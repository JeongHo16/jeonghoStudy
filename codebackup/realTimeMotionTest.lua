require("config") 
require("module")
require("common")
require("RigidBodyWin/subRoutines/Constraints")
require("RigidBodyWin/retargetting/kinectTracker")

config_jeongho = {
	"../Resource/jae/social_p1/social_p1.wrl",
	"../Resource/jae/social_p1/social_p1_copy.wrl.dof",
	skinScale=1
}

config = config_jeongho

jointsMap = {
	["JOINT_HEAD"]=1,
	["JOINT_NECK"]=2,
	["JOINT_TORSO"]=3,
	["JOINT_WAIST"]=4,			

	["JOINT_LEFT_COLLAR"]=5,
	["JOINT_LEFT_SHOULDER"]=6,
	["JOINT_LEFT_ELBOW"]=7,
	["JOINT_LEFT_WRIST"]=8,		
	["JOINT_LEFT_HAND"]=9,		

	["JOINT_RIGHT_COLLAR"]=11,
	["JOINT_RIGHT_SHOULDER"]=12,
	["JOINT_RIGHT_ELBOW"]=13,
	["JOINT_RIGHT_WRIST"]=14,	
	["JOINT_RIGHT_HAND"]=15,	

	["JOINT_LEFT_HIP"]=17,	
	["JOINT_LEFT_KNEE"]=18,		
	["JOINT_LEFT_ANKLE"]=19,		

	["JOINT_RIGHT_HIP"]=21,	
	["JOINT_RIGHT_KNEE"]=22,		
	["JOINT_RIGHT_ANKLE"]=23	
}

useDevice = true
--useDevice = false

tracking = false
recording = false
playingMotion = false
motionSize = 0

