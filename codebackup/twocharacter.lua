require("config") 
require("module")
require("common")
require("RigidBodyWin/subRoutines/Constraints")
require("RigidBodyWin/subRoutines/VelocityFields")
--require("RigidBodyWin/retargetting/kinectTracker")

config_jeongho = {
	{
		"../../ETRI_2020/Resource/jae/social_p1/social_p1.wrl",
		"../../ETRI_2020/Resource/jae/social_p1/social_p1_copy.wrl.dof",--frameRate 120인줄 알았는데 30이네? 정확한 확인법->dofInfo.frameRate 틀릴 수 있음 눈으로 보는게 나음.
	},
	{
		"../../ETRI_2020/Resource/jae/social_p2/social_p2.wrl",
		"../../ETRI_2020/Resource/jae/social_p2/social_p2_copy.wrl.dof",
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

featureMap = {
	"RightHip",	
	"LeftHip",	
	"RightAnkle",
	"LeftAnkle",		
	"RightShoulder",
	"RightElbow",
	"LeftShoulder",
	"LeftElbow",
	"Hips"
}

--useDevice = true
useDevice = false

tracking = false
recording = false
playingMotion = false

learnType = 3
historySize = 6
motionSize = 0
playStartFrame = 0
playEndFrame = 0

kinectPosOffset = vector3()

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
--	this:create("Choice", "Select learn type")
--	this:widget(0):menuSize(4)
--	this:widget(0):menuItem(0, "kinectRaw")
--	this:widget(0):menuItem(1, "current")
--	this:widget(0):menuItem(2, "past")
--	this:widget(0):menuItem(3, "past and future")
	this:create("Button", "learn", "learn")
	this:widget(0):buttonShortcut("l")
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
	mSkin2:scale(s,s,s)
	mSkin2:setTranslation(130,0,0)

	mMotionDOFcontainer = MotionDOFcontainer(mLoader.dofInfo, config[1][2])
	mMotionDOFcontainer.discontinuity:set(0, true)
	mMotionDOFcontainer:resample(mMotionDOFcontainer:copy(), 4)--30으로 맞추기
	mMotionDOF = mMotionDOFcontainer.mot

	mMotionDOFcontainer2 = MotionDOFcontainer(mLoader2.dofInfo, config[2][2])
	mMotionDOFcontainer2.discontinuity:set(0, true)
	mMotionDOFcontainer2:resample(mMotionDOFcontainer2:copy(), 4)
	mMotionDOF2 = mMotionDOFcontainer2.mot

	for i=0, mMotionDOF:rows()-1 do
		mMotionDOF:matView():set(i, 1, mMotionDOF:matView()(i,1)*100)
		mMotionDOF2:matView():set(i, 1, mMotionDOF2:matView()(i,1)*100)
	end

	userPose = Pose()
	userPose:init(mLoader:numRotJoint(), mLoader:numTransJoint())
	userPose:identity()

	mSkin:setPoseDOF(mMotionDOF:row(0))
	mSkin2:setPoseDOF(mMotionDOF2:row(0))

	mNuiListener = NuiListener()
	if useDevice then
		mNuiListener:startNuitrack()
	end

	mDeriv=VelocityFields(mLoader, mMotionDOFcontainer, mMotionDOF:row(0), {frameRate=30, alignRoot=true})-- 여기서 y값 바꿔 놓기
	mDeriv2=VelocityFields(mLoader2, mMotionDOFcontainer2, mMotionDOF2:row(0), {frameRate=30, alignRoot=true})

	mTimeline=Timeline("Timeline", mMotionDOF:numFrames())
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
			kinectPosOffset = mMotionDOF:row(0):toVector3(0)-getJointPos("JOINT_WAIST", 0)
			setPlayFrame()
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

function getUserRootPos(fIdx)
	local rootPos = getJointPos("JOINT_WAIST", fIdx)
	return transf(quater(1,0,0,0), rootPos+kinectPosOffset)
end

function getUserRootOri(fIdx)
	local rootRot = getJointRot("JOINT_WAIST", fIdx)
	--local initRotY = mMotionDOF:row(0):toQuater(3)
	local addrot = quater(math.rad(90),vector3(0,1,0))
	dbg.namedDraw("Axes", transf(addrot*rootRot, getJointPos("JOINT_WAIST", fIdx)+kinectPosOffset), "axes")
	--return addrot*rootRot
	return rootRot
end

function getFeature(loader)
	local feature=vectorn()
	feature:setSize(#featureMap*3)

	for i=1, #featureMap do
		feature:setVec3((i-1)*3, loader:getBoneByName(featureMap[i]):getFrame().translation)
	end

	return feature
end

function extractFeature(loader, fIdx, historySize)
	local histMat = matrixn()

	if learnType == 1 then
		loader:setPoseDOF(mMotionDOF:row(fIdx))
		histMat:pushBack(getFeature(loader))
	elseif learnType == 2 then
		for i=fIdx-historySize, fIdx-1 do
			loader:setPoseDOF(mMotionDOF:row(i))
			histMat:pushBack(getFeature(loader))
		end
	elseif learnType == 3 then
		for i=fIdx-historySize, fIdx+historySize-1 do
			loader:setPoseDOF(mMotionDOF:row(i))
			histMat:pushBack(getFeature(loader))
		end
	end
	return histMat:toVector()
end

function extractKinectFeature(loader, fIdx, historySize)
	local histMat = matrixn()

	if learnType == 1 then
		getUserPose(fIdx)
		histMat:pushBack(getFeature(loader))
	elseif learnType == 2 then
		for i=fIdx-historySize, fIdx-1 do
			getUserPose(i)
			histMat:pushBack(getFeature(loader))
		end
	elseif learnType == 3 then
		for i=fIdx-historySize, fIdx+historySize-1 do
			getUserPose(i)
			histMat:pushBack(getFeature(loader))
		end
	end
	return histMat:toVector()
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

function getUserPose(fIdx) --fIdx가 있으면 녹화된 파일에서 불러오기
	userPose:setRootTransformation(getUserRootPos(fIdx))
	userPose.rotations:assign(setRotJoints(fIdx))

	mLoader:setPose(userPose)
	mSkin:_setPose(userPose, mLoader)
end

function setRotJoints(fIdx) --TODO:rootRot 고정 시키지 않기
	local rots = quaterN() 
	--rots:pushBack(getJointRot("JOINT_WAIST",fIdx)) 
	rots:pushBack(getUserRootOri(fIdx)) 
	rots:pushBack(getUserJointLocalRot("JOINT_WAIST","JOINT_TORSO",fIdx))--여기가 1번
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
	--python.FC('test_sample_python', 'saveJointAngles', getUserJointLocalRot("JOINT_RIGHT_ELBOW","JOINT_RIGHT_WRIST",fIdx):rotationAngle())

--	rots:pushBack(getUserJointLocalRot("JOINT_WAIST","JOINT_LEFT_HIP",fIdx))
--	rots:pushBack(getUserJointLocalRot("JOINT_LEFT_HIP","JOINT_LEFT_KNEE",fIdx))
--	rots:pushBack(getUserJointLocalRot("JOINT_LEFT_KNEE","JOINT_LEFT_ANKLE",fIdx))
	rots:pushBack(quater(1,0,0,0))
	rots:pushBack(quater(1,0,0,0))
	rots:pushBack(quater(1,0,0,0)) -- LEFT_ANKLE
	rots:pushBack(quater(1,0,0,0)) -- LEFT_TOE

--	rots:pushBack(getUserJointLocalRot("JOINT_WAIST","JOINT_RIGHT_HIP",fIdx))
--	rots:pushBack(getUserJointLocalRot("JOINT_RIGHT_HIP","JOINT_RIGHT_KNEE",fIdx))
--	rots:pushBack(getUserJointLocalRot("JOINT_RIGHT_KNEE","JOINT_RIGHT_ANKLE",fIdx))
	rots:pushBack(quater(1,0,0,0))
	rots:pushBack(quater(1,0,0,0))
	rots:pushBack(quater(1,0,0,0)) -- RIGHT_ANKLE
	rots:pushBack(quater(1,0,0,0)) -- RIGHT_TOE

	--print(rots:size())

	return rots
end

function getUserJointLocalRot(preRot, curRot, fIdx)
	preRot = getJointRot(preRot, fIdx)
	curRot = getJointRot(curRot, fIdx)
	curRot:toLocal(preRot, curRot) -- 여기 내부에서 align 시킴
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
		for i=1, mMotionDOF:numFrames()-1 do
			features:pushBack(extractFeature(mLoader, i))
			matdata:pushBack(mDeriv.dmot:row(i-1)..mMotionDOF:row(i)..mDeriv2.dmot:row(i-1)..mMotionDOF2:row(i))
			--matdata:pushBack(mDeriv.dmot:row(i-1)..mMotionDOF:row(i))
		end
	elseif state == 2 then
		for i=historySize, mMotionDOF:numFrames()-1 do
			features:pushBack(extractFeature(mLoader, i, historySize))
			matdata:pushBack(mDeriv.dmot:row(i-1)..mMotionDOF:row(i)..mDeriv2.dmot:row(i-1)..mMotionDOF2:row(i))
			--matdata:pushBack(mDeriv.dmot:row(i-1)..mMotionDOF:row(i))
		end
	elseif state == 3 then
		historySize = historySize/2

		for i=historySize, mMotionDOF:numFrames()-historySize-1 do
			features:pushBack(extractFeature(mLoader, i, historySize))
			--matdata:pushBack(mDeriv.dmot:row(i-1)..mMotionDOF:row(i)..mDeriv2.dmot:row(i-1)..mMotionDOF2:row(i))
			matdata:pushBack(mDeriv.dmot:row(i-1)..mMotionDOF:row(i))
		end
	else
		print("learnType is kinectRaw")
		dbg.console()
	end

	mMetric = math.KovarMetric(true)
	mIDW = NonlinearFunctionIDW(mMetric, 30, 2.0)
	mIDW:learn(features, matdata)
	--print("Learn type is "..this:findWidget("Select learn type"):menuText())
	print("learned")
end

function playMotionFile(fIdx)
	local temp = vectorn()
	local refDpose = vectorn()
	local refPose = vectorn()
	local refDpose2 = vectorn()
	local refPose2 = vectorn()

	if learnType == 0 then
		return getUserPose(fIdx) -- return 안하면 맨밑 두줄에서 에러남 
	elseif learnType == 1 then
		mIDW:mapping(extractKinectFeature(mLoader, fIdx), temp) 
	elseif learnType == 2 then
		mIDW:mapping(extractKinectFeature(mLoader, fIdx, historySize), temp)
	elseif learnType == 3 then
		mIDW:mapping(extractKinectFeature(mLoader, fIdx, historySize), temp) --TODO: Q) y축이 어느 방향을 봐도 상관없이 mapping? x
		--extractKinectFeature(mLoader, fIdx, historySize)
	end

	refDpose:assign(temp:range(0, temp:size()/2))
	refPose:assign(temp:range(temp:size()/2, temp:size()))

	refPose:set(0,0)
	refPose:set(2,0)
	refPose:setQuater(3, refPose:toQuater(3):offsetQ())
	refPose:setQuater(3, refPose:toQuater(3):Normalize())

	mDeriv:stepKinematic(refDpose, refPose, 0.4)
	mSkin:setPoseDOF(mDeriv.pose)

--	refDpose:assign(temp:range(0, temp:size()/4))
--	refPose:assign(temp:range(temp:size()/4, temp:size()/2))
--
--	refPose:set(0,0)
--	refPose:set(2,0)--TODO:y축으로 도는 것 해결하기
--	refPose:setQuater(3, refPose:toQuater(3):offsetQ()) --offsetQ가 머지?->y축 회전 정보 빼고 나머지?...
--	refPose:setQuater(3, refPose:toQuater(3):Normalize()) --Normalize와 offsetQ 순서?크게 상관없을듯...
--
--	refDpose2:assign(temp:range(temp:size()/2, temp:size()*3/4))
--	refPose2:assign(temp:range(temp:size()*3/4, temp:size()))
--
--	refPose2:set(0,0)
--	refPose2:set(2,0)
--	refPose2:setQuater(3, refPose2:toQuater(3):offsetQ())
--	refPose2:setQuater(3, refPose2:toQuater(3):Normalize())
--
--	poseIntegrationAlpha=0.4
--	mDeriv:stepKinematic(refDpose, refPose, poseIntegrationAlpha)
--	mSkin:setPoseDOF(mDeriv.pose)
--
--	mDeriv2:stepKinematic(refDpose2, refPose2, poseIntegrationAlpha) -- 두번째 캐릭터를 첫번째 캐릭터에 상대적으로 인코딩
--	mSkin2:setPoseDOF(mDeriv2.pose)
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

function setPlayFrame() 
	if learnType == 0 or learnType == 1 then
		playStartFrame = 0	
	elseif learnType == 2 or learnType==3 then
		playStartFrame = historySize
	end

	if learnType == 3 then
		playEndFrame = motionSize - historySize	
	else
		playEndFrame = motionSize
	end
end

function EVR:onFrameChanged(win, iframe)
	if playingMotion and playStartFrame < playEndFrame then 
		playMotionFile(playStartFrame)	
		playStartFrame = playStartFrame + 1
	else
		playingMotion = false
		setPlayFrame()
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
	python.FC('test_sample_python', 'makeResult', elaspedFrame)
end

--[[
function drawLoaderJoints()
	for i=1, mLoader:numBone()-1 do
		dbg.namedDraw("Axes", mLoader:bone(i):getFrame(), "axes"..i)
		--dbg.namedDraw("Sphere", mLoader:bone(i):getFrame().translation, mLoader:bone(i):name(), "red", 3)
	end
end
]]
