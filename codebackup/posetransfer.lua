require("config")
package.projectPath='../Samples/classification/'
package.path=package.path..";../Samples/classification/lua/?.lua" --;"..package.path
require("common")
require("module")

require("RigidBodyWin/subRoutines/Constraints")
require("subRoutines/AnimOgreEntity")
PoseTransfer2=require("subRoutines/PoseTransfer2")

skinScale=100 -- meter / cm
kist={
    --origin_model="../Resource/gangrae/test.wrl",
    --target_model="../Resource/gangrae/kist_T_T.wrl",
    --motion="../Resource/gangrae/kist_motion.dof",
	origin_model="../Resource/motion/locomotion_hyunwoo/hyunwoo_lowdof_T.wrl",
	--target_model="../Resource/motion/dance1_M_1dof/dance1_M_1dof.wrl",
	target_model="../Resource/motion/social_p1/social_p1.wrl",
	motion="../Resource/motion/locomotion_hyunwoo/hyunwoo_lowdof_T_locomotion_hl.dof",
    motion2="../Resource/gangrae/kist_motion_retarget.dof",
}

vocaKist={
	chest='spine1',
	left_heel='R_Ankle',
	left_knee='R_leg2',
	left_hip='R_leg1',
	right_heel='L_Ankle',
	right_knee='L_leg2',
	right_hip='L_leg1',
	left_shoulder='R_upperArm',
	left_elbow='R_elbow',
	right_shoulder='L_upperArm',
	right_elbow='L_elbow',
	neck='neek',
	hips='Root'
}

vocaHyunwoo={
	chest='Chest',
	left_heel='LeftAnkle',
	left_knee='LeftKnee',
	left_hip='LeftHip',
	right_heel='RightAnkle',
	right_knee='RightKnee',
	right_hip='RightHip',
	left_shoulder='LeftShoulder',
	left_elbow='LeftElbow',
	right_shoulder='RightShoulder',
	right_elbow='RightElbow',
	neck='Neck',
	hips='Hips'
}

--vocaDance={
--	chest='Chest',
--	left_heel='LeftAnkle',
--	left_knee='LeftKnee',
--	left_hip='LeftHip',
--	right_heel='RightAnkle',
--	right_knee='RightKnee',
--	right_hip='RightHip',
--	left_shoulder='LeftShoulder',
--	left_elbow='LeftElbow',
--	right_shoulder='RightShoulder',
--	right_elbow='RightElbow',
--	neck='Neck',
--	hips='Hips'
--}

--function getConvInfo(convInfoT)
--	local convInfo = TStrings()
--	for i=1, mOrigLoader:numBone() do
--		convInfo:pushBack(convInfoT[i])	
--	end
--	return convInfo
--end

function ctor()
	mEventReceiver=EVR()
	this:create("Button", "pose transfer", "pose transfer")
	this:create("Button", "dbg console", "dbg console")
	this:updateLayout()

	mOrigLoader=MainLib.VRMLloader(kist.origin_model)
    mTargetLoader=MainLib.VRMLloader(kist.target_model)
    
    mOrigSkin=RE.createVRMLskin(mOrigLoader, false)
    mTargetSkin=RE.createVRMLskin(mTargetLoader, false)
	mTargetSkin:setTranslation(100,0,0)
    mOrigSkin:scale(skinScale,skinScale,skinScale)
    mTargetSkin:scale(1,1,1)
    mOrigSkin:setMaterial('red')
    mTargetSkin:setMaterial('blue')
    
	mMotionDOFcontainer=MotionDOFcontainer(mOrigLoader.dofInfo, kist.motion)
	mMotionDOF=mMotionDOFcontainer.mot
    
	mOrigLoader:setVoca(vocaHyunwoo)
	mTargetLoader:setVoca(vocaHyunwoo)

--	convInfoA = getConvInfo(vocaHyunwoo)
--	convInfoB = getConvInfo(vocaDance) 

    initialPose_origin=mMotionDOF:row(0)
    initialPose_origin:setVec3(0,vector3(0,0,0))   
    initialPose_target=vectorn()
    mTargetLoader:getPoseDOF(initialPose_target)
    mOrigLoader:setPoseDOF(initialPose_origin)

	local Tpose=Pose()
	mOrigLoader:getPose(Tpose)
	mOrigSkin:setPoseDOF(initialPose_origin)
	mOrigSkin:_setPose(Tpose, mOrigLoader)
    mOrigSkin:applyMotionDOF(mMotionDOF)
    
    RE.motionPanel():motionWin():addSkin(mOrigSkin)

    --PT=PoseTransfer2(mOrigLoader,mTargetLoader,convInfoA,convInfoB)
    PT=PoseTransfer2(mOrigLoader,mTargetLoader)
end

function dtor()
end

function onCallback(w, userData)
	if w:id()=='pose transfer' then
       
        mOrigLoader:setPoseDOF(initialPose_origin)
        mTargetLoader:setPoseDOF(initialPose_target)
        
        local M=require("RigidBodyWin/retargetting/module/retarget_common")
	    M.gotoTpose(mOrigLoader)
	    M.gotoTpose(mTargetLoader)
	    
        local Tpose=Pose()
	    mOrigLoader:getPose(Tpose)
	    mOrigSkin:_setPose(Tpose, mOrigLoader)
	    mTargetLoader:getPose(Tpose)
	    mTargetSkin:_setPose(Tpose, mOrigLoader)

        --PT=PoseTransfer2(mOrigLoader,mTargetLoader,convInfoA,convInfoB)
        PT=PoseTransfer2(mOrigLoader,mTargetLoader)

	elseif w:id()=='dbg console' then
        dbg.console() 
    end

end

if EventReceiver then
	EVR=LUAclass(EventReceiver)
	function EVR:__init(graph)
		self.currFrame=0
		self.cameraInfo={}
	end
end

function EVR:onFrameChanged(win, iframe)
    local mPose0=Pose()
    local mPose=vectorn()
    mOrigLoader:setPoseDOF(mMotionDOF:row(iframe))
    mOrigSkin:setPoseDOF(mMotionDOF:row(iframe))
    mOrigLoader:getPoseDOF(mPose) 

	local vec = mPose:toVector3(0)
	vec = vec*100
	mPose:setVec3(0,vec)

    PT:setTargetSkeleton(mPose)
    
    local poseOrig=Pose()
    mTargetLoader:getPose(poseOrig)
    mTargetSkin:_setPose(poseOrig, mTargetLoader);

end

function frameMove(fElapsedTime)
end