function ctor()
	mEventReceiver=EVR()

	fileList = scandir("jsonDatas")

	this:create("Button", "Check Viewpoint", "Check Viewpoint")
	this:create("Check_Button", "Tracking", "Tracking")
	this:widget(0):checkButtonValue(false)
	this:widget(0):buttonShortcut("t")
	this:create("Button", "Start Record", "Start Record")
	this:create("Button", "Stop Record", "Stop Record")
	this:create("Input", "Motion Title", "")
	this:create("Button", "Save Motion", "Save Motion")
	this:create("Choice", "load Motion file")
	this:widget(0):menuSize(#fileList)
	for i=1, #fileList do
		this:widget(0):menuItem(i-1, fileList[i])
	end
	this:widget(0):menuValue(0)
	this:create("Button", "Play Motion File", "Play Motion File")
--	this:create("Check_Button", "drawAxes", "drawAxes")
--	this:widget(0):checkButtonValue(false)
--	this:widget(0):buttonShortcut("d")
	this:updateLayout()

	RE.viewpoint().vpos:set(368, 210, 26)
	RE.viewpoint().vat:set(6, 126, -2)
	RE.viewpoint():update()

	mLoader=MainLib.VRMLloader(config[1])
	mLoader:printHierarchy()
	
	mSkin = RE.createVRMLskin(mLoader, false)
	local s=config.skinScale
	mSkin:scale(s,s,s)
--[[
	mMotionDOFcontainer = MotionDOFcontainer(mLoader.dofInfo, config[2])
	mMotionDOF = mMotionDOFcontainer.mot
	 
	for i=0, mMotionDOF:rows()-1 do
		mMotionDOF:matView():set(i, 1, mMotionDOF:matView()(i,1)*100)
	end

	mSkin:applyMotionDOF(mMotionDOF)
	mSkin:setFrameTime(1/120)

	RE.motionPanel():motionWin():detachSkin(mSkin)
	RE.motionPanel():motionWin():addSkin(mSkin)
]]
	userPose = Pose()
	userPose:init(mLoader:numRotJoint(), mLoader:numTransJoint())
	userPose:identity()	
	mSkin:_setPose(userPose, mLoader)

	mNuiListener = NuiListener()
	if useDevice then
		mNuiListener:startNuitrack()
	end

	mTimeline=Timeline("Timeline", 10000)
end

function frameMove(fElapsedTime)
	if tracking then
		mNuiListener:waitUpdate()
		--drawUserJoints()
		--getUserPose()
		if recording then
			mNuiListener:createRecordedJson()
		end
	end
end

function onCallback(w, userData)
	if w:id()=="Check Viewpoint" then
		print(RE.viewpoint().vpos)
		print(RE.viewpoint().vat)
	elseif w:id()=="Tracking" then
		if w:checkButtonValue() then
			tracking = true
		else
			dbg.eraseAllDrawn()
			tracking = false
		end 
	elseif w:id()=="Start Record" then
		if tracking then
			print("Start Recording")
			recording = true
		end
	elseif w:id()=="Stop Record" then
		if recording == true then
			print("Stop Recording")
			recording = false
		end
	elseif w:id()=="Save Motion" then
		local title = this:findWidget("Motion Title"):inputValue()
		if title ~= "" then
			print("Saved MotionData")
			mNuiListener:saveJsonStringToFile(title)
		end
	elseif w:id()=="Play Motion File" then
		local title = string.sub(this:findWidget("load Motion file"):menuText(),0,-6)
		if title ~= "" and not playingMotion then
			print("Start play recorded motion")
			playingMotion = true
			mNuiListener:loadFileToJson(title)
			motionSize = mNuiListener:getMotionFrameSize()
		end
--[[
	elseif w:id()=="drawAxes" then
		if w:checkButtonValue() then
			dbg.namedDraw("Axes", transf(quater(1,0,0,0), vector3(0,0,100)), "axes")
		else
			dbg.erase("Axes", "axes")
		end
]]
	end
end

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function getUserPose(fIdx)
	local pose = Pose()
	pose:init(mLoader:numRotJoint(), mLoader:numTransJoint())
	pose:identity()	

	pose:setRootTransformation(getUserRootTransf(fIdx))
	pose.rotations:assign(setRotJoints(fIdx))

	userPose = pose	
	mSkin:_setPose(userPose, mLoader)
end

function getUserRootTransf(fIdx) --TODO : y값 조정
	local rootRot = getJointRot("JOINT_WAIST", fIdx)
	local rootPos = getJointPos("JOINT_WAIST", fIdx)
	return transf(rootRot, rootPos+vector3(0,128,0))
end

function setRotJoints(fIdx)
	local rots = quaterN() 
	rots:pushBack(getJointRot("JOINT_WAIST",fIdx)) 
	rots:pushBack(getUserJointLocalRot("JOINT_WAIST","JOINT_TORSO",fIdx))
	rots:pushBack(getUserJointLocalRot("JOINT_TORSO","JOINT_LEFT_COLLAR",fIdx))
	rots:pushBack(getUserJointLocalRot("JOINT_LEFT_COLLAR","JOINT_NECK",fIdx))
	rots:pushBack(getUserJointLocalRot("JOINT_NECK","JOINT_HEAD",fIdx))

	rots:pushBack(quater(1,0,0,0)) -- LEFT_COLLAR
	rots:pushBack(getUserJointLocalRot("JOINT_LEFT_COLLAR","JOINT_LEFT_SHOULDER",fIdx))
	rots:pushBack(getUserJointLocalRot("JOINT_LEFT_SHOULDER","JOINT_LEFT_ELBOW",fIdx))
	rots:pushBack(getUserJointLocalRot("JOINT_LEFT_ELBOW","JOINT_LEFT_WRIST",fIdx))

	rots:pushBack(quater(1,0,0,0)) -- RIGHT_COLLAR
	rots:pushBack(getUserJointLocalRot("JOINT_RIGHT_COLLAR","JOINT_RIGHT_SHOULDER",fIdx))
	rots:pushBack(getUserJointLocalRot("JOINT_RIGHT_SHOULDER","JOINT_RIGHT_ELBOW",fIdx))
	rots:pushBack(getUserJointLocalRot("JOINT_RIGHT_ELBOW","JOINT_RIGHT_WRIST",fIdx))

	--rots:pushBack(getUserJointLocalRot("JOINT_WAIST","JOINT_LEFT_HIP",fIdx))
	--rots:pushBack(getUserJointLocalRot("JOINT_LEFT_HIP","JOINT_LEFT_KNEE",fIdx))
	--rots:pushBack(getUserJointLocalRot("JOINT_LEFT_KNEE","JOINT_LEFT_ANKLE",fIdx))
	rots:pushBack(quater(1,0,0,0))
	rots:pushBack(quater(1,0,0,0))
	rots:pushBack(quater(1,0,0,0)) -- LEFT_ANKLE
	rots:pushBack(quater(1,0,0,0)) -- LEFT_TOE

	--rots:pushBack(getUserJointLocalRot("JOINT_WAIST","JOINT_RIGHT_HIP",fIdx))
	--rots:pushBack(getUserJointLocalRot("JOINT_RIGHT_HIP","JOINT_RIGHT_KNEE",fIdx))
	--rots:pushBack(getUserJointLocalRot("JOINT_RIGHT_KNEE","JOINT_RIGHT_ANKLE",fIdx))
	rots:pushBack(quater(1,0,0,0))
	rots:pushBack(quater(1,0,0,0))
	rots:pushBack(quater(1,0,0,0)) -- RIGHT_ANKLE
	rots:pushBack(quater(1,0,0,0)) -- RIGHT_TOE

	return rots
end

function getUserJointLocalRot(preRot, curRot, fIdx)
	preRot = getJointRot(preRot, fIdx)
	curRot = getJointRot(curRot, fIdx)
	curRot:toLocal(preRot, curRot)
	return curRot
end

function drawUserJoints()
for k,v in pairs(jointsMap) do
	if not(k==10 or k==16 or k==20 or k==24) then 
		dbg.namedDraw("Sphere", getJointPos(v)+vector3(0,108,0), v, "red", 3)
		--dbg.draw("Axes", transf(getJointRot(k), getJointPos(k)+vector3(0,108,0)), "a"..v)
	end
end
end

function getJointPos(jIdx, fIdx)
	if type(jIdx) == "string" then
		jIdx = jointsMap[jIdx]
	end
	
	local pos = vector3()
	if fIdx == nil then
		pos.x = mNuiListener:getJointPos(jIdx,0)/10
		pos.y = mNuiListener:getJointPos(jIdx,1)/10
		pos.z = -mNuiListener:getJointPos(jIdx,2)/10
	else
		pos.x = mNuiListener:getMotionFileInfo(fIdx,"pos",jIdx,0)/10
		pos.y = mNuiListener:getMotionFileInfo(fIdx,"pos",jIdx,1)/10
		pos.z = -mNuiListener:getMotionFileInfo(fIdx,"pos",jIdx,2)/10
	end

	return pos
end

function getJointRot(jIdx, fIdx)
	if type(jIdx) == "string" then
		jIdx = jointsMap[jIdx]
	end
	
	local rot = vectorn(9)
	if fIdx == nil then
		for i=0, 8 do
			rot:set(i, mNuiListener:getJointRot(jIdx,i))
		end
	else
		for i=0, 8 do
			rot:set(i, mNuiListener:getMotionFileInfo(fIdx,"ori",jIdx,i))
		end
	end

	local mat = matrix4()
	mat:setValue(rot(0),rot(3),rot(6),0,rot(1),rot(4),rot(7),0,rot(2),rot(5),rot(8),0,0,0,0,1)

	local quat = quater()
	quat:setRotation(mat)
	quat:setValue(quat.w, quat.x, quat.y, -quat.z)

	return quat
end

function playMotionFile(fIdx)
	getUserPose(fIdx)
--[[
	local tempVec = vector3()
	for i=1, 24 do
		if not(i==10 or i==16 or i==20 or i==24) then
			tempVec.x = mNuiListener:getMotionFileInfo(fIdx,"pos",i,0)/10
			tempVec.y = mNuiListener:getMotionFileInfo(fIdx,"pos",i,1)/10
			tempVec.z = -mNuiListener:getMotionFileInfo(fIdx,"pos",i,2)/10
			dbg.namedDraw("Sphere", tempVec+vector3(0,108,0), "b"..i, "red", 3)
		end
	end
]]
end

if EventReceiver then
	--class 'EVR'(EventReceiver)
	EVR=LUAclass(EventReceiver)
	function EVR:__init(graph)
		--EventReceiver.__init(self)
		self.currFrame=0
		self.cameraInfo={}
	end
end

curFrame = 0
function EVR:onFrameChanged(win, iframe)
	if playingMotion and curFrame < motionSize then 
		playMotionFile(curFrame)	
		curFrame = curFrame + 1
	else
		playingMotion = false
		curFrame = 0
		dbg.eraseAllDrawn()
	end
end

Timeline=LUAclass(LuaAnimationObject)
function Timeline:__init(label, totalTime)
	self.totalTime=totalTime
	self:attachTimer(1/30, totalTime)		
	RE.renderer():addFrameMoveObject(self)
	RE.motionPanel():motionWin():addSkin(self)
end

function dtor()
end

--[[
function drawLoaderJoints()
	for i=1, mLoader:numBone()-1 do
		dbg.namedDraw("Axes", mLoader:bone(i):getFrame(), "axes"..i)
		--dbg.namedDraw("Sphere", mLoader:bone(i):getFrame().translation, mLoader:bone(i):name(), "red", 3)
	end
end
]]
