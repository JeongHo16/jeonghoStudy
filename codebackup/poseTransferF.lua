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
    --source_model="../Resource/gangrae/test.wrl",
    --target_model="../Resource/gangrae/kist_T_T.wrl",
    --motion="../Resource/gangrae/kist_motion.dof",
	--source_model="../Resource/motion/locomotion_hyunwoo/hyunwoo_lowdof_T.wrl",
	--target_model="../Resource/motion/dance1_M_1dof/dance1_M_1dof.wrl",
	target_model="../Resource/motion/dance1_M_1dof/dance1_M_1dof.wrl",
	--target_model="../Resource/motion/locomotion_hyunwoo/hyunwoo_lowdof_T.wrl",
	source_model="../Resource/motion/social_p1/social_p1.wrl",
	--motion="../Resource/motion/locomotion_hyunwoo/hyunwoo_lowdof_T_locomotion_hl.dof",
	--motion="../Resource/motion/dance1_M_1dof/dance1_M_1dof_social_p2_edited_handshake.dof",
	motion="../Resource/motion/social_p1/social_p1_copy.wrl.dof",
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

function ctor()
	mEventReceiver=EVR()
	this:create("Button", "pose transfer", "pose transfer")
	this:create("Button", "dbg console", "dbg console")
	this:updateLayout()

	mSourceLoader=MainLib.VRMLloader(kist.source_model)
    mTargetLoader=MainLib.VRMLloader(kist.target_model)
    
    mSourceSkin=RE.createVRMLskin(mSourceLoader, false)
    mTargetSkin=RE.createVRMLskin(mTargetLoader, false)
	
    mTargetSkin:scale(skinScale,skinScale,skinScale)
    mSourceSkin:scale(1,1,1)
	mTargetSkin:setTranslation(100,0,0)

    mSourceSkin:setMaterial('red')
    mTargetSkin:setMaterial('blue')
    
	mMotionDOFcontainer=MotionDOFcontainer(mSourceLoader.dofInfo, kist.motion)
	mMotionDOF=mMotionDOFcontainer.mot
    
	mSourceLoader:setVoca(vocaHyunwoo)
	mTargetLoader:setVoca(vocaHyunwoo)

	convInfoA = getConvInfo(vocaHyunwoo)
	convInfoB = getConvInfo(vocaHyunwoo) 

	mSourceLoader:updateInitialBone()
	mTargetLoader:updateInitialBone()
	
	initPose_origin = vectorn()
	--initPose_origin=mMotionDOF:row(0)
	--initPose_origin:setVec3(0,vector3(0,0,0))

	mSourceLoader:getPoseDOF(initPose_origin)

    initPose_target=vectorn()
    mTargetLoader:getPoseDOF(initPose_target)

    mSourceSkin:applyMotionDOF(mMotionDOF)
    RE.motionPanel():motionWin():addSkin(mSourceSkin)

    PT=PoseTransfer2(mSourceLoader,mTargetLoader,convInfoA,convInfoB)
    --PT=PoseTransfer2(mSourceLoader,mTargetLoader)
end

function getConvInfo(convInfoT)
	local convInfo = TStrings()
	for k,v in pairs(convInfoT) do
		convInfo:pushBack(v)	
	end
	return convInfo
end

function dtor()
end

function onCallback(w, userData)
	if w:id()=='pose transfer' then

        mSourceLoader:setPoseDOF(initPose_origin)
        mTargetLoader:setPoseDOF(initPose_target)
        
        local M=require("RigidBodyWin/retargetting/module/retarget_common")
	    M.gotoTpose(mSourceLoader)
	    M.gotoTpose(mTargetLoader)
	    
        local Tpose=Pose()
	    mSourceLoader:getPose(Tpose)
	    mSourceSkin:_setPose(Tpose, mSourceLoader)
	    mTargetLoader:getPose(Tpose)
	    mTargetSkin:_setPose(Tpose, mSourceLoader)

        PT=PoseTransfer2(mSourceLoader,mTargetLoader,convInfoA,convInfoB)
        --PT=PoseTransfer2(mSourceLoader,mTargetLoader)
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
    mSourceLoader:setPoseDOF(mMotionDOF:row(iframe))
    mSourceSkin:setPoseDOF(mMotionDOF:row(iframe))
    mSourceLoader:getPoseDOF(mPose) 

--	local vec = mPose:toVector3(0)
--	vec = vec*100
--	mPose:setVec3(0,vec)

    PT:setTargetSkeleton(mPose)
    
    local poseOrig=Pose()
    mTargetLoader:getPose(poseOrig)
    mTargetSkin:_setPose(poseOrig, mTargetLoader);
end

function frameMove(fElapsedTime)
end
