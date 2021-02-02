require("config")
require("module")
require("common")
require("RigidBodyWin/subRoutines/Constraints")
require("RigidBodyWin/retargetting/kinectTracker")

config_jeongho = {
	"../Resource/jae/social_p1/social_p1.wrl",
	"../Resource/jae/social_p1/social_p1_copy.wrl.dof",
	{
		{'Hips', 'Hips', vector3(0, 0, 0), reversed=false},
		{'Neck', 'Head', vector3(0, 0, 0), reversed=false},
		{'LeftElbow', 'LeftWrist', vector3(0, 0, 0), reversed=false},
		{'RightElbow', 'RightWrist', vector3(0, 0, 0), reversed=false},
		{'LeftKnee', 'LeftAnkle', vector3(0, 0, 0), reversed=false},
		{'RightKnee', 'RightAnkle', vector3(0, 0, 0), reversed=false}
	},
	skinScale=1
}

config = config_jeongho

userJointNames = {
	"JOINT_WAIST",			-- 3
	"JOINT_TORSO",			-- 2
	"JOINT_NECK",			-- 1
	"JOINT_HEAD",			-- 0

	"JOINT_LEFT_COLLAR",	-- 4
	"JOINT_LEFT_SHOULDER",	-- 5
	"JOINT_LEFT_ELBOW",		-- 6
	"JOINT_LEFT_WRIST",		-- 7
	"JOINT_LEFT_HAND",		-- 8
	"JOINT_LEFT_FINGERTIP",	-- 9

	"JOINT_RIGHT_COLLAR",	-- 10
	"JOINT_RIGHT_SHOULDER",	-- 11
	"JOINT_RIGHT_ELBOW",	-- 12
	"JOINT_RIGHT_WRIST",	-- 13
	"JOINT_RIGHT_HAND",		-- 14
	"JOINT_RIGHT_FINGERTIP",-- 15

	"JOINT_LEFT_HIP",		-- 16
	"JOINT_LEFT_KNEE",		-- 17
	"JOINT_LEFT_ANKLE",		-- 18
	"JOINT_LEFT_FOOT",		-- 19

	"JOINT_RIGHT_HIP",		-- 20
	"JOINT_RIGHT_KNEE",		-- 21
	"JOINT_RIGHT_ANKLE",	-- 22
	"JOINT_RIGHT_FOOT",		-- 23
}

--[[
function createIKsolver(loader, config)
	local out = {}
	local mEffectors = MotionUtil.Effectors()
	local numCon = #config
	mEffectors:resize(numCon)
	out.effectors = mEffectors
	out.numCon = numCon

	for i=0, numCon-1 do
		local conInfo = config[i+1] 
		local kneeInfo = 1
		mEffectors(i):init(loader:getBoneByName(conInfo[kneeInfo+1]), conInfo[kneeInfo+2])
	end
	out.solver = MotionUtil.createFullbodyIk_MotionDOF_MultiTarget_lbfgs(loader.dofInfo)
	return out
end
]]

useDevice = true 
--useDevice = false 

tracking = false

function ctor()
	--mEventReceiver=EVR()

	this:create("Button", "Check Viewpoint", "Check Viewpoint")
	this:create("Check_Button", "Tracking", "Tracking")
	this:widget(0):checkButtonValue(false)
	this:widget(0):buttonShortcut("t")
	this:create("Check_Button", "drawAxes", "drawAxes")
	this:widget(0):checkButtonValue(false)
	this:updateLayout()

	--camera init
	RE.viewpoint().vpos:set(368, 210, 26)
	RE.viewpoint().vat:set(6, 126, -2)
	RE.viewpoint():update()

	mLoader=MainLib.VRMLloader(config[1])
	mLoader:printHierarchy()
--[[
	for i=1, mLoader:numBone()-1 do
		if mLoader:VRMLbone(i):numChannels()==0 then
			mLoader:removeAllRedundantBones()
			--mLoader:removeBone(mLoader:VRMLbone(i))
			--mLoader:export(config[1]..'_removed_fixed.wrl')
			break
		end
	end
	mLoader:_initDOFinfo()
]]
	mMotionDOFcontainer = MotionDOFcontainer(mLoader.dofInfo, config[2])
	mMotionDOF = mMotionDOFcontainer.mot
	 
	for i=0, mMotionDOF:rows()-1 do
		mMotionDOF:matView():set(i, 1, mMotionDOF:matView()(i,1)*100)
	end
	
	mSkin = RE.createVRMLskin(mLoader, false)
	local s=config.skinScale
	mSkin:scale(s,s,s)
	--mSkin:setTranslation(0, 108, 0)
	--drawLoaderJoints()

