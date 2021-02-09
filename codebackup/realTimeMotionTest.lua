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

	"JOINT_RIGHT_COLLAR",	-- 10
	"JOINT_RIGHT_SHOULDER",	-- 11
	"JOINT_RIGHT_ELBOW",	-- 12
	"JOINT_RIGHT_WRIST",	-- 13
	"JOINT_RIGHT_HAND",		-- 14

	"JOINT_LEFT_HIP",		-- 16
	"JOINT_LEFT_KNEE",		-- 17
	"JOINT_LEFT_ANKLE",		-- 18

	"JOINT_RIGHT_HIP",		-- 20
	"JOINT_RIGHT_KNEE",		-- 21
	"JOINT_RIGHT_ANKLE",	-- 22
}

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
	this:widget(0):buttonShortcut("d")
	this:updateLayout()

	RE.viewpoint().vpos:set(368, 210, 26)
	RE.viewpoint().vat:set(6, 126, -2)
	RE.viewpoint():update()

	mLoader=MainLib.VRMLloader(config[1])
	mLoader:printHierarchy()

	mMotionDOFcontainer = MotionDOFcontainer(mLoader.dofInfo, config[2])
	mMotionDOF = mMotionDOFcontainer.mot
	 
	for i=0, mMotionDOF:rows()-1 do
		mMotionDOF:matView():set(i, 1, mMotionDOF:matView()(i,1)*100)
	end
	
	mSkin = RE.createVRMLskin(mLoader, false)
	local s=config.skinScale
	mSkin:scale(s,s,s)

	mSkin:applyMotionDOF(mMotionDOF)
	mSkin:setFrameTime(1/120)

	RE.motionPanel():motionWin():detachSkin(mSkin)
	RE.motionPanel():motionWin():addSkin(mSkin)

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

	if useDevice then
		mNuiListener = NuiListener()
		mNuiListener:startNuitrack()
	end

	--dbg.console()
end

function frameMove(fElapsedTime)
	if tracking then
		mNuiListener:waitUpdate()
		--drawUserJoints()
		--drawLoaderJoints()
		getUserPose()
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

function setRotJoints()
	local rots = quaterN() 
	rots:pushBack(getJointRotByName("JOINT_WAIST")) 
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_WAIST"),getJointRotByName("JOINT_TORSO")))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_TORSO"),getJointRotByName("JOINT_LEFT_COLLAR")))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_LEFT_COLLAR"),getJointRotByName("JOINT_NECK")))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_NECK"),getJointRotByName("JOINT_HEAD")))

	rots:pushBack(quater(1,0,0,0))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_LEFT_COLLAR"),getJointRotByName("JOINT_LEFT_SHOULDER")))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_LEFT_SHOULDER"),getJointRotByName("JOINT_LEFT_ELBOW")))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_LEFT_ELBOW"),getJointRotByName("JOINT_LEFT_WRIST")))

	rots:pushBack(quater(1,0,0,0))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_RIGHT_COLLAR"),getJointRotByName("JOINT_RIGHT_SHOULDER")))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_RIGHT_SHOULDER"),getJointRotByName("JOINT_RIGHT_ELBOW")))
	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_RIGHT_ELBOW"),getJointRotByName("JOINT_RIGHT_WRIST")))

--	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_WAIST"),getJointRotByName("JOINT_LEFT_HIP")))
--	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_LEFT_HIP"),getJointRotByName("JOINT_LEFT_KNEE")))
--	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_LEFT_KNEE"),getJointRotByName("JOINT_LEFT_ANKLE")))
--
--	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_WAIST"),getJointRotByName("JOINT_RIGHT_HIP")))
--	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_RIGHT_HIP"),getJointRotByName("JOINT_RIGHT_KNEE")))
--	rots:pushBack(getUserJointLocalRot(getJointRotByName("JOINT_RIGHT_KNEE"),getJointRotByName("JOINT_RIGHT_ANKLE")))

	return rots
end

function getUserPose()
	local pose = Pose()
	pose:init(mLoader:numRotJoint(), mLoader:numTransJoint())
	pose:identity()	

	pose:setRootTransformation(getUserRootTransf())
	pose.rotations:assign(setRotJoints())

	userPose = pose	
	mSkin:_setPose(userPose, mLoader)
end

function getUserRootTransf()--todo: y값 조정
	local rootRot = getJointRotByName("JOINT_WAIST")
	local rootPos = getJointPosByName("JOINT_WAIST")
	return transf(rootRot, rootPos+vector3(0,128,0))
end

function getUserJointLocalRot(preRot, curRot)
	curRot:toLocal(preRot, curRot)
	return curRot
end

function drawUserJoints()
	for i=0, 23 do
		if not(i==9 or i==15 or i==19 or i==23) then 
			--dbg.namedDraw("Sphere", getJointPos(i)+vector3(0,108,0), "ball"..i, "red", 3)
			--dbg.namedDraw("Sphere", getJointPosByName(userJointNames[i+1])+vector3(0,108,0), userJointNames[i+1], "red", 3)
			--dbg.draw("Sphere", getJointPos(i)+vector3(0,108,0), "ball2l"..i, "blue", 3)
			dbg.draw("Axes", transf(getJointRot(i), getJointPos(i)+vector3(0,108,0)), "axesll"..i)
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
	pos.z = -mNuiListener:getJointPosByName(name,2)/10
	return pos
end

function getJointPos(idx)
	local pos = vector3()
	pos.x = mNuiListener:getJointPos(idx,0)/10
	pos.y = mNuiListener:getJointPos(idx,1)/10
	pos.z = -mNuiListener:getJointPos(idx,2)/10
	return pos
end

function getJointRotByName(name)
	local mat = matrix4()
	local rot = vectorn(9)
	local quat = quater()
	for i=0, 8 do
		rot:set(i, mNuiListener:getJointRotByName(name,i))
	end

	mat:setValue(rot(0),rot(3),rot(6),0,rot(1),rot(4),rot(7),0,rot(2),rot(5),rot(8),0,0,0,0,1)

	quat:setRotation(mat)
	quat:setValue(quat.w, quat.x, quat.y, -quat.z)
	return quat 
end

function getJointRot(idx)
	local mat = matrix4()
	local rot = vectorn(9)
	local quat = quater()
	for i=0, 8 do
		rot:set(i, mNuiListener:getJointRot(idx,i))
	end
	mat:setValue(rot(0),rot(3),rot(6),0,rot(1),rot(4),rot(7),0,rot(2),rot(5),rot(8),0,0,0,0,1)

	quat:setRotation(mat)
	quat:setValue(quat.w, quat.x, quat.y, -quat.z)
	return quat 
end

function dtor()
end

--[[
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
