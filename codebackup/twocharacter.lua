require("config") 
require("module")
require("common")
require("RigidBodyWin/subRoutines/Constraints")
require("RigidBodyWin/retargetting/kinectTracker")

config_jeongho = {
	{
		"../Resource/jae/social_p1/social_p1.wrl",
		"../Resource/jae/social_p1/social_p1_copy.wrl.dof",
	},
	{
		"../Resource/jae/social_p2/social_p2.wrl",
		"../Resource/jae/social_p2/social_p2_copy.wrl.dof",
	},
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

--useDevice = true
useDevice = false

tracking = false
recording = false
playingMotion = false
motionSize = 0
historySize = 4 

learnType = 0

function ctor()
	mEventReceiver=EVR()

	fileList = scandir("jsonDatas")

	this:create("Button", "Check Viewpoint", "Check Viewpoint")
	this:create("Check_Button", "Tracking", "Tracking")
	this:widget(0):checkButtonValue(false)
	this:widget(0):buttonShortcut("t")
	this:create("Button", "Start Record", "Start Record")
	this:widget(0):buttonShortcut("s")
	this:create("Button", "Stop Record", "Stop Record")
	this:widget(0):buttonShortcut("e")
	this:create("Input", "Motion Title", "")
	this:create("Button", "Save Motion", "Save Motion")
	this:create("Choice", "Select learn type")
	this:widget(0):menuSize(4)
	this:widget(0):menuItem(0, "kinectRaw")
	this:widget(0):menuItem(1, "current")
	this:widget(0):menuItem(2, "past")
	this:widget(0):menuItem(3, "past and future")
	this:create("Button", "learn", "learn")
	this:create("Choice", "load Motion file")
	this:widget(0):menuSize(#fileList)
	for i=1, #fileList do
		this:widget(0):menuItem(i-1, fileList[i])
	end
	this:widget(0):menuValue(0)
	this:create("Button", "Play Motion File", "Play Motion File")
	this:widget(0):buttonShortcut("p")
	this:create("Check_Button", "drawAxes", "drawAxes")
	this:widget(0):checkButtonValue(false)
	this:widget(0):buttonShortcut("d")
	this:updateLayout()

	RE.viewpoint().vpos:set(117, 341, 467)
	RE.viewpoint().vat:set(6, 126, -2)
	RE.viewpoint():update()

	mLoader=MainLib.VRMLloader(config[1][1])
	mLoader2=MainLib.VRMLloader(config[2][1])
	mLoader:printHierarchy()
	
	mSkin = RE.createVRMLskin(mLoader, false)
	local s=config.skinScale
	mSkin:scale(s,s,s)
	
	mSkin2 = RE.createVRMLskin(mLoader2, false)
	local s=config.skinScale
	mSkin2:scale(s,s,s)
	mSkin2:setTranslation(130,0,0)

	mMotionDOFcontainer = MotionDOFcontainer(mLoader.dofInfo, config[1][2])
	mMotionDOF = mMotionDOFcontainer.mot
	mMotionDOFcontainer2 = MotionDOFcontainer(mLoader2.dofInfo, config[2][2])
	mMotionDOF2 = mMotionDOFcontainer2.mot

	for i=0, mMotionDOF:rows()-1 do
		mMotionDOF:matView():set(i, 1, mMotionDOF:matView()(i,1)*100)
		mMotionDOF2:matView():set(i, 1, mMotionDOF2:matView()(i,1)*100)
	end
	
	initRootTrans = getInitRootTransf(mMotionDOF)

	userPose = Pose()
	userPose:init(mLoader:numRotJoint(), mLoader:numTransJoint())
	userPose:identity()	

	mSkin:setPoseDOF(mMotionDOF:row(0))
	mSkin2:setPoseDOF(mMotionDOF2:row(0))

	mNuiListener = NuiListener()
	if useDevice then
		mNuiListener:startNuitrack()
	end

	featureHistory = matrixn()

	mTimeline=Timeline("Timeline", 10000)
end

function frameMove(fElapsedTime)
	if tracking then
		mNuiListener:waitUpdate()
		getUserPose()
		--drawUserJoints()
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
			prePlayMotion()
		end
	elseif w:id()=="Select learn type" then
		learnType = this:findWidget("Select learn type"):menuValue()
	elseif w:id()=="learn" then
		learnFeature(learnType)
	elseif w:id()=="drawAxes" then
		if w:checkButtonValue() then
			dbg.namedDraw("Axes", transf(quater(1,0,0,0), vector3(0,0,100)), "axes")
		else
			dbg.erase("Axes", "axes")
		end
	end
end

function getInitRootTransf(mMotionDOF)
	local rootPos = mMotionDOF:row(0):toVector3(0)
	local rootRot = mMotionDOF:row(0):toQuater(3)
	return transf(rootRot, rootPos)
end

--[[
function getOffset(skin, skin2)
	local root1 = skin:getTranslation()
	local root2 = skin2:getTranslation()
	return root1-root2
end
]]

--[[
function extractPreFeature(loader, fIdx, historySize)
	local histMat = matrixn()
	
	for i=fIdx-historySize, fIdx-1 do
		loader:setPoseDOF(mMotionDOF:row(i))
		histMat:pushBack(getFeature(loader))
	end
	
	return histMat:toVector()
end

function extractFutPreFeature(loader, fIdx, historySize)
	local histMat = matrixn()
	
	for i=fIdx-historySize, fIdx+historySize-1 do
		loader:setPoseDOF(mMotionDOF:row(i))
		histMat:pushBack(getFeature(loader))
	end
	
	return histMat:toVector()
end
]]

function getFeature(loader)--하드코딩 고치기 
	local feature=vectorn()
	feature:setSize(27)

	feature:setVec3(0, loader:bone(18):getFrame().translation)
	feature:setVec3(3, loader:bone(14):getFrame().translation)
	feature:setVec3(6, loader:bone(20):getFrame().translation)
	feature:setVec3(9, loader:bone(16):getFrame().translation)
	feature:setVec3(12, loader:bone(11):getFrame().translation)
	feature:setVec3(15, loader:bone(12):getFrame().translation)
	feature:setVec3(18, loader:bone(7):getFrame().translation)
	feature:setVec3(21, loader:bone(8):getFrame().translation)
	feature:setVec3(24, loader:bone(1):getFrame().translation)

	return feature
end

function extractFeature(loader, fIdx, historySize)
	local histMat = matrixn()

	if learnType == 1 then
		return getFeature(loader)
	elseif learnType == 2 then
		print(fIdx)
		for i=fIdx-historySize, fIdx-1 do
			loader:setPoseDOF(mMotionDOF:row(i))
			histMat:pushBack(getFeature(loader))
		end
		return histMat:toVector()
	elseif learnType == 3 then
		for i=fIdx-historySize, fIdx+historySize-1 do
			loader:setPoseDOF(mMotionDOF:row(i))
			histMat:pushBack(getFeature(loader))
		end
		return histMat:toVector()
	end
end

--[[
function extractFeature2(loader) 
	local feature=vectorn()
	feature:setSize(27)

	function convert(num)
		local conv = vector3()
		conv:assign(loader:bone(num):getFrame().translation)
		conv.x = -conv.x
		conv.z = -conv.z
		return conv-getOffset(mSkin,mSkin2)
	end

	feature:setVec3(0, convert(18))
	feature:setVec3(3, convert(14))
	feature:setVec3(6, convert(20))
	feature:setVec3(9, convert(16))
	feature:setVec3(12, convert(11))
	feature:setVec3(15, convert(12))
	feature:setVec3(18, convert(7))
	feature:setVec3(21, convert(8))
	feature:setVec3(24, convert(1))

	for i=0, 8 do
		dbg.draw("Sphere", feature:toVector3(i*3), "ib"..i, "blue", 3)
	end

	return feature
end
]]

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
	userPose:setRootTransformation(initRootTrans)
	userPose.rotations:assign(setRotJoints(fIdx))

	mSkin:_setPose(userPose, mLoader)
	mLoader:setPose(userPose)

	--local poseV = vectorn()
	--mLoader:getPoseDOF(poseV)
	
	--return poseV
	print("getUserPose")
	return extractFeature(mLoader, fIdx, historySize)
end

function getUserRootTransf(fIdx) --TODO : y값 조정
	local rootRot = getJointRot("JOINT_WAIST", fIdx)
	local rootPos = getJointPos("JOINT_WAIST", fIdx)
	return transf(rootRot, rootPos+vector3(0,128,0))
end

function setRotJoints(fIdx)
	local rots = quaterN() 
	--rots:pushBack(getJointRot("JOINT_WAIST",fIdx)) 
	rots:pushBack(mMotionDOF:row(0):toQuater(3)) 
	--rots:pushBack(quater(1,0,0,0)) 
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

function learnFeature(state)
	local features = matrixn()
	local matdata = matrixn()

	if state == 1 then 
		for i=0, mMotionDOF:numFrames()-1 do
			mLoader:setPoseDOF(mMotionDOF:row(i))
			features:pushBack(extractFeature(mLoader))
		end
		matdata:assign(mMotionDOF:matView())
	elseif state == 2 then
		for i=historySize, mMotionDOF:numFrames()-1 do
			features:pushBack(extractFeature(mLoader, i, historySize))
			matdata:pushBack(mMotionDOF:row(i))
		end
	elseif state == 3 then
		local size = historySize/2

		for i=size, mMotionDOF:numFrames()-size-1 do
			features:pushBack(extractFeature(mLoader, i, size))
			matdata:pushBack(mMotionDOF:row(i))
		end
	else
		print("learnType is kinectRaw")
		dbg.console()
	end

	mMetric = math.KovarMetric(true)
	mIDW = NonlinearFunctionIDW(mMetric, 30, 2.0)
	mIDW:learn(features, matdata)
	print("learned by "..learnType)
end

--[[
function learnFeature()
	local features = matrixn()
	
	for i=0, mMotionDOF:numFrames()-1 do
		mLoader:setPoseDOF(mMotionDOF:row(i))
		features:pushBack(extractFeature(mLoader))
	end

	mMetric = math.KovarMetric(true)
	mIDW = NonlinearFunctionIDW(mMetric, 30, 2.0)
	mIDW:learn(features, mMotionDOF:matView())
end

function learnFeature2()
	local features = matrixn()
	local matdata = matrixn()

	for i=historySize, mMotionDOF:numFrames()-1 do
		features:pushBack(extractPreFeature(mLoader, i, historySize))
		matdata:pushBack(mMotionDOF:row(i))
	end
	
	mMetric = math.KovarMetric(true)
	mIDW = NonlinearFunctionIDW(mMetric, 30, 2.0)
	mIDW:learn(features, matdata)
end

function learnFeature3()
	local features = matrixn()
	local matdata = matrixn()

	local size = historySize/2

	for i=size, mMotionDOF:numFrames()-size-1 do
		features:pushBack(extractFutPreFeature(mLoader, i, size))
		matdata:pushBack(mMotionDOF:row(i))
	end
	
	mMetric = math.KovarMetric(true)
	mIDW = NonlinearFunctionIDW(mMetric, 30, 2.0)
	mIDW:learn(features, matdata)
end
]]
function prePlayMotion()
	if learnType == 2 then
		local mat = matrixn()
		for i=historySize, 2*historySize-1 do
			mat:pushBack(getUserPose(i))
		end
		featureHistory:assign(mat)
	elseif learnType == 3 then
		local mat = matrixn()
		for i=historySize/2, historySize/2-1 do
			mat:pushBack(getUserPose(i))
		end
		featureHistory:assign(mat)
	end
--	if learnType == 2 or learnType == 3 then
--		local mat = matrixn()
--		for i=0, historySize-1 do
--			print(i)
--			mat:pushBack(getUserPose(i))
--		end
--		featureHistory:assign(mat)
--	end
end

function playMotionFile(fIdx)
	local target = vectorn()

	if learnType == 0 then
		return getUserPose(fIdx) -- return 안하면 맨밑 두줄에서 에러남 
	elseif learnType == 1 then
		getUserPose(fIdx)
		mIDW:mapping(extractFeature(mLoader), target) 
	elseif learnType == 2 then
		featureHistory:pushBack(getUserPose(fIdx))
		mIDW:mapping(featureHistory:sub(featureHistory:rows()-historySize, featureHistory:rows(),0,0):toVector(), target)--2번
	elseif learnType == 3 then
		featureHistory:pushBack(getUserPose(fIdx+(historySize/2)))
		getUserPose(fIdx)
		mIDW:mapping(featureHistory:sub(fIdx-(historySize/2), fIdx+(historySize/2),0,0):toVector(), target)--3번
	end

	target:setQuater(3, target:toQuater(3):Normalize())
	mSkin:setPoseDOF(target)
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

function getCurFrame()
	if learnType == 0 or learnType == 1 then
		return 0
	elseif learnType == 2 then
		return historySize
	elseif learnType == 3 then
		return historySize/2
	end
end

curFrame = getCurFrame() 
print("cur")
print(curFrame)
function EVR:onFrameChanged(win, iframe)
	if learnType ~= 3 then
		if playingMotion and curFrame < motionSize then 
			playMotionFile(curFrame)	
			curFrame = curFrame + 1
		else
			playingMotion = false
			curFrame = getCurFrame()
			dbg.eraseAllDrawn()
		end
	else
		if playingMotion and curFrame < motionSize-historySize then 
			playMotionFile(curFrame)	
			curFrame = curFrame + 1
		else
			playingMotion = false
			curFrame = getCurFrame()
			dbg.eraseAllDrawn()
		end
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