--	mSkin:applyMotionDOF(mMotionDOF)
--	mSkin:setFrameTime(1/120)
--
--	RE.motionPanel():motionWin():detachSkin(mSkin)
--	RE.motionPanel():motionWin():addSkin(mSkin)

--	mPose = vectorn()
--	mPose:assign(mMotionDOF:row(0))
--	mSkin:setPoseDOF(mPose)
	userPose = Pose()
	userPose:init(mLoader:numRotJoint(), mLoader:numTransJoint())
	userPose:identity()	
	mSkin:_setPose(userPose, mLoader)

--	mPose = Pose()
--	mLoader:getPose(mPose)
--	mSkin:_setPose(mPose, mLoader)

--[[
	mSolverInfo = createIKsolver(mLoader, config[3])
	mEffectors = mSolverInfo.effectors
	numCon = mSolverInfo.numCon
	mIK = mSolverInfo.solver

	--footPos = vector3N(numCon)
	eePos = vector3N(numCon)

	mLoader:setPoseDOF(mPose)
	local originalPos = {}
	for i=0, numCon-1 do
		local opos = mEffectors(i).bone:getFrame():toGlobalPos(mEffectors(i).localpos)
		originalPos[i+1] = opos*config.skinScale
	end
	table.insert(originalPos, mLoader:bone(1):getFrame().translation*config.skinScale)
	mCON = Constraints(unpack(originalPos))
	mCON:connect(limbik)
]]
	--mTimeline=Timeline("Timeline", 10000)
	
	if useDevice then
		mNuiListener = NuiListener()
		mNuiListener:startNuitrack()
	end

	--dbg.console()
end

function frameMove(fElapsedTime)
	if tracking then
		mNuiListener:waitUpdate()
--		drawUserJoints()
--		drawLoaderJoints()
		getUserPose()
		--conposUpdateFromUser()
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
	elseif w:id()=="drawAxes" then
		if w:checkButtonValue() then
			dbg.namedDraw("Axes", transf(quater(1,0,0,0), vector3(0,0,100)), "axes")
		else
			dbg.erase("Axes", "axes")
		end
	end
end

function getUserPose()
	local pose = Pose()
	pose:init(mLoader:numRotJoint(), mLoader:numTransJoint())
	pose:identity()	
	local rootTransf = getUserRootTransf()
	pose:setRootTransformation(rootTransf)
	local rots = quaterN() rots:pushBack(getJointRotByName("JOINT_WAIST")) 
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_WAIST"),getJointRotByName("JOINT_TORSO")))
	rots:pushBack(quater(1,0,0,0))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_TORSO"),getJointRotByName("JOINT_NECK")))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_NECK"),getJointRotByName("JOINT_HEAD")))
	
	--rots:pushBack(quater(1,0,0,0))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_NECK"),getJointRotByName("JOINT_LEFT_COLLAR")))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_LEFT_COLLAR"),getJointRotByName("JOINT_LEFT_SHOULDER")))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_LEFT_SHOULDER"),getJointRotByName("JOINT_LEFT_ELBOW")))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_LEFT_ELBOW"),getJointRotByName("JOINT_LEFT_WRIST")))

	pose.rotations:assign(rots)
	userPose = pose	
	mSkin:_setPose(userPose, mLoader)--setPose안쓴데_setPose쓴데
end

function getUserRootTransf()--todo: y값 조정
	local rootRot = getJointRotByName("JOINT_WAIST")
	local rootPos = getJointPosByName("JOINT_WAIST")
	return transf(rootRot, rootPos)
end

function getUserJointLocalRot(preRot, curRot)
	curRot:toLocal(preRot, curRot)
	return curRot
end

function drawUserJoints()
	for i=0, 23 do
		if not(i==9 or i==15 or i==19 or i==23) then 
		--if (i==3 or i==7 or i==13 or i==18 or i==22) then 
			--dbg.namedDraw("Sphere", getJointPos(i)+vector3(0,108,0), "ball"..i, "red", 3)
			--dbg.namedDraw("Sphere", getJointPosByName(userJointNames[i+1])+vector3(0,108,0), userJointNames[i], "red", 3)
			dbg.draw("Axes", transf(getJointRot(i), getJointPos(i)+vector3(0,108,0)), "axesll"..i)
			--dbg.namedDraw("Sphere", getJointPos(i) - getDistance(), i, "red", 3)
			dbg.draw("Sphere", getJointPos(i)+vector3(0,108,0), "ball2l"..i, "blue", 3)
		end
	end
