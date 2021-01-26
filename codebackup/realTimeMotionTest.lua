require("config")
require("module")
require("common")
require("RigidBodyWin/subRoutines/Constraints")
require("RigidBodyWin/retargetting/kinectTracker")

config_jeongho = {
	"../Resource/jae/social_p1/social_p1.wrl",
	"../Resource/jae/social_p1/social_p1_copy.wrl.dof",
	{
--		{'Hips', 'Hips', vector3(0, 0, 0), reversed=false},
		{'Neck', 'Head', vector3(0, 0, 0), reversed=false},
		{'LeftElbow', 'LeftWrist', vector3(0, 0, 0), reversed=false},
		{'RightElbow', 'RightWrist', vector3(0, 0, 0), reversed=false},
		{'LeftKnee', 'LeftAnkle', vector3(0, 0, 0), reversed=false},
		{'RightKnee', 'RightAnkle', vector3(0, 0, 0), reversed=false}
	},
	skinScale=1
}

config = config_jeongho

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

--useGUI = false 
--useDevice = true 
useGUI = true	 
useDevice = false 

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

	for i=1, mLoader:numBone()-1 do
		if mLoader:VRMLbone(i):numChannels()==0 then
			mLoader:removeAllRedundantBones()
			--mLoader:removeBone(mLoader:VRMLbone(i))
			--mLoader:export(config[1]..'_removed_fixed.wrl')
			break
		end
	end
	mLoader:_initDOFinfo()

	mMotionDOFcontainer = MotionDOFcontainer(mLoader.dofInfo, config[2])
	mMotionDOF = mMotionDOFcontainer.mot
	 
	-- in meter scale
	for i=0, mMotionDOF:rows()-1 do
		mMotionDOF:matView():set(i, 1, mMotionDOF:matView()(i,1)*100)
	end
	
	mSkin = RE.createVRMLskin(mLoader, false)
	local s=config.skinScale
	mSkin:scale(s,s,s)

--	mSkin:applyMotionDOF(mMotionDOF)
--	mSkin:setFrameTime(1/120)
--
--	RE.motionPanel():motionWin():detachSkin(mSkin)
--	RE.motionPanel():motionWin():addSkin(mSkin)

	mPose = vectorn()
	mPose:assign(mMotionDOF:row(918))
	mSkin:setPoseDOF(mPose)
	--mLoader:setPoseDOF(mPose)

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

	if useDevice then
		mNuiListener = NuiListener()
		mNuiListener:startNuitrack()
	end
	--mTimeline=Timeline("Timeline", 10000)
end

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

function drawUserJoints()--ToDo: 실제 그려지는 ball은 19개. collar가 문제인듯.
	for i=0, 23 do
		if not(i==9 or i==15 or i==19 or i==23) then
		--if (i==3 or i==7 or i==13 or i==18 or i==22) then
		--if (i==0 or i==3 or i==7 or i==13) then
			dbg.draw("Sphere", getJointPos(i) - getDistance(), "ball"..i, "red", 3)
			--dbg.namedDraw("Sphere", getJointPos(i) - getDistance(), i, "red", 3)
			--dbg.draw("Sphere", getJointPos(i), "ball2l"..i, "blue", 3)
		end
	end
end

function drawLoaderJoints()
	for i=1, mLoader:numBone()-1 do
		dbg.namedDraw("Sphere", mLoader:bone(i):getFrame().translation, mLoader:bone(i):name(), "red", 3)
	end
end

function getJointPos(idx)
	local pos = vector3()
	pos.x = -mNuiListener:getJointRealCoords(idx,2)/10
	pos.y = mNuiListener:getJointRealCoords(idx,1)/10
	pos.z = -mNuiListener:getJointRealCoords(idx,0)/10
	return pos
end

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
--	mCON.conPos(0):assign(getJointPos(0)-getDistance())
--	mCON.conPos(1):assign(getJointPos(7)-getDistance())
--	mCON.conPos(2):assign(getJointPos(13)-getDistance())
--	mCON.conPos(3):assign(getJointPos(18)-getDistance())
--	mCON.conPos(4):assign(getJointPos(22)-getDistance())

	mCON.conPos(0):assign(getJointPos(0)-getDistance()+adjustEE(0, 0))
	mCON.conPos(1):assign(getJointPos(7)-getDistance()+adjustEE(7, 1))
	mCON.conPos(2):assign(getJointPos(13)-getDistance()+adjustEE(13, 2))
	mCON.conPos(3):assign(getJointPos(18)-getDistance()+adjustEE(18, 3))
	mCON.conPos(4):assign(getJointPos(22)-getDistance()+adjustEE(22, 4))

	limbik()
	mCON:drawConstraints()
end
q = 0
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

function frameMove(fElapsedTime)
	if tracking then
		mNuiListener:waitUpdate()
		drawUserJoints()
		conposUpdateFromUser()
	end
end

function dtor()
end

function handleRendererEvent(ev, button, x,y) 
	if mCON then
		return mCON:handleRendererEvent(ev, button, x,y)
	end
	return 0
end

--if EventReceiver then
--	--class 'EVR'(EventReceiver)
--	EVR=LUAclass(EventReceiver)
--	function EVR:__init(graph)
--		--EventReceiver.__init(self)
--		self.currFrame=0
--		self.cameraInfo={}
--	end
--end
--
--function EVR:onFrameChanged(win, iframe)
----	if mKinectTracker.tracking then
----		mKinectTracker:drawUserJoints()
----	end
--end
--
--Timeline=LUAclass(LuaAnimationObject)
--function Timeline:__init(label, totalTime)
--	self.totalTime=totalTime
--	self:attachTimer(1/30, totalTime)		
--	RE.renderer():addFrameMoveObject(self)
--	RE.motionPanel():motionWin():addSkin(self)
--end
