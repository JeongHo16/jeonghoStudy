require("config")
require("module")
require("moduleIK")
require("common")
require("RigidBodyWin/subRoutines/MultiConstraints")
require("RigidBodyWin/subRoutines/Constraints")

require("control/SDRE")
package.projectPath='../Samples/classification/'
package.path=package.path..";../Samples/classification/lua/?.lua" --;"..package.path
require("RigidBodyWin/retargetting/kinectModule")

--kinect_datafile='sack.data'
--kinect_datafile='highfive.data'
kinect_datafile='handshake.data'
--kinect_datafile='waltz.data'

config_dance_M={
	skel="../../taesooLib/Resource/motion/skeletonEditor/dance1_M_1dof.wrl",
	motion="../../taesooLib/Resource/motion/skeletonEditor/dance1_M_1dof_social_p2_edited.dof",
	--conFile="../Samples/scripts/RigidBodyWin/retargetting/data/Data/2_1.bvh.dof.bvh.conEditor",
	skinScale=112.54*0.85,
	modelScale={
		leftLeg=1,
		rightLeg=1,
		spine=1,
		leftArm=1,
		rightArm=1,
	},
	kinectScale=100, 
	kinectPosOffset=vector3(0,105,-270),
	heightAdjustment={ 0, 0, 0},
	rightLeg={'RightHip', 'RightKnee', 'RightAnkle', reversed=true},
	leftLeg= {'LeftHip', 'LeftKnee', 'LeftAnkle', reversed=true},
	rightArm={'RightShoulder', 'RightElbow', 'RightWrist', reversed=false},
	leftArm= {'LeftShoulder', 'LeftElbow', 'LeftWrist', reversed=true},
	neck={'Neck', 'Head'},
	spine={'Hips', 'Neck'},
	toes={'LeftAnkle','RightAnkle'},
	markerOffset=2,
	keyFrameDuration=10,
	debugMode=true,
	--fixedJoints={ -- do not use these joints in the graph
	--	'LThWrist','LThMetac', 'LThIntra1', 
	--	'LF1Wrist', 'LF1Metac','LF1Intra1','LF1Intra2', 
	--	'LF2Wrist', 'LF2Metac','LF2Intra1','LF2Intra2', 
	--	'LF3Wrist', 'LF3Metac','LF3Intra1','LF3Intra2', 
	--	'LF4Wrist', 'LF4Metac','LF4Intra1','LF4Intra2', 
	--	'RThWrist', 'RThMetac','RThIntra1', 
	--	'RF1Wrist', 'RF1Metac','RF1Intra1','RF1Intra2', 
	--	'RF2Wrist', 'RF2Metac','RF2Intra1','RF2Intra2', 
	--	'RF3Wrist', 'RF3Metac','RF3Intra1','RF3Intra2', 
	--	'RF4Wrist', 'RF4Metac','RF4Intra1','RF4Intra2', 
	--	'Head1', 'LEyeJ', 'REyeJ',
	--	--'Spine','root',
	--	'LToe','RToe',
	--},
	kneeDampingCoef_RO=math.rad(160),
	translateRefPoseAboveGround=true,	
	GROUND_HEIGHT=1, -- 1 cm. set this to nil to disable heightAdjustment
}

danceMotion={
		{
			skel="../Resource/jae/dance/dance1_M.wrl",
		--	mot ="../Resource/jae/dance/dance1_M.dof",
			mot ="../Resource/jae/dance/dance1_M_fastened.dof",
			motionFrameRate=30,
		},
		{
			skel="../Resource/jae/dance/dance1_W.wrl",
		--	mot ="../Resource/jae/dance/dance1_W.dof",
			mot ="../Resource/jae/dance/dance1_W_fastened.dof",
			motionFrameRate=30,
		},
		upperindexNum = 12,
		lowerindexNum = 6,
		isMove=false,
		doIK = true,
		MultiRegressor= true,
		skinScale = 100
}
social_p_retarget={
	{
		skel="../../taesooLib/Resource/motion/skeletonEditor/dance1_M_1dof.wrl",
		mot="../../taesooLib/Resource/motion/skeletonEditor/dance1_M_1dof_social_p2_edited.dof",

--			skel="../../taesooLib/Resource/jae/dance/dance1_M.wrl",
--			mot ="../../taesooLib/Resource/jae/dance/dance1_M_social_p2.dof",
		motionFrameRate=30,
	},
	{
		skel="../../taesooLib/Resource/motion/skeletonEditor/dance1_M_1dof.wrl",
		mot="../../taesooLib/Resource/motion/skeletonEditor/dance1_M_1dof_social_p1_edited.dof",

		motionFrameRate=30,
	},
	boneArr={
		'RightCollar','RightShoulder','RightElbow','RightWrist',
	},
	isMove=false,
	doIK = false,
	MultiRegressor=false,
	skinScale = 100
}
danceMotion_retarget={
		{
			skel="../Resource/motion/skeletonEditor/ETRI_2016_fixed_T.wrl",
		--	mot ="../Resource/jae/dance/dance1_M.dof",
			mot ="../Resource/jae/dance/dance1_M_to_ETRI_2016_fixed_T.dof",
			motionFrameRate=30,
		},
		{
			skel="../Resource/motion/skeletonEditor/ETRI_2016_fixed_T.wrl",
		--	mot ="../Resource/jae/dance/dance1_M.dof",
			mot ="../Resource/jae/dance/dance1_W_to_ETRI_2016_fixed_T.dof",
			motionFrameRate=30,
		},
		boneArr={
			'ETRI_man_flatface_V0_2:LCollarBone',
			'ETRI_man_flatface_V0_2:LShoulder',
			'ETRI_man_flatface_V0_2:LElbow',
			'ETRI_man_flatface_V0_2:LWrist',
		},
--		upperindexNum = 12,
--		lowerindexNum = 6,
		isMove=false,
		doIK=false,
		MultiRegressor= false,
		skinScale=100,
		removeRedundantBones=true

}

social_p={
	{
		skel="../Resource/jae/social_p1/social_p1.wrl",
		mot="../Resource/jae/social_p1/social_p1.bvh",
		motionFrameRate=30
	},
	{
		skel="../Resource/jae/social_p2/social_p2.wrl",
		mot="../Resource/jae/social_p2/social_p2.bvh",
		motionFrameRate=30
	},
	{
		{'Neck', 'Head', vector3(0,0,0), reversed=false},--0
		{'LeftElbow', 'Leftwrist', vector3(0,0,0), reversed=false},--7
		{'RightElbow', 'Rightwrist', vector3(0,0,0), reversed=false},--13
		{'LeftKnee', 'LeftAnkle', vector3(0, 0, 0), reversed=false},--18
		{'RightKnee', 'RightAnkle', vector3(0, 0, 0), reversed=false},--22
	},

	isMove=false,
	doIK=false,
	MultiRegressor=false,
	skinScale=1,
}


motionGroup={
--	[1]=danceMotion
--	[1]=danceMotion_retarget
	[1]=social_p
--	[1]=social_p_retarget
	
	--[[	[2]={
		{
			skel="../Resource/jae/dance/dance2_M.wrl",
			mot ="../Resource/jae/dance/dance2_M.dof",
			motionFrameRate=30,
		},
		{
			skel="../Resource/jae/dance/dance2_W.wrl",
			mot ="../Resource/jae/dance/dance2_W.dof",
			motionFrameRate=30,
		},
	},
]]
}
config=config_dance_M--for kinectDemo
startFrame=144
character2offset=vector3(1,0,0)
poseIntegrationAlpha=0.5 -- 1에 가까울수록 이전 프레임의 포즈를 적분한 결과보다는 예측된 포즈 선호.
featureHistorySize=25 -- 크면 더 잘되지만, 더 많은 예제데이터 필요.
numIDW_samples=20
upperindexNum = motionGroup[1].upperindexNum
lowerindexNum = motionGroup[1].lowerindexNum
isMove=motionGroup[1].isMove
MultiRegressor= motionGroup[1].MultiRegressor
MainMotion = 1

