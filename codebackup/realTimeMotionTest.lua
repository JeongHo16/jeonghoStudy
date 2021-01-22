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
--		{'Neck', 'Head', vector3(0, 0, 0), reversed=false},
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

function ctor()
	--mEventReceiver=EVR()

	this:create("Button", "Check Viewpoint", "Check Viewpoint")
	this:create("Check_Button", "Tracking", "Tracking")
	this:widget(0):checkButtonValue(false)
	this:widget(0):buttonShortcut("t")

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

	mPose = vectorn()
	mPose:assign(mMotionDOF:row(0))
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

	mNuiListener = nuiListener()
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

function onCallback(w, userData)
	if w:id()=="Check Viewpoint" then
		print(RE.viewpoint().vpos)
		print(RE.viewpoint().vat)
	elseif w:id()=="Tracking" then
	end
end

function frameMove(fElapsedTime)
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
----		mKinectTracker:drawSkeletonJoints()
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
