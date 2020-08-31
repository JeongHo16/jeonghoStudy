require("config")
require("module")
require("moduleIK")
require("common")
--require("RigidBodyWin/subRoutines/MultiConstraints")
require("RigidBodyWin/subRoutines/Constraints")

config = {
	"../Resource/jae/social_p1/social_p1.wrl",
	"../Resource/jae/social_p1/social_p1.bvh",
	{--bone 이름 확인-ok.
		{'Neck', 'Head', vector3(0,0,0), reversed=false},--0
		{'LeftElbow', 'Leftwrist', vector3(0,0,0), reversed=false},--7
		{'RightElbow', 'Rightwrist', vector3(0,0,0), reversed=false},--13
		{'LeftKnee', 'LeftAnkle', vector3(0, 0, 0), reversed=false},--18
		{'RightKnee', 'RightAnkle', vector3(0, 0, 0), reversed=false},--22
	},
	skinScale=1
}

function ctor()
	--UI init
	this:create("Button", "Start Nuitrack", "Start Nuitrack")
	this:widget(0):buttonShortcut("s")
	this:create("Check_Button", "Tracking", "Tracking")
	this:widget(0):checkButtonValue(false)
	this:widget(0):buttonShortcut("t")
	this:create("Button", "Check Viewpoint", "Check Viewpoint")
	this:create("Check_Button", "drawAxes", "drawAxes")
	this:widget(0):checkButtonValue(false)

	this:updateLayout()
	
	--camera init
	RE.viewpoint().vpos:set(0, 238, 334)
	RE.viewpoint().vat:set(9, 109, 15)
	RE.viewpoint():update()

	nuiListener = NuiListener()

	start = false
	tracking = false
	
	mLoader = MainLib.VRMLloader(config[1])
--	mLoader:Scale(0.8)

--	mMotionDOFcontainer = MotionDOFcontainer(mLoader.dofInfo, config[2])
--	mMotionDOF = mMotionDOFcontainer.mot

--	mMot=loadMotion(config[1], config[2])
--	mLoader=mMot.loader
	
--	mMotionDOF = mMot.motionDOFcontainer 

	mSkin = RE.createVRMLskin(mLoader, true)
	mSkin:scale(1,1,1)
	mSkin:setTranslation(0,108,0)

	mPose = vectorn()--제대로 초기화-bvh불러와서 했는데 dof인지 아닌지 모르겠음
	mLoader:getPoseDOF(mPose)
	mSkin:setPoseDOF(mPose)

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
	--mCON:connect(eventFunction)

--	for i=0, mLoader:numBone()-1 do
--		print(mLoader:bone(i))
--		local pos = mLoader:getBoneByTreeIndex(i):getFrame().translation + vector3(0, 108, 0)
--		--dbg.namedDraw("Sphere", pos, tostring(mLoader:bone(i)), "red", 3)
--		--if tostring(mLoader:bone(i))=="Hips" then
--			dbg.draw("Sphere", pos, tostring(mLoader:bone(i)), "red", 3)
--		--end
--	end

--	conNeckLen=mLoader:getBoneByName("Neck"):getFrame().translation:distance(mLoader:getBoneByName("Head"):getFrame().translation)
--	conLegLen=mLoader:getBoneByName("RightHip"):getFrame().translation:distance(mLoader:getBoneByName("RightKnee"):getFrame().translation)+
--	mLoader:getBoneByName("RightKnee"):getFrame().translation:distance(mLoader:getBoneByName("RightAnkle"):getFrame().translation)
--	conArmLen=mLoader:getBoneByName("RightShoulder"):getFrame().translation:distance(mLoader:getBoneByName("RightElbow"):getFrame().translation)+
--	mLoader:getBoneByName("RightElbow"):getFrame().translation:distance(mLoader:getBoneByName("RightWrist"):getFrame().translation)
end

function dtor()
end

function frameMove(fElapsedTime)
	if tracking then
		nuiListener:waitUpdate()
		--drawSkeleton()
		limbik()
	end
end

function onCallback(w, userData)
	if w:id()=="Start Nuitrack" then
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
	elseif w:id()=="Check Viewpoint" then
		print(RE.viewpoint().vpos)
		print(RE.viewpoint().vat)
	elseif w:id()=="drawAxes" then
		if w:checkButtonValue() then
			dbg.namedDraw("Axes", transf(quater(1,0,0,0), vector3(0,0,100)), "axes")
		else
			dbg.erase("Axes", "axes")
		end
	end
end

function handleRendererEvent(ev, button, x,y) 
	if mCON then
		return mCON:handleRendererEvent(ev, button, x,y)
	end
	return 0
end

function conPosUpdate()
	local s=1.3
	mCON.conPos(0):assign(getJointPos(0)*s)
	mCON.conPos(1):assign(getJointPos(7)*s)
	mCON.conPos(2):assign(getJointPos(13)*s)
	mCON.conPos(3):assign(getJointPos(18)*s)
	mCON.conPos(4):assign(getJointPos(22)*s)
	mCON.conPos(5):assign(getJointPos(3)*s)

--	mCON.conPos(0):assign(getJointPos(0))
--	mCON.conPos(1):assign(getJointPos(7))
--	mCON.conPos(2):assign(getJointPos(13))
--	mCON.conPos(3):assign(getJointPos(18))
--	mCON.conPos(4):assign(getJointPos(22))
--	mCON.conPos(5):assign(getJointPos(3))
	mCON:drawConstraints()
end

--function getNuiLen()
--	local neck=getJointPos(1):distance(getJointPos(0))
--	local armLen=getJointPos(5):distance(getJointPos(6))+getJointPos(6):distance(getJointPos(7))
--	local legLen=getJointPos(16):distance(getJointPos(17))+getJointPos(17):distance(getJointPos(18))
--	return neck, armLen, legLen
--end

function drawSkeleton()--ToDo: 실제 그려지는 ball은 19개. collar가 문제인듯.
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
	local numCon=#config
	mEffectors:resize(numCon);
	out.effectors=mEffectors
	out.numCon=numCon

	for i=0, numCon-1 do
		local conInfo=config[i+1]
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
		originalPos = originalPos + vector3(0, -108, 0)
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
	mSkin:setPoseDOF(mPose);
end

function eventFunction()
	limbik()
end