function lookAt(pose, offset)
	local tf=MotionDOF.rootTransformation(pose)
	local vpos=vector3(94.777964, 126.724047, 352.393547)
	local vat=vector3(-34.317428, 67.508947, -4.622992)
	local vdir=(vpos-vat)*0.5 -- zoomIn
	vdir:rotate(quater(math.rad(90),vector3(0,1,0)))
	RE.viewpoint().vat:assign(tf.translation*100+offset)
	RE.viewpoint().vpos:assign(tf.translation*100+offset+vdir)
	RE.viewpoint():update()
end

function ctor()

	mEventReceiver=EVR()

	this:create("Button", "attach camera to 1", "attach camera to 1")
	this:create("Button", "attach camera to 2", "attach camera to 2")
	this:widget(0):buttonShortcut("FL_ALT+c")

	this:create("Value_Slider"	, "set desired rotation", "set desired rotation",1);
	this:widget(0):sliderRange(-15, 15);
	this:widget(0):sliderValue(0);
	this:create("Value_Slider"	, "set desired distance", "set desired distance",1);
	this:widget(0):sliderRange(0, 15);
	this:widget(0):sliderValue(1);
	this:create("Value_Slider",	"set radd x", "set radd x",1);
	this:widget(0):sliderRange(-100, 100);
	this:widget(0):sliderValue(0);
	this:create("Value_Slider"	, "set radd z", "set radd z",1);
	this:widget(0):sliderRange(-100, 100);
	this:widget(0):sliderValue(0);

	this:create("Value_Slider",	"set radd x2", "set radd x2",1);
	this:widget(0):sliderRange(-100, 100);
	this:widget(0):sliderValue(0);
	this:create("Value_Slider"	, "set radd z2", "set radd z2",1);
	this:widget(0):sliderRange(-100, 100);
	this:widget(0):sliderValue(0);

	this:create("Button", "Start Nuitrack", "Start Nuitrack")
	this:widget(0):buttonShortcut("s")
	this:create("Check_Button", "Tracking", "Tracking")
	this:widget(0):checkButtonValue(false)
	this:widget(0):buttonShortcut("t")

	this:updateLayout()
	this:redraw()

	mObjectList=Ogre.ObjectList()
	
	--이 코드는 리그레션하는 모션데이타들이 모두 같은 wrl,dof 형식을 갖고 있다고 가정함
	--프레임수가 달라도 스켈레톤구조와 posedof 사이즈가 같아야한다는 의미.
	mLoaderArr ={}
	DOFcontainerArr={}
	mSkinArr={}
	N=0
	featureSize=0
	mLoader =nil
	mLoader2=nil
	mMotionDOFcontainer =nil
	mMotionDOFcontainer2=nil

	for motNum=1,#motionGroup do

		
		input =motionGroup[motNum][1]
		input2=motionGroup[motNum][2]

		mot =loadMotion(input.skel,input.mot,motionGroup[motNum].skinScale,motionGroup[motNum].removeRedundantBones)
		mot2=loadMotion(input2.skel,input2.mot,motionGroup[motNum].skinScale,motionGroup[motNum].removeRedundantBones)
		mLoaderArr[motNum]={}
		mLoaderArr[motNum][1]=mot.loader
		mLoaderArr[motNum][2]=mot2.loader

		DOFcontainerArr[motNum]={}
		DOFcontainerArr[motNum][1]=mot.motionDOFcontainer
		DOFcontainerArr[motNum][2]=mot2.motionDOFcontainer

		mSkinArr[motNum]={}
		mSkinArr[motNum][1]=mot.skin
		mSkinArr[motNum][2]=mot2.skin
--[[
		mLoaderArr[motNum]={}
		chosenFile=input.skel
		mLoaderArr[motNum][1]=MainLib.VRMLloader(chosenFile)
		chosenFile2=input2.skel
		mLoaderArr[motNum][2]=MainLib.VRMLloader(chosenFile2)

		DOFcontainerArr[motNum]={}
		DOFcontainerArr[motNum][1]=MotionDOFcontainer(mLoaderArr[motNum][1].dofInfo,input.mot)
		DOFcontainerArr[motNum][2]=MotionDOFcontainer(mLoaderArr[motNum][2].dofInfo,input2.mot)
]]
		N=N+DOFcontainerArr[motNum][1].mot:numFrames()
	end
	featureSize=DOFcontainerArr[1][1]:row(0):size()

	local matfeatureall=matrixn()
	matfeatureall:resize(N,featureSize)
	local matfeaturevalid=boolN()
	matfeaturevalid:resize(N)
	matfeaturevalid:setAllValue(false)

	if MultiRegressor then
		matfeatureLow=matrixn() -- for transf and lower body regressor
		matfeatureLow:resize(N,7+lowerindexNum*3)
		matfeatureLowvalid=boolN()
		matfeatureLowvalid:resize(N)
		matfeatureLowvalid:setAllValue(false)

		matfeatureUp=matrixn() -- for upper body regressor
		matfeatureUp:resize(N,upperindexNum*3)
		matfeatureUpvalid=boolN()
		matfeatureUpvalid:resize(N)
		matfeatureUpvalid:setAllValue(false)

		mMetric=math.L2Metric()
	end

	local matfeatureall2=matrixn()
	matfeatureall2:resize(N,featureSize)
	local matfeaturevalid2=boolN()
	matfeaturevalid2:resize(N)
	matfeaturevalid2:setAllValue(false)

	if MultiRegressor then
		matfeatureLow2=matrixn() -- for transf and lower body regressor
		matfeatureLow2:resize(N,7+lowerindexNum*3)
		matfeatureLowvalid2=boolN()
		matfeatureLowvalid2:resize(N)
		matfeatureLowvalid2:setAllValue(false)

		matfeatureUp2=matrixn() -- for upper body regressor
		matfeatureUp2:resize(N,upperindexNum*3)
		matfeatureUpvalid2=boolN()
		matfeatureUpvalid2:resize(N)
		matfeatureUpvalid2:setAllValue(false)
	end
	-- regressor (또는 pose group. 아마도 나중에는 여러개가 필요할 듯.)
	
	cset={
		matfeature=matrixn(), -- source
		matdata=matrixn(), -- target
		--IDW=NonlinearFunctionIDW(mMetric, numIDW_samples, 2.0) -- regressor
		IDW=KNearestInterpolationFast(numIDW_samples, 2.0) -- regressor
	}--regressor for Upperbody
	cset2={
		matfeature=matrixn(),
		matdata=matrixn(),
		IDW=KNearestInterpolationFast(numIDW_samples,2.0)
	}--regressor for Lowerbody

	local startF=0
	local endF=0
	for motNum=1,#motionGroup do
		--dbg.console()
		if motNum >1 then 
			startF=startF+DOFcontainerArr[motNum-1][1].mot:numFrames()
			if startF>N then 
				print('something wrong about frame count');
				dbg.console();
			end
		end
		numFrame=DOFcontainerArr[motNum][1].mot:numFrames()
		endF=startF+numFrame-1
		if endF >=N then print('somthing wront about endFrame')
			dbg.console()
		end

		mLoader = mLoaderArr[motNum][1]
		mLoader2= mLoaderArr[motNum][2]
		mMotionDOFcontainer = DOFcontainerArr[motNum][1]
		mMotionDOFcontainer2= DOFcontainerArr[motNum][2]
		boneArr=motionGroup[motNum].boneArr

		for i=0,numFrame-1 do
		--	if i>featureHistorySize then dbg.console() end