end

function drawLoaderJoints()
	for i=1, mLoader:numBone()-1 do
		dbg.namedDraw("Axes", mLoader:bone(i):getFrame(), "axes"..i)
		--dbg.namedDraw("Axes", mLoader:bone(i):getFrame()*transf(quater(1,0,0,0), vector3(0,108,0)), "axes"..i)
		--dbg.namedDraw("Sphere", mLoader:bone(i):getFrame().translation, mLoader:bone(i):name(), "red", 3)
	end
end

function getJointPosByName(name)
	local pos = vector3()
	pos.x = mNuiListener:getJointPosByName(name,0)/10
	pos.y = mNuiListener:getJointPosByName(name,1)/10
	pos.z = mNuiListener:getJointPosByName(name,2)/10
	return pos
end

function getJointRotByName(name)
	local mat = matrix4()
	local rot = vectorn(9)
	local quat = quater()
	for i=0, 8 do
		rot:set(i, mNuiListener:getJointRotByName(name,i))
	end
	mat:setValue(rot(0),rot(1),rot(2),0,rot(3),rot(4),rot(5),0,rot(6),rot(7),rot(8),0,0,0,0,1)
	quat:setRotation(mat)
	return quat 
end

function getJointPos(idx)
	local pos = vector3()
	pos.x = mNuiListener:getJointPos(idx,0)/10
	pos.y = mNuiListener:getJointPos(idx,1)/10
	pos.z = mNuiListener:getJointPos(idx,2)/10
	return pos
end

function getJointRot(idx)
	local mat = matrix4()
	local rot = vectorn(9)
	local quat = quater()
	for i=0, 8 do
		rot:set(i, mNuiListener:getJointRot(idx,i))
	end
	mat:setValue(rot(0),rot(1),rot(2),0,rot(3),rot(4),rot(5),0,rot(6),rot(7),rot(8),0,0,0,0,1)
	quat:setRotation(mat)
	return quat 
end

function dtor()
end

--[[
function limbik()
	mPose:assign(mMotionDOF:row(0))
	mLoader:setPoseDOF(mPose)
	local COM = mCON.conPos(2)/config.skinScale
	mIK:_changeNumEffectors(numCon)
	mIK:_changeNumConstraints(0)

	for i=0, numCon-1 do
		mIK:_setEffector(i, mEffectors(i).bone, mEffectors(i).localpos)
		local originalPos = mCON.conPos(i)/config.skinScale
		eePos(i):assign(originalPos)
	end
	mIK:_effectorUpdated()

	mIK:IKsolve(mPose, eePos)
	mSkin:setPoseDOF(mPose)
end
]]

--[[
function getDistance()
	local userRoot = getJointPos(3)
	local loaderRoot = mCON.conPos(mCON.conPos:size()-1)
	local distance = vector3()
	distance = userRoot-loaderRoot
	return distance 
end

function adjustEE(ui, li)
	local userEE = getJointPos(ui)-getDistance()
	local loaderEE = mCON.conPos(li)
	local distance = vector3()
	--distance = userEE-loaderEE
	distance = loaderEE-userEE
	return distance
end

function conposUpdateFromUser()
	mCON.conPos(0):assign(getJointPos(0)-getDistance())
	mCON.conPos(1):assign(getJointPos(7)-getDistance())
	mCON.conPos(2):assign(getJointPos(13)-getDistance())
	mCON.conPos(3):assign(getJointPos(18)-getDistance())
	mCON.conPos(4):assign(getJointPos(22)-getDistance())
	limbik()
	mCON:drawConstraints()
end
]]
--[[
function handleRendererEvent(ev, button, x,y) 
	if mCON then
		return mCON:handleRendererEvent(ev, button, x,y)
	end
	return 0
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

function EVR:onFrameChanged(win, iframe)
end
]]

--[[
Timeline=LUAclass(LuaAnimationObject)
function Timeline:__init(label, totalTime)
	self.totalTime=totalTime
	self:attachTimer(1/30, totalTime)		
	RE.renderer():addFrameMoveObject(self)
	RE.motionPanel():motionWin():addSkin(self)
end
]]
