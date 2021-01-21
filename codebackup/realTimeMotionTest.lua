require("config")
require("module")
require("common")
require("RigidBodyWin/subRoutines/Constraints")

config_jeongho = {
	"../Resource/jae/social_p1/social_p1.wrl",
	"../Resource/jae/social_p1/social_p1_copy.wrl.dof",
	{
		{'LeftKnee', 'LeftToes', vector3(0, 0, 0), reversed=false},
		{'RightKnee', 'RightToes', vector3(0, 0, 0), reversed=false}
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
		local lknee = loader:getBoneByName(conInfo[kneeInfo])
		mEffectors(i):init(loader:getBoneByName(conInfo[kneeInfo+1]), conInfo[kneeInfo+2])
	end
	out.solver = MotionUtil.createFullbodyIk_MotionDOF_MultiTarget_lbfgs(loader.dofInfo)
	return out
end

function ctor()
	--camera init
	RE.viewpoint().vpos:set(0, 238, 334)
	RE.viewpoint().vat:set(9, 109, 15)
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
		mMotionDOF:matView():set(i, 1, mMotionDOF:matView()(i,1)+(config.initialHeight or 0))
	end
	
	mSkin = RE.createVRMLskin(mLoader, false)
	mSkin:scale(1,1,1)
	mSkin:setTranslation(0,0,0)

	mPose = vectorn()
	mPose:assign(mMotionDOF:row(0))
	mLoader:setPoseDOF(mPose)
	mSkin:setPoseDOF(mPose)

	mSolverInfo = createIKsolver(mLoader, config[3])
	mEffectors = mSolverInfo.effectors
	numCon = mSolverInfo.numCon
	mIK = mSolverInfo.solver

	footPos = vector3N(numCon)

	local originalPos = {}
	for i=0, numCon-1 do
		local opos = mEffectors(i).bone:getFrame():toGlobalPos(mEffectors(i).localpos)
		originalPos[i+1] = opos*config.skinScale
	end
	table.insert(originalPos, mLoader:bone(1):getFrame().translation*config.skinScale)
	mCON = Constraints(unpack(originalPos))
	mCON:connect(limbik)
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
		footPos(i):assign(originalPos)
	end
	mIK:_effectorUpdated()

	mIK:IKsolve(mPose, footPos)
	mSkin:setPoseDOF(mPose)
	
end

function onCallback(w, userData)
end

--elapsedTime=0
function frameMove(fElapsedTime)
--	elapsedTime = elapsedTime + fElapsedTime
--	local currFrame = math.round(elapsedTime*120)
--
--	mLoader:setPoseDOF(mMotionDOF:row(currFrame))
--	mSkin:setPoseDOF(mMotionDOF:row(currFrame))
end

function dtor()
end

function handleRendererEvent(ev, button, x,y) 
	if mCON then
		return mCON:handleRendererEvent(ev, button, x,y)
	end
	return 0
end