--			    if i==0 or i==1 or i==50 then dbg.console() end
			local pose=extract_pose(mMotionDOFcontainer, i)
			local dpose=extract_dpose(mMotionDOFcontainer, i)
			
			local poseW=extract_pose(mMotionDOFcontainer2, i)
			local dposeW=extract_dpose(mMotionDOFcontainer2, i)

			if pose and dpose and poseW and dposeW then
				local feature=extractFeatureVector(pose, dpose)
				local featureW=extractFeatureVector(poseW, dposeW)

				local fpos = startF+i
				if fpos>endF then print('something wrong about frame count');
					dbg.console()
				end


				if MultiRegressor then
					if fpos==5375 or fpos==5376 then dbg.console() end
					local lowfeatureNum = 7+3*(lowerindexNum)
					matfeatureLow:row(fpos):assign(feature:range(0,lowfeatureNum))
					matfeatureLowvalid:set(fpos,true)
					matfeatureUp:row(fpos):assign(feature:range(lowfeatureNum,getFeatureSize()))
					matfeatureUpvalid:set(fpos,true)

					matfeatureLow2:row(fpos):assign(featureW:range(0,lowfeatureNum))
					matfeatureLowvalid2:set(fpos,true)
					matfeatureUp2:row(fpos):assign(featureW:range(lowfeatureNum,getFeatureSize()))
					matfeatureUpvalid2:set(fpos,true)
				else
					matfeatureall:row(fpos):assign(feature)
					matfeaturevalid:set(fpos,true)
					matfeatureall2:row(fpos):assign(featureW)
					matfeaturevalid2:set(fpos,true)
				end

	--		if i>featureHistorySize then dbg.console() end
				local male,female
				if i>featureHistorySize then
					if MultiRegressor then
						male = matfeatureLowvalid:range(fpos-featureHistorySize+1,fpos+1):count()
						female = matfeatureLowvalid2:range(fpos-featureHistorySize+1,fpos+1):count()
					else
						male = matfeaturevalid:range(fpos-featureHistorySize+1,fpos+1):count()
						female = matfeaturevalid2:range(fpos-featureHistorySize+1,fpos+1):count()
					end
				end
				if i>featureHistorySize and male==featureHistorySize and female==featureHistorySize then
					-- (i-featureHistorySize, i] 전부다 valid 한 경우
					local vpose=PoseToVector(pose) 
					local vdpose=DposeToVector(dpose)
					local vposeW=PoseToVector(poseW) 
					local vdposeW=DposeToVector(dposeW)

					--To use joint angles as control input, we use a function named extractControlInput2
					--local control=extractControlInput(mMotionDOFcontainer, i)
					local control=extractControlInput2(mMotionDOFcontainer,mMotionDOFcontainer2, i)

					if control ~=nil then
						-- 입력 (db search query)
						if not MultiRegressor then
							cset.matfeature:pushBack(
								matfeatureall:sub(fpos-featureHistorySize, fpos,0,0):toVector()..
		--						matfeatureall2:sub(i-featureHistorySize, i,0,0):toVector()..
								control)
						else
							cset.matfeature:pushBack(
								matfeatureLow:sub(fpos-featureHistorySize,fpos,0,0):toVector()
								)

							cset2.matfeature:pushBack(
								matfeatureUp:sub(fpos-featureHistorySize,fpos,0,0):toVector()..
								control	
								)
						end
						-- 출력
						cset.matdata:pushBack(vposeW..vdposeW)
						if MultiRegressor then
							cset2.matdata:pushBack(vposeW..vdposeW) 
						end
					end
				end
			end
		end
	end

	--dbg.console()
	assert(cset.matfeature:rows()>0)
	assert(cset.matfeature:rows()==cset.matdata:rows())
	cset.IDW:learn(cset.matfeature, cset.matdata)

	if MultiRegressor then
		assert(cset2.matfeature:rows()>0)
		assert(cset2.matfeature:rows()==cset2.matdata:rows())
		cset2.IDW:learn(cset2.matfeature, cset2.matdata)
	end

	assert(MainMotion<=#motionGroup)
	mLoader = mLoaderArr[MainMotion][1]
	mLoader2= mLoaderArr[MainMotion][2]
	mMotionDOFcontainer = DOFcontainerArr[MainMotion][1]
	mMotionDOFcontainer2= DOFcontainerArr[MainMotion][2]
	input =motionGroup[MainMotion][1]
	input2=motionGroup[MainMotion][2]
	boneArr=motionGroup[MainMotion].boneArr
	doIK = motionGroup[MainMotion].doIK
	local skinScale = motionGroup[MainMotion].skinScale

	--skin setting--
	drawSkeleton=true
	mSkin = mSkinArr[MainMotion][1]
--	mSkin =RE.createVRMLskin(mLoader, drawSkeleton)
--	mSkin:setThickness(0.03)
--	mSkin:scale(100,100,100)
	mSkin2=RE.createVRMLskin(mLoader, drawSkeleton)
	mSkin2:setThickness(0.03)
	mSkin2:scale(skinScale,skinScale,skinScale)

	drawSkeleton2=true
	mSkinW = mSkinArr[MainMotion][2]
--	mSkinW =RE.createVRMLskin(mLoader2, drawSkeleton2)
--	mSkinW:setThickness(0.03)
--	mSkinW:scale(100,100,100)
	mSkinW2=RE.createVRMLskin(mLoader2, drawSkeleton2)
	mSkinW2:setThickness(0.03)
	mSkinW2:scale(skinScale,skinScale,skinScale)

	mSkin:setVisible(false)
	mSkinW:setVisible(false)
	if doIK then
		if os.isFileExist(string.sub(input.skel, 1, -4)..'con_config.lua') then
			mconfig=loadfile(string.sub(input.skel, 1, -4)..'con_config.lua')()
			mconfig2=loadfile(string.sub(input2.skel, 1, -4)..'con_config.lua')()
		elseif os.isFileExist(string.sub(input.skel, 1, -4)..'con_config') then
			mconfig=loadfile(string.sub(input.skel, 1, -4)..'con_config')()
			mconfig2=loadfile(string.sub(input2.skel, 1, -4)..'con_config')()
		else 
			print('not exist ik config file!')
			dbg.console()
		end
	end

	--mMotionDOFcontainer=MotionDOFcontainer(mLoader.dofInfo,input.mot)
	
	--nuiListenerInit()
	mSkin:applyMotionDOF(mMotionDOFcontainer.mot)
	mSkin:setFrameTime(1/30)
	
	RE.motionPanel():motionWin():detachSkin(mSkin)
	RE.motionPanel():motionWin():addSkin(mSkin)

	--woman
	--mMotionDOFcontainer2=MotionDOFcontainer(mLoader2.dofInfo,input2.mot)
	mSkinW:applyMotionDOF(mMotionDOFcontainer2.mot)
	mSkinW:setFrameTime(1/30)

	RE.motionPanel():motionWin():detachSkin(mSkinW)
	RE.motionPanel():motionWin():addSkin(mSkinW)

	mSkin2:setPoseDOF(mMotionDOFcontainer.mot:row(3))
	mSkinW2:setPoseDOF(mMotionDOFcontainer2.mot:row(3))

	mSkin2:setTranslation(character2offset.x*200, character2offset.y*200, character2offset.z*200)
	mSkinW2:setTranslation(character2offset.x*200, character2offset.y*200, character2offset.z*200)

	--IKsetting--
	if doIK then
		--man
		bones={	
			mLoader:getBoneByName(mconfig.wrist[1]),
			mLoader:getBoneByName(mconfig.wrist[2])
		}
		mEffectors=MotionUtil.Effectors()
		mEffectors:resize(2);

		local elbow 
		if not mconfig.elbow then
			elbow={
				mLoader:bone(bones[1]:treeIndex()-1),
				mLoader:bone(bones[2]:treeIndex()-1),
			}
		else
			elbow={
				mLoader:getBoneByName(mconfig.elbow[1]),
				mLoader:getBoneByName(mconfig.elbow[2]),
			}
		end
		mEffectors(0):init(bones[1],vector3(0,0,0))
		mEffectors(1):init(bones[2],vector3(0,0,0))
		mIK= LimbIKsolver(mLoader.dofInfo, mEffectors, CT.ivec(elbow[1]:treeIndex(), elbow[2]:treeIndex()), CT.vec(1,1));
		--man IKsetting end
		
		--woman
		bones2={	
			mLoader2:getBoneByName(mconfig2.wrist[1]),
			mLoader2:getBoneByName(mconfig2.wrist[2])
		}

		mEffectors2=MotionUtil.Effectors()
		mEffectors2:resize(2);

		local elbow2
		if not mconfig2.elbow then
			elbow2={
				mLoader2:bone(bones2[1]:treeIndex()-1),
				mLoader2:bone(bones2[2]:treeIndex()-1),
			}
		else
			elbow2={
				mLoader2:getBoneByName(mconfig2.elbow[1]),
				mLoader2:getBoneByName(mconfig2.elbow[2]),
			}
		end


		mEffectors2(0):init(bones2[1], vector3(0,0,0))--i don't know  end effector pos
		mEffectors2(1):init(bones2[2], vector3(0,0,0))--need to add effector lpos
		mIK2= LimbIKsolver(mLoader2.dofInfo, mEffectors2, CT.ivec(elbow2[1]:treeIndex(), elbow2[2]:treeIndex()), CT.vec(1,1));
		--woman IKsetting end
	end
	-- init state --
	mState=initState(mMotionDOFcontainer, startFrame)-- this mState is real user's state, so this is not used.
	mState2=initState(mMotionDOFcontainer2, startFrame)-- mState2 is practically used

	local fpos=0
	if #motionGroup >1 then
		for i=2,MainMotion do
			fpos=fpos+DOFcontainerArr[i-1][1].mot:numFrames()
		end
	end
	if MultiRegressor then
		assert(matfeatureLowvalid:range(fpos+startFrame-featureHistorySize, fpos+startFrame):count()==featureHistorySize )
		mLowFeatureHistory=matfeatureLow:sub(fpos+startFrame-featureHistorySize,fpos+startFrame,0,0):copy()
		assert(matfeatureUpvalid:range(fpos+startFrame-featureHistorySize, fpos+startFrame):count()==featureHistorySize )
		mUpFeatureHistory=matfeatureUp:sub(fpos+startFrame-featureHistorySize,fpos+startFrame,0,0):copy()

		assert(matfeatureLowvalid2:range(fpos+startFrame-featureHistorySize, fpos+startFrame):count()==featureHistorySize )
		mLowFeatureHistory2=matfeatureLow2:sub(fpos+startFrame-featureHistorySize,fpos+startFrame,0,0):copy()
		assert(matfeatureUpvalid2:range(fpos+startFrame-featureHistorySize, fpos+startFrame):count()==featureHistorySize )
		mUpFeatureHistory2=matfeatureUp2:sub(fpos+startFrame-featureHistorySize,fpos+startFrame,0,0):copy()
	else
		assert( matfeaturevalid:range(fpos+startFrame-featureHistorySize, fpos+startFrame):count()==featureHistorySize )
		mFeatureHistory=matfeatureall:sub(fpos+startFrame-featureHistorySize, fpos+startFrame,0,0):copy()
		assert( matfeaturevalid2:range(fpos+startFrame-featureHistorySize, fpos+startFrame):count()==featureHistorySize )
		mFeatureHistory2=matfeatureall2:sub(fpos+startFrame-featureHistorySize, fpos+startFrame,0,0):copy()
	end

	if config.debugMode then
	   --mKinectTracker=KinectTrackerFromFile("../../testdata/etri_src_kinect.txt", true )
	   mKinectTracker=KinectTrackerFromFile("../kinectdata/"..kinect_datafile)
	else
	   mKinectTracker=KinectTrackerFromFile("../kinectdata/"..kinect_datafile)
	end
--	mKinectModule=kinectModule(mKinectTracker)
	--mKinectTracker=KinectTracker()
	mTimeline=Timeline("Timeline", 10000)
end

function nuiListenerInit()
	nuiListener = NuiListener()
	start = false
	tracking = false

	mPose = vectorn()
	mLoader:getPoseDOF(mPose)
	mSkin2:setPoseDOF(mPose)

	mSolverInfo=createIKsolver(solver, mLoader, config[3])
	mEffectors=mSolverInfo.effectors
	numCon=mSolverInfo.numCon
	mIK=mSolverInfo.solver

	eePos=vector3N(numCon)
	
	mLoader:setPoseDOF(mPose)
	local originalPos={}
	for i=0, numCon-1 do
		local opos=mEffectors(i).bone:getFrame():toGlobalPos(mEffectors(i).localpos)
		opos=opos+vector3(0, 108, 0)
		originalPos[i+1]=opos*config.skinScale--mskin:scale 과 비교
	end
	local hipPos = mLoader:bone(1):getFrame().translation + vector3(0, 108, 0)
	table.insert(originalPos, hipPos*config.skinScale)

	mCON=Constraints(unpack(originalPos))
end

function conPosUpdate()
	local s=1.3
--	mCON.conPos(0):assign(getJointPos(0)*s)
--	mCON.conPos(1):assign(getJointPos(7)*s)
--	mCON.conPos(2):assign(getJointPos(13)*s)
--	mCON.conPos(3):assign(getJointPos(18)*s)
--	mCON.conPos(4):assign(getJointPos(22)*s)
--	mCON.conPos(5):assign(getJointPos(3)*s)

	mCON.conPos(0):assign(getJointPos(0))
	mCON.conPos(1):assign(getJointPos(7))
	mCON.conPos(2):assign(getJointPos(13))
	mCON.conPos(3):assign(getJointPos(18))
	mCON.conPos(4):assign(getJointPos(22))
	mCON.conPos(5):assign(getJointPos(3))
	mCON:drawConstraints()
end

function drawSkeletonJoints()--ToDo: 실제 그려지는 ball은 19개. collar가 문제인듯.
	if nuiListener:isTracking() then
		for i=0, 23 do
			if not(i==9 or i==15 or i==19 or i==23) then
				dbg.draw("Sphere", getJointPos(i), "ball"..i, "red", 3)
			end
		end
	end
end

function getJointPos(idx)
	local pos = vector3()
	pos.x = nuiListener:getJointRealCoords(idx,0)/10
	pos.y = nuiListener:getJointRealCoords(idx,1)/10 + 130
	pos.z = -nuiListener:getJointRealCoords(idx,2)/10 --지금 카메라각도에서 wrl과 맞추기 위해 -1x
	return pos
end

function createIKsolver(solverType, loader, config)
	local out={}
	local mEffectors=MotionUtil.Effectors()
	--local numCon=#config
	local numCon=#motionGroup[1][3]
	mEffectors:resize(numCon);
	out.effectors=mEffectors
	out.numCon=numCon

	for i=0, numCon-1 do
		--local conInfo=config[i+1]
		local conInfo=motionGroup[1][3][i+1]
		local kneeInfo=1
		--local lknee=loader:getBoneByName(conInfo[kneeInfo])
		mEffectors(i):init(loader:getBoneByName(conInfo[kneeInfo+1]), conInfo[kneeInfo+2])
		--endeffector로 등록
	end
	g_con=MotionUtil.Constraints() -- std::vector<MotionUtil::RelativeConstraint>
	out.solver=MotionUtil.createFullbodyIk_MotionDOF_MultiTarget_lbfgs(loader.dofInfo);
	return out
end

function limbik()
	conPosUpdate()
	--mPose:assign(mMotionDOF:row(0));
	--mLoader:setPoseDOF(mPose);
	local hasCOM=0
	local hasRot=0
	local hasMM=0
	local COM=mCON.conPos(5)/config.skinScale--안쓰이는듯
	mIK:_changeNumEffectors(numCon)
	--mIK:_changeNumConstraints(hasCOM+hasRot+hasMM)
	-- local pos to global pos
	for i=0,numCon-1 do
		mIK:_setEffector(i, mEffectors(i).bone, mEffectors(i).localpos)

		local originalPos=mCON.conPos(i)/config.skinScale
		eePos(i):assign(originalPos);
	end
	
	if hasCOM==1 then
		mIK:_setCOMConstraint(0, COM)
	end
	if hasRot==1 then
		local bone=mLoader:getBoneByName('LeftElbow')

		mIK:_setOrientationConstraint(hasCOM, bone, quater(this:findWidget('arm ori y'):sliderValue(), vector3(0,1,0)));
	end
	if hasMM==1 then
		mIK:_setMomentumConstraint(hasCOM+hasRot, vector3(0,0,0), vector3(0,0,0));
	end
	mIK:_effectorUpdated()

	mIK:IKsolve(mPose, eePos)
	mLoader:setPoseDOF(mPose);
	mSkin2:setPoseDOF(mPose);
end

function getCurPoseVector()
	local curPoseVector = vectorn()
	mLoader:getPoseDOF(curPoseVector)
	return curPoseVector
end

function initState(motdof, startFrame)
	local pose=extract_pose(motdof, startFrame)
	if not pose then return nil end
	local dpose=extract_dpose(motdof, startFrame, pose)
	if not dpose then return nil end

	local state=
	{
		pose=pose,
		dpose=dpose
	}
	state.raw_pose=motdof.mot:row(startFrame):copy()
	return state
end

function extract_pose(motdof, frame)
	if frame>=motdof:numFrames() then
		return nil
	end
	if frame<0 then
		return nil
	end
	if motdof.discontinuity(frame) then
		return nil
	end

	local raw_pose=motdof.mot:row(frame)
	local pose={}
	-- vertical component of root orientation
	pose.rotY=quater()
	-- horizontal root translation
	pose.rootXZ=raw_pose:toVector3(0)
	pose.rootXZ.y=0
	
	-- root transformation excluding vertical rotation and horizontal tranlation
	-- vertical rotation, horizontal translation은 좌표계에 dependent한 성분이고
	-- 나머지 어느 위치에 어느방향을 보도록 갖다놓아도 변하지 않는 성분은 pelvisOffset으로 따로 저장한다.
	pose.pelvisOffset, pose.rotY=extract_pelvisOffset(raw_pose)
	-- jont angles excluding root
	pose.jointAngles=raw_pose:range(7, raw_pose:size()):copy()
	return pose
end

function extract_pelvisOffset(raw_pose)
	local pelvisOffset=transf()
	local rotY=quater()
	raw_pose:toQuater(3):decompose(rotY, pelvisOffset.rotation) -- excluding vertical rotation
	pelvisOffset.translation:assign(vector3(0, raw_pose(1),0)) -- height only excluding horizontal translation
	return pelvisOffset, rotY
end

function extract_dpose(motdof, frame)
	local pose1=extract_pose(motdof, frame)
	local pose2=extract_pose(motdof, frame+1)
	if not pose1 or not pose2 then
		return nil
	end

	-- 미분.
	local dpose={}
	dpose.pelvisOffset={
		rotation=vector3(),
		translation=vector3()
	}
	dpose.pelvisOffset.rotation:angularVelocity(pose1.pelvisOffset.rotation, pose2.pelvisOffset.rotation)
	dpose.pelvisOffset.translation:linearVelocity(pose1.pelvisOffset.translation, pose2.pelvisOffset.translation)

	dpose.rootXZ=vector3()
	dpose.rootXZ:linearVelocity(pose1.rootXZ, pose2.rootXZ)
	dpose.rootXZ:rotate(pose1.rotY:inverse())

	local qdelta=quater()
	qdelta:difference(pose1.rotY, pose2.rotY)
	dpose.rotY=qdelta:rotationAngleAboutAxis(vector3(0,1,0))
	dpose.jointAngles=pose1.jointAngles-pose2.jointAngles
	dpose.jointAngles:rmult(input.motionFrameRate) -- (angle1-angle2)/dt
	return dpose
end

function onCallback(w, userData)
	if w:id()=="export results" then
		local chosenFile=Fltk.chooseFile("Choose a DOF file to create", ".", "*.dof", true)
		exportResults(chosenFile)
	elseif w:id()=="attach camera to 1" then
		mEventReceiver:attachCamera(mMotion1)
	elseif w:id()=="attach camera to 2" then
		--mEventReceiver:attachCamera(mMotion2)
		mEventReceiver.camera2=true
		local curPos=mState.raw_pose:toVector3(0)*100
		mEventReceiver:_attachCamera(curPos)
	elseif w:id()=="set radd x" then
	elseif w:id()=="set radd z" then
	elseif w:id()=="Start Nuitrack" then
		nuiListener:startNuitrack()
		start = true
	elseif w:id()=="Tracking" then
		if start == true then
			if w:checkButtonValue() then
				tracking = true
			else
				dbg.eraseAllDrawn()
				tracking = false
			end
		else
			print("please start nuitrack. press Start Nuitrack Button")
			w:checkButtonValue(false)
		end
	end
end

function dtor()
	dbg.finalize()
	detachSkins()
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

function EVR:setCamera(iframe)
	self.currFrame=iframe
	if self.trajectory then
		if self.currFrame<self.trajectory:rows() then
			assert(self.trajectory:rows()==
			self.trajectoryOri:rows())
			local mMotionDOF=mMotionDOFcontainer.mot
			local curPos=self.trajectory:row(self.currFrame):toVector3(0)*100
			local pPos=
			MotionDOF.rootTransformation(mMotionDOF:row(self.currFrame)).translation
			local currRot=
			self.trajectoryOri:row(self.currFrame):toQuater(0):rotationY()

			--dbg.draw('Line', pPos*100, pPos*100+rotate(character2offset*100, currRot), 'prot')


			--print('setCamera', iframe, self.cameraInfo.vat, curPos)
			do
				RE.viewpoint().vpos:assign(self.cameraInfo.vpos+curPos)
				RE.viewpoint().vat:assign(self.cameraInfo.vat+curPos)
				RE.viewpoint():update()     
			end
		end
	elseif self.camera2 then
		local curPos=mState.raw_pose:toVector3(0)*100
		--dbg.draw('Sphere', curPos, "root", "red", 10)
		RE.viewpoint().vpos:assign(self.cameraInfo.vpos+curPos)
		RE.viewpoint().vat:assign(self.cameraInfo.vat+curPos)
		RE.viewpoint():update()     
	end
end
function mapping(idw, feature, target, matfeature)
	local weight=vectorn() 
	local index=intvectorn()
	idw:mapping2(feature, target, index, weight)
	assert(target:size()==transitionBoundarySize or 2)
	
	local distance=(matfeature:row(index(weight:argMax()))-feature):length()
	return distance
end
tempframe = 0
function EVR:onFrameChanged(win, iframe)
	--if self.trajectory then EVR.setCame0.000440,-0.010029,-0.037750,-0.106580,-0.013146,0.972541,0.206476,-0.002546,0.018145,0.046361,-0.023359,-0.001154,-0.010464,0.000069,0.001702,0.017954,0.044275,-0.025996,-0.004319,-0.008092,0.003610,0.000477,0.014322,-0.000914,0.000041,0.000620,-0.000884,-0.005313,0.000868,-0.007171,-0.017980,0.025290,-0.011810,0.019976,0.003080,-0.009969,0.003315,0.002140,0.000260,0.004879,0.020927,0.025440,-0.018510,0.006864,-0.006886,-0.012543,0.000460,-0.001967,-0.002119,0.006164,-0.003975,0.000188,0.006104ra(self, iframe) end do return end

	if noOnframeChanged then return end

	self.currFrame=iframe
	tempframe = self.currFrame

	--kinectdata=mKinectModule:oneStep(iframe)
	--kinectdata:setTransf(0,mState.raw_pose:toTransf(0))

	local out
	if true then
		if not MultiRegressor then
			out,mState2 = calOutput(mState2)
		else
			out,mState2 = calOutput2(mState2)
		end

--		if iframe < mMotionDOFcontainer:numFrames() then
--	--		mLoader:setPoseDOF(kinectdata)
--			mLoader:setPoseDOF(mMotionDOFcontainer.mot:row(tempframe+startFrame))
--			mLoader2:setPoseDOF(out)
--		else
--			util.msgBox("Error! frame range error")
--		end
		if tracking then
			limbik()
			--mLoader:setPoseDOF(getCurPoseVector())
			mLoader2:setPoseDOF(out)
		end

	--	mLoader:setPoseDOF(kinectdata)
				--dbg.console()
	-- iksolve start--
		local IKout=vectorn()
		local IKout2=vectorn()
		mLoader:getPoseDOF(IKout)
		IKout2:assign(out)

		if doIK then
			local LWristPos = mEffectors(0).bone:getFrame():toGlobalPos(vector3(0,0,0))
			local RWristPos = mEffectors(1).bone:getFrame():toGlobalPos(vector3(0,0,0))
			local LWristPos2 =mEffectors2(0).bone:getFrame():toGlobalPos(vector3(0,0,0))
			local RWristPos2 =mEffectors2(1).bone:getFrame():toGlobalPos(vector3(0,0,0))

			local RR,RL,LR,LL
			local posR,posL,posR2,posL2,grepPos,alpha,pvec
			RR=RWristPos-RWristPos2
			RL=RWristPos-LWristPos2
			LR=LWristPos-RWristPos2
			LL=LWristPos-LWristPos2

			if RR:length() <0.4 then 
				alpha = RR:length()/0.4
				grepPos = (RWristPos+RWristPos2)/2
				pvec = (-RWristPos+RWristPos2)/2
				posR=grepPos-pvec*alpha;posL=LWristPos;posR2=grepPos+pvec*alpha;posL2=LWristPos2;
			elseif RL:length() <0.4 then
				alpha = RL:length()/0.4
				grepPos = (RWristPos+LWristPos2)/2
				pvec = (-RWristPos+LWristPos2)/2
				posR=grepPos-pvec*alpha;posL=LWristPos;posR2=RWristPos2;posL2=grepPos+pvec*alpha;
			elseif LR:length() <0.4 then 
				alpha = LR:length()/0.4
				grepPos = (LWristPos+RWristPos2)/2
				pvec = (-LWristPos+RWristPos2)/2
				posR=RWristPos;posL=grepPos-pvec*alpha;posR2=grepPos+pvec*alpha;posL2=LWristPos2;
			elseif LL:length() <0.4 then
				alpha = LL:length()<0.4
				grepPos = (LWristPos+LWristPos2)/2
				pvec = (-LWristPos+LWristPos2)/2
				posR=RWristPos;posL=grepPos-pvec*alpha;posR2=RWristPos2;posL2=grepPos+pvec*alpha;
			else
				grepPos=nil
			end

			if grepPos then
				do --IK for character 1
				-- dance : man=left wrist, woman=right wrist
					local wcons=vector3N(2)
					local wcons_q=quaterN(2)
					wcons:row(0):assign(posL) -- grep constraint
					wcons:row(1):assign(posR)

					wcons_q(0):assign(mEffectors(0).bone:getFrame().rotation:copy())
					wcons_q(1):assign(mEffectors(1).bone:getFrame().rotation:copy())
					
					local importance=vectorn(2)
					importance:setAllValue(1)
					mIK:IKsolve3(IKout,mMotionDOFcontainer.mot.rootTransformation(IKout),wcons,wcons_q,importance)
				end

				do --IK for character 2 
				-- dance : man=left wrist, woman=right wrist
					local wcons=vector3N(2)
					local wcons_q=quaterN(2)
					wcons:row(0):assign(posL2)
					wcons:row(1):assign(posR2) -- grep constraint

					wcons_q(0):assign(mEffectors2(0).bone:getFrame().rotation:copy())
					wcons_q(1):assign(mEffectors2(1).bone:getFrame().rotation:copy())
					
					local importance=vectorn(2)
					importance:setAllValue(1)
					mIK2:IKsolve3(IKout2,mMotionDOFcontainer2.mot.rootTransformation(IKout2),wcons,wcons_q,importance)
				end
			end
		end
	-- iksolve  end --

		--mSkin ad mSkinW are original dance motion
		--mSkin2 is Man's motion
		--mSkinW2 is woman's edited motion
		
	--	dbg.console()
		local transition = IKout:toVector3(0)
		transition.x=transition.x+this:findWidget("set radd x"):sliderValue()
		transition.z=transition.z+this:findWidget("set radd z"):sliderValue()
		IKout:setVec3(0,transition) -- 
		
		local transition2= IKout2:toVector3(0)
		transition2.x=transition2.x+this:findWidget("set radd x2"):sliderValue()
		transition2.z=transition2.z+this:findWidget("set radd z2"):sliderValue()
		IKout2:setVec3(0,transition2) -- 

--		if iframe < mMotionDOFcontainer:numFrames() then
--			mSkin2:setPoseDOF(IKout)
--		end
		if tracking then
			mSkin2:setPoseDOF(IKout)
		end
		mSkinW2:setPoseDOF(IKout2)
	end
	EVR.setCamera(self, iframe)
end

function calOutput(mState)

	local rotY=mState.pose.rotY
	
--	local feature=extractFeatureVector(extract_pose(mMotionDOFcontainer,tempframe+startFrame),
--		extract_dpose(mMotionDOFcontainer,tempframe+startFrame))
	local feature=extractFeatureVector(extract_pose(mMotionDOFcontainer,startFrame),--여기서 단순히 현재 포즈 정보만 넘겨주면 되나?
		extract_dpose(mMotionDOFcontainer,startFrame))--그리고 그걸 여기서 디포즈?

 --	local feature = kinectdata
	local feature2=extractFeatureVector(integratePose2(mState.pose,mState.dpose),mState.dpose)
	local user_control=extractControlInput3(mMotionDOFcontainer,feature)--feature
		
	mFeatureHistory:pushBack(feature)
	mFeatureHistory2:pushBack(feature2)

	local target=vectorn()
	local ff

	ff= mFeatureHistory:sub(mFeatureHistory:rows()-featureHistorySize, mFeatureHistory:rows(),0,0):toVector()
	cset.IDW:mapping(ff..user_control, target)
	
	local pose, curColumn= PoseVectorToPose(target)
	local dpose, curColumn= PoseVectorToDPose(target, curColumn)

	-- regression 결과가 pose, dpose
	if false then
		-- regression대신 예제 자세를 그대로 갖다쓰려면...
		pose=extract_pose(mMotionDOFcontainer2, tempframe+startFrame)
		dpose=extract_dpose(mMotionDOFcontainer2, tempframe+startFrame)
	end

	-- regression결과에 없는 정보(위치-dependent components)는 State에서 카피.
	pose.rotY=mState.pose.rotY:copy()
	pose.rootXZ=mState.pose.rootXZ:copy()

	local nextpose
	if not isMove then
		mState.pose=integratePose2(mState.pose, dpose)
		nextpose=integratePose2(pose, dpose)
	else
		-- 현재 포즈를 예측된 속도로 적분.
		mState.pose=integratePose(mState.pose, dpose)
		-- obtain next pose
		-- 예측된 포즈를 예측된 속도로 적분.
		nextpose=integratePose(pose, dpose)
	end
	
	-- blend two guessed poses.
	local out	
	out=vectorn(mMotionDOFcontainer2.mot:row(0):size())
	mLoader2.dofInfo:blend(out, recoverRawPose(mState.pose), recoverRawPose(nextpose), poseIntegrationAlpha)

	mState.raw_pose=out
	mState.pose.jointAngles:assign(out:range(7,out:size()))
	mState.pose.pelvisOffset, mState.pose.rotY=extract_pelvisOffset(out)
	mState.dpose=dpose

	return out,mState
end

function calOutput2(mState)

	-- mLowFeatureHistory2 and mUpFeatureHistory2 is second character's input feature for regression 
	-- but because regressor only use user's input , this features is not used for now
	local feature=extractFeatureVector(extract_pose(mMotionDOFcontainer,tempframe+startFrame),
		extract_dpose(mMotionDOFcontainer,tempframe+startFrame))
	local feature2=extractFeatureVector(integratePose2(mState.pose,mState.dpose),mState.dpose)
	local user_control=extractControlInput2(mMotionDOFcontainer,mMotionDOFcontainer2,tempframe+startFrame)
		
	local lowfeatureNum = 7+3*lowerindexNum
	mLowFeatureHistory:pushBack(feature:range(0,lowfeatureNum))
	mUpFeatureHistory:pushBack(feature:range(lowfeatureNum,getFeatureSize()))

	mLowFeatureHistory2:pushBack(feature2:range(0,lowfeatureNum))
	mUpFeatureHistory2:pushBack(feature2:range(lowfeatureNum,getFeatureSize()))

	local target=vectorn()
	local target2=vectorn()
	local ffLow,ffUp

	ffLow = mLowFeatureHistory:sub(mLowFeatureHistory:rows()-featureHistorySize,mLowFeatureHistory:rows(),0,0):toVector()
	ffUp = mUpFeatureHistory:sub(mUpFeatureHistory:rows()-featureHistorySize,mUpFeatureHistory:rows(),0,0):toVector()
	cset.IDW:mapping(ffLow,target)
	cset2.IDW:mapping(ffUp..user_control,target2)

	local Lowpose, curColumn= PoseVectorToPose(target)
	local Lowdpose, curColumn= PoseVectorToDPose(target, curColumn)

	local Uppose, curColumn2= PoseVectorToPose(target2)
	local Updpose, curColumn2= PoseVectorToDPose(target2, curColumn2)

	local pose={}
	local dpose={}

	pose.pelvisOffset = Lowpose.pelvisOffset
	pose.jointAngles = Lowpose.jointAngles:range(0,3*lowerindexNum)..
					Uppose.jointAngles:range(3*lowerindexNum,Uppose.jointAngles:size())
	dpose.pelvisOffset=Lowdpose.pelvisOffset
	dpose.rotY = Lowdpose.rotY
	dpose.rootXZ=Lowdpose.rootXZ
	dpose.jointAngles=Lowdpose.jointAngles:range(0,3*lowerindexNum)..
					Updpose.jointAngles:range(3*lowerindexNum,Updpose.jointAngles:size())
					
	-- regression 결과가 pose, dpose
	if false then
			pose=extract_pose(mMotionDOFcontainer2, tempframe+startFrame)
			dpose=extract_dpose(mMotionDOFcontainer2, tempframe+startFrame)
	end

	-- regression결과에 없는 정보(위치-dependent components)는 State에서 카피.
	pose.rotY=mState.pose.rotY:copy()
	pose.rootXZ=mState.pose.rootXZ:copy()

	local nextpose
	if not isMove then
		mState.pose=integratePose2(mState.pose, dpose)
		nextpose=integratePose2(pose, dpose)
	else
		-- 현재 포즈를 예측된 속도로 적분.
		mState.pose=integratePose(mState.pose, dpose)
		-- obtain next pose
		-- 예측된 포즈를 예측된 속도로 적분.
		nextpose=integratePose(pose, dpose)
	end
	
	-- blend two guessed poses.
	local out	
	out=vectorn(mMotionDOFcontainer2.mot:row(0):size())
	mLoader2.dofInfo:blend(out, recoverRawPose(mState.pose), recoverRawPose(nextpose), poseIntegrationAlpha)
	
	mState.raw_pose=out
	mState.pose.jointAngles:assign(out:range(7,out:size()))
	mState.pose.pelvisOffset, mState.pose.rotY=extract_pelvisOffset(out)
--	mState.pose.rootXZ=out:toVector3(0)
	mState.dpose=dpose

	return out,mState
end

function EVR:_attachCamera(curPos)
	self.cameraInfo.vpos=RE.viewpoint().vpos-curPos
	self.cameraInfo.vat=RE.viewpoint().vat-curPos
	self.cameraInfo.dist=RE.viewpoint().vpos:distance(curPos)
end
function EVR:attachCamera(mot, offset)

	if mLoader~=nill then
		local discont=mMotionDOFcontainer.discontinuity
		local mMotionDOF=mot
		self.trajectory=matrixn(mMotionDOFcontainer:numFrames(),3)

		self.trajectoryOri=matrixn(mMotionDOFcontainer:numFrames(),4)
		local segFinder=SegmentFinder(discont)

		for i=0, segFinder:numSegment()-1 do
			local s=segFinder:startFrame(i)
			local e=segFinder:endFrame(i)

			for f=s,e-1 do
				if offset then
					self.trajectory:row(f):setVec3(0, MotionDOF.rootTransformation(mMotionDOF:row(f)).translation+offset)
				else
					self.trajectory:row(f):setVec3(0, MotionDOF.rootTransformation(mMotionDOF:row(f)).translation)
				end

				self.trajectory:row(f):set(1,0)
				self.trajectoryOri:row(f):setQuater(0, MotionDOF.rootTransformation(mMotionDOF:row(f)).rotation:rotationY())
			end
			print("filtering",s,e)
			math.filter(self.trajectory:range(s,e,0, 3), 63)
			math.filter(self.trajectoryOri:range(s,e,0, 4), 63)
		end

		local curPos=self.trajectory:row(self.currFrame):toVector3(0)*100
		self:_attachCamera(curPos)
		self.cameraInfo.refRot=self.trajectoryOri:row(self.currFrame):toQuater(0):rotationY()
	end
end

function frameMove(fElapsedTime)
	if tracking then
		nuiListener:waitUpdate()
		drawSkeletonJoints()
		--limbik()
	end
end

function detachSkins()
	if RE.motionPanelValid() then
		if mSkin then
			RE.motionPanel():motionWin():detachSkin(mSkin)
			RE.motionPanel():motionWin():detachSkin(mSkin2)

			mSkin=nil
			mSkin2=nil
		end
	end
	-- remove objects that are owned by LUA
	collectgarbage()
end

function getFeatureSize()
	return mMotionDOFcontainer:row(0):size()
end
function getPoseVectorSize()
	return mMotionDOFcontainer:row(0):size()
end
function extractFeatureVector(pose, dpose)
	local v=vectorn(7+pose.jointAngles:size())
	assert(v:size()==getFeatureSize())
	local c=0
	v:range(c, c+3):assign(pose.pelvisOffset.translation)
	v:range(c+3,c+7):assign(pose.pelvisOffset.rotation)
	v:range(c+7, v:size()):assign(pose.jointAngles)
	return v
end
function PoseToVector(pose)
	-- currently identical to feature vector, but it doesn't have to be.
	local v=vectorn(7+pose.jointAngles:size())
	assert(v:size()==getPoseVectorSize())
	local curCol=0
	v:setTransf(0, pose.pelvisOffset)
	curCol=curCol+7
	v:range(curCol, v:size()):assign(pose.jointAngles)
	return v
end
-- 위함수의 역함수
function PoseVectorToPose(v)
	local pose={}
	pose.pelvisOffset= v:toTransf(0)
	pose.jointAngles=v:range(7, getPoseVectorSize()):copy()
	return pose, getPoseVectorSize()
end
function DposeToVector(dpose)
	local v=vectorn(7+dpose.jointAngles:size())
	v:setVec3(0,dpose.pelvisOffset.translation) -- 
	v:set(0, dpose.rootXZ.x)
	v:set(2, dpose.rootXZ.z)
	v:setVec3(3,dpose.pelvisOffset.rotation)
	v:set(6,dpose.rotY)
	v:range(7, 7+dpose.jointAngles:size()):assign(dpose.jointAngles)
	return v 
end
function PoseVectorToDPose(v, startColumn)
	local dpose={}
	local vv=v:toVector3(startColumn)
	local ww=v:toVector3(startColumn+3)
	dpose.pelvisOffset={
		rotation=ww,
		translation=vv}
	dpose.rotY=v(startColumn+6)
	dpose.rootXZ=dpose.pelvisOffset.translation:copy()
	dpose.pelvisOffset.translation.x=0
	dpose.rootXZ.y=0
	dpose.pelvisOffset.translation.z=0
	dpose.jointAngles=v:range(startColumn+7, startColumn+7+getPoseVectorSize()-7)
	return dpose, startColumn+7+getPoseVectorSize()-7
end

function integratePose(pose, dpose)
	local out=deepCopyTable(pose)
	local dt=1/input.motionFrameRate
	local dq=quater()
	dq:setRotation(dpose.pelvisOffset.rotation)
	out.pelvisOffset.rotation:mult(dq, out.pelvisOffset.rotation)
	out.pelvisOffset.rotation:normalize()
	out.pelvisOffset.translation:radd(dpose.pelvisOffset.translation)
	assert(dpose.pelvisOffset.translation.x==0)
	out.jointAngles:radd(dpose.jointAngles*dt)
	if pose.rotY then
		assert(dpose.rotY)
		assert(out.rootXZ)
		out.rotY:leftMult(quater(dpose.rotY, vector3(0,1,0)))
		local dv=dpose.rootXZ
		dv.y=0
		dv:rotate(out.rotY)
		out.rootXZ:radd(dv)
	end
	return out
end

--unlikely integratePose, integratePose2 deleted part of pelvisoffset
function integratePose2(pose, dpose)
	local out=deepCopyTable(pose)
	local dt=1/input.motionFrameRate
	local dq=quater()
--	dq:setRotation(dpose.pelvisOffset.rotation)
--	out.pelvisOffset.rotation:mult(dq, out.pelvisOffset.rotation)
--	out.pelvisOffset.rotation:normalize()
--	out.pelvisOffset.translation:radd(dpose.pelvisOffset.translation)
--	assert(dpose.pelvisOffset.translation.x==0)
	out.jointAngles:radd(dpose.jointAngles*dt)
	--[[
	if pose.rotY then
		assert(dpose.rotY)
		assert(out.rootXZ)
		out.rotY:leftMult(quater(dpose.rotY, vector3(0,1,0)))
		local dv=dpose.rootXZ
		dv.y=0
		dv:rotate(out.rotY)
		out.rootXZ:radd(dv)
	end
	]]
	return out
end

function recoverRawPose(pose)
	local raw_pose=vectorn(pose.jointAngles:size()+7)
	local roottf=transf()
	local qy=quater()
	local qo=quater()
	-- discard rotY component (if any. 아마도 rotY성분 거의 없을꺼지만, 혹시 몰라서...)
	pose.pelvisOffset.rotation:decompose(qy, qo)
	roottf.rotation:mult(pose.rotY, qo)
	roottf.translation:assign(pose.rootXZ)
	roottf.translation.y=pose.pelvisOffset.translation.y
	MotionDOF.setRootTransformation(raw_pose, roottf)
	raw_pose:range(7, raw_pose:size()):assign(pose.jointAngles)
	return raw_pose
end

function extractControlInput(motdof, i)
	local delta=0
	local dist=0
	local prevRotY=motdof.mot:row(i):toQuater(3):rotationY()
	for ii=1, featureHistorySize do
		if i+ii>=motdof:numFrames() or motdof.discontinuity(i+ii) then
			return nil
		end

		local cRotY=motdof.mot:row(i+ii):toQuater(3):rotationY()
		local qdelta=quater()
		qdelta:difference(prevRotY, cRotY)
		dist=dist+motdof.mot:row(i+ii-1):toVector3(0):distance(motdof.mot:row(i+ii):toVector3(0))
		delta=delta+qdelta:rotationAngleAboutAxis(vector3(0,1,0))
		prevRoty=cRotY
	end
	return CT.vec(delta, dist)
end

function extractControlInput2(motdof,motdof2,i)
	if not boneArr then
		boneArr={'LeftCollar','LeftShoulder','LeftElbow','LeftWrist',}
	end

	local angle = {}
	mLoader:setPoseDOF(motdof.mot:row(i))

	local delta,delta2--control input value
	delta=0;delta2=0;
	
	local function getAxis(bone,bone2,bone3)
	-- A:collar ,B:shoulder ,C:elbow(..for example)
		local A=mLoader:getBoneByName(bone):getFrame():toGlobalPos(vector3(0,0,0))
		local B=mLoader:getBoneByName(bone2):getFrame():toGlobalPos(vector3(0,0,0))
		local C=mLoader:getBoneByName(bone3):getFrame():toGlobalPos(vector3(0,0,0))

		local p = A-B
		local prevVec = C-B
	--	angle[1] = math.acos((p.x*q.x+p.y*q.y+p.z*q.z)/(p:length()*q:length()))--(m_real)ACOS( (a%b)/(len(a)*len(b)) );
		local Axis = vector3()
		Axis:cross(p,prevVec)--A~B~C axis -- collar~shoulder~elbow axis
		
		return Axis,prevVec
	end

	do 
		local prevAxis,prevVec = getAxis(boneArr[1],boneArr[2],boneArr[3])
		local prevAxis2,prevVec2 = getAxis(boneArr[2],boneArr[3],boneArr[4])

		for ii=1,featureHistorySize do
			if i+ii>=motdof:numFrames() or motdof.discontinuity(i+ii) then
				return nil
			end
			-- first delta(delta1) 
			mLoader:setPoseDOF(motdof.mot:row(i+ii))
			local currAxis,currVec=getAxis(boneArr[1],boneArr[2],boneArr[3])
			local qdelta = quater()

			qdelta:axisToAxis(prevVec,currVec)	 --axisToAxis(vfrom,vto)
			delta = delta+qdelta:rotationAngleAboutAxis(currAxis)
			prevVec = currVec 
			
			--second delta (delta2)
			local currAxis2,currVec2=getAxis(boneArr[2],boneArr[3],boneArr[4])
			local qdelta2 = quater()

			qdelta2:axisToAxis(prevVec2,currVec2)	 --axisToAxis(vfrom,vto)
			delta2 = delta2+qdelta2:rotationAngleAboutAxis(currAxis2)
			prevVec2 = currVec2
		end
	end

	mLoader:setPoseDOF(motdof.mot:row(0))
--	return CT.vec(delta, dist)
--	return CT.vec(angle[1],angle[2])
	return CT.vec(delta,delta2)
end
function extractControlInput3(motdof,mot)
	if not boneArr then
		boneArr={'LeftCollar','LeftShoulder','LeftElbow','LeftWrist',}
	end

	local angle = {}
	mLoader:setPoseDOF(mFeatureHistory:row(mFeatureHistory:rows()-featureHistorySize))

	local delta,delta2--control input value
	delta=0;delta2=0;
	
	local function getAxis(bone,bone2,bone3)
	-- A:collar ,B:shoulder ,C:elbow(..for example)
		local A=mLoader:getBoneByName(bone):getFrame():toGlobalPos(vector3(0,0,0))
		local B=mLoader:getBoneByName(bone2):getFrame():toGlobalPos(vector3(0,0,0))
		local C=mLoader:getBoneByName(bone3):getFrame():toGlobalPos(vector3(0,0,0))

		local p = A-B
		local prevVec = C-B
	--	angle[1] = math.acos((p.x*q.x+p.y*q.y+p.z*q.z)/(p:length()*q:length()))--(m_real)ACOS( (a%b)/(len(a)*len(b)) );
		local Axis = vector3()
		Axis:cross(p,prevVec)--A~B~C axis -- collar~shoulder~elbow axis
		
		return Axis,prevVec
	end

	do 
		local prevAxis,prevVec = getAxis(boneArr[1],boneArr[2],boneArr[3])
		local prevAxis2,prevVec2 = getAxis(boneArr[2],boneArr[3],boneArr[4])

		for ii=1,featureHistorySize do
			-- first delta(delta1) 
			local vec
			if ii~=featureHistorySize then 
				vec=mFeatureHistory:row(mFeatureHistory:size()-featureHistorySize+ii)
			else
				vec=mot
			end
			mLoader:setPoseDOF(vec)
			local currAxis,currVec=getAxis(boneArr[1],boneArr[2],boneArr[3])
			local qdelta = quater()

			qdelta:axisToAxis(prevVec,currVec)	 --axisToAxis(vfrom,vto)
			delta = delta+qdelta:rotationAngleAboutAxis(currAxis)
			prevVec = currVec 
			
			--second delta (delta2)
			local currAxis2,currVec2=getAxis(boneArr[2],boneArr[3],boneArr[4])
			local qdelta2 = quater()

			qdelta2:axisToAxis(prevVec2,currVec2)	 --axisToAxis(vfrom,vto)
			delta2 = delta2+qdelta2:rotationAngleAboutAxis(currAxis2)
			prevVec2 = currVec2
		end
	end

	mLoader:setPoseDOF(motdof.mot:row(0))
--	return CT.vec(delta, dist)
--	return CT.vec(angle[1],angle[2])
	return CT.vec(delta,delta2)
end
Timeline=LUAclass(LuaAnimationObject)
function Timeline:__init(label, totalTime)
	self.totalTime=totalTime
	self:attachTimer(1/60, totalTime)		
	RE.renderer():addFrameMoveObject(self)
	RE.motionPanel():motionWin():addSkin(self)
end
