KinectTrackerFromFile=LUAclass()
KinectTrackerToFile=LUAclass()

function KinectTrackerFromFile:__init(stateFile, dataFile, numFrames)
	f=util.BinaryFile()
	f2=util.BinaryFile()
	f:openRead(stateFile)
	f2:openRead(dataFile)
	--local trackingState=intmatrixn();
	--local skeletonData=matrixn();
	local trackingState=intvectorn();
	local skeletonData=vectorn();
	f:unpack(trackingState)
	f2:unpack(skeletonData)
	--f:close()
	--f2:close()
	self.curr_frame=0
	numFrames=numFrames-20 -- i don't know why
	self.numFrames=numFrames 

	self.matTrackingState=intmatrixn()
	self.matTrackingState:resize(self.numFrames, NUI_SKELETON_POSITION_COUNT+1)
	self.matTrackingData=matrixn(self.numFrames, NUI_SKELETON_POSITION_COUNT*3)
	local function setData(i, trackingState, skeletonData)
		if trackingState:size()==1 then
			self.matTrackingState:row(i):set(0, trackingState(0))
		else
			self.matTrackingState:row(i):assign(trackingState)
			self.matTrackingData:row(i):assign(skeletonData)
		end
	end
	setData(0, trackingState, skeletonData)
	for i=1, numFrames-1 do
		local trackingState=intvectorn();
		local skeletonData=vectorn();
		f:unpack(trackingState)
		f2:unpack(skeletonData)

		print(i, numFrames)
		setData(i, trackingState, skeletonData)
	end
end

function KinectTrackerToFile:__init(filename )
	writeStateFile=util.BinaryFile()
	--writeStateFile:openWrite("kinect_state_gth.data")
	writeStateFile:openWrite(filename..'teststate.data')

	writeDataFile=util.BinaryFile()
	--writeDataFile:openWrite("kinect_data_gth.data")
	writeDataFile:openWrite(filename..'testdata.data')

	--self.trackingState=trackingState
	--self.skeletonData=skeletonData
	self.currFrame=0
end

function KinectTrackerToFile:close()
	writeStateFile:close()
	writeDataFile:close()
end
function KinectTrackerToFile:saveFeature(trackingState, skeletonData)
	writeStateFile:pack(trackingState)
	writeDataFile:pack(skeletonData)
end


function KinectTrackerFromFile:trackSkeleton(iframe)
	--	local i= self.currFrame
	--	if iframe then
	--		i=math.min(iframe, self.trackingState:rows()-1)
	--	end
	--	self.currFrame=math.min(i+1, self.trackingState:rows()-1)
	--	return self.trackingState:row(i), self.skeletonData:row(i)

	local trackingState=intvectorn();
	local skeletonData=vectorn();

	local curr_frame=self.curr_frame
	local num_frames=self.numFrames
	if (iframe>curr_frame and iframe < curr_frame+100 and curr_frame+1<num_frames and iframe<num_frames ) then -- this should be the same as that in KinectDevice.cpp
		curr_frame=curr_frame+1;
	else
		iframe=math.min(iframe, num_frames-1);
		curr_frame=iframe;
	end
	self.curr_frame=curr_frame
	trackingState:assign(self.matTrackingState:row(curr_frame))
	skeletonData:assign(self.matTrackingData:row(curr_frame))
	--f:unpack(trackingState)
	--f2:unpack(skeletonData)

	return  trackingState, skeletonData
end

function KinectTrackerFromFile:close()
end


KinectTrackerFromGUI=LUAclass()

function KinectTrackerFromGUI:__init(loader, initialPose)
	require("RigidBodyWin/subRoutines/Constraints")
	self.loader=loader
	if initialPose then
		self.initialPose=initialPose:copy()
	end
end

function KinectTrackerFromGUI:finalizeSourceMotion(mMap, mMot)
	local loader=self.loader
	if not loader then
		self.loader=mMot.loader
		loader=self.loader
	end
	if not self.initialPose then
		self.initialPose=mMot.motionDOFcontainer.mot:row(0):copy()
	end
	self.loader:setPoseDOF(self.initialPose)
	local rootPos=loader:bone(1):getFrame().translation:copy()
	self.deltas=vector3N(4)
	self.deltas(0):assign( rootPos-mMap.NUI_SKELETON_POSITION_HIP_RIGHT:getFrame().translation) 
	self.deltas(1):assign( rootPos-mMap.NUI_SKELETON_POSITION_HIP_LEFT:getFrame().translation) 
	self.deltas(2):assign( rootPos-mMap.NUI_SKELETON_POSITION_SHOULDER_RIGHT:getFrame().translation)
	self.deltas(3):assign( rootPos-mMap.NUI_SKELETON_POSITION_SHOULDER_LEFT:getFrame().translation) 
	self.deltas=self.deltas*(config.skinScale/config.kinectScale)

	local pos={
		rootPos*config.skinScale,
		mMap.NUI_SKELETON_POSITION_ANKLE_RIGHT:getFrame().translation:copy()*config.skinScale, 
		mMap.NUI_SKELETON_POSITION_ANKLE_LEFT:getFrame().translation:copy()*config.skinScale, 
		mMap.NUI_SKELETON_POSITION_WRIST_RIGHT:getFrame().translation:copy()*config.skinScale, 
		mMap.NUI_SKELETON_POSITION_WRIST_LEFT:getFrame().translation:copy()*config.skinScale,
	}
	self.CON=Constraints(unpack(pos))
end
function KinectTrackerFromGUI:trackSkeleton()
	local state=intvectorn(NUI_SKELETON_POSITION_COUNT+1)
	local data=vectorn(NUI_SKELETON_POSITION_COUNT*3)
	state:setAllValue(STATE_TRACKED)
	data:setAllValue(0)

	-- A : meter unit
	-- B : kinect unit
	-- C : cm unit == A*skinScale
	-- C==B*kinectScale+kinectPosOffset
	-- (C-kinectPosOffset)*(1/kinectScale) == B
	
	local pos=(self.CON.conPos-config.kinectPosOffset)*(1/config.kinectScale)
	data:setVec3(3*NUI_SKELETON_POSITION_HIP_CENTER, pos(0))
	data:setVec3(3*NUI_SKELETON_POSITION_ANKLE_RIGHT, pos(1))
	data:setVec3(3*NUI_SKELETON_POSITION_ANKLE_LEFT, pos(2))
	data:setVec3(3*NUI_SKELETON_POSITION_WRIST_RIGHT, pos(3))
	data:setVec3(3*NUI_SKELETON_POSITION_WRIST_LEFT, pos(4))
	data:setVec3(3*NUI_SKELETON_POSITION_HIP_RIGHT, pos(0)-self.deltas(0))
	data:setVec3(3*NUI_SKELETON_POSITION_HIP_LEFT, pos(0)-self.deltas(1))
	data:setVec3(3*NUI_SKELETON_POSITION_SHOULDER_RIGHT, pos(0)-self.deltas(2))
	data:setVec3(3*NUI_SKELETON_POSITION_SHOULDER_LEFT, pos(0)-self.deltas(3))


	if false then
		local v=vectorn(5*3)
		v:setVec3(3*0, pos(0)*config.kinectScale+config.kinectPosOffset+vector3(10,0,0))
		v:setVec3(3*1, pos(1)*config.kinectScale+config.kinectPosOffset+vector3(10,0,0))
		v:setVec3(3*2, pos(2)*config.kinectScale+config.kinectPosOffset+vector3(10,0,0))
		v:setVec3(3*3, pos(3)*config.kinectScale+config.kinectPosOffset+vector3(10,0,0))
		v:setVec3(3*4, pos(4)*config.kinectScale+config.kinectPosOffset+vector3(10,0,0))
		dbg.namedDraw("PointClouds", "featureKK", v, "redCircle", "Z")
		v:setSize(4*3)
		v:setVec3(3*0, pos(0)-self.deltas(0)+vector3(10,0,0))
		v:setVec3(3*1, pos(0)-self.deltas(1)+vector3(10,0,0))
		v:setVec3(3*2, pos(0)-self.deltas(2)+vector3(10,0,0))
		v:setVec3(3*3, pos(0)-self.deltas(3)+vector3(10,0,0))
		dbg.namedDraw("PointClouds", "featureK2", v, "blueCircle", "Z")
	end
	return state, data
end

-- needs to optimize a=0.65, b=0.87, 
function getMatrix_to3Dcoord(kinectScale)
	local to3Dcoord=matrix4()
	to3Dcoord:setValue(0.65,0,0,0,
	0,0.86,0,0,
	0,0,1,0,
	0,0,0,1)
	local s= kinectScale*0.00100*1.0
	to3Dcoord:leftMultScaling(s,s,s)
	to3Dcoord:leftMultTranslation(config.kinectPosOffset)
	return to3Dcoord
end

KinectTrackerFromDevice=LUAclass()

function KinectTrackerFromDevice:__init()
	require("RigidBodyWin/subRoutines/Constraints")
	self.nuiListener=NuiListener()
	self.nuiListener:startNuitrack()
	self.start = true 
	self.tracking = false
end

function KinectTrackerFromDevice:finalizeSourceMotion(mMap, mMot)
	local loader=self.loader
	if not loader then
		self.loader=mMot.loader
		loader=self.loader
	end
	if not self.initialPose then
		self.initialPose=mMot.motionDOFcontainer.mot:row(0):copy()
	end
	self.loader:setPoseDOF(self.initialPose)
	local rootPos=loader:bone(1):getFrame().translation:copy()
	self.deltas=vector3N(4)
	self.deltas(0):assign( rootPos-mMap.NUI_SKELETON_POSITION_HIP_RIGHT:getFrame().translation) 
	self.deltas(1):assign( rootPos-mMap.NUI_SKELETON_POSITION_HIP_LEFT:getFrame().translation) 
	self.deltas(2):assign( rootPos-mMap.NUI_SKELETON_POSITION_SHOULDER_RIGHT:getFrame().translation)
	self.deltas(3):assign( rootPos-mMap.NUI_SKELETON_POSITION_SHOULDER_LEFT:getFrame().translation) 
	self.deltas=self.deltas*(config.skinScale/config.kinectScale)

	local pos={
		rootPos*config.skinScale,
		mMap.NUI_SKELETON_POSITION_ANKLE_RIGHT:getFrame().translation:copy()*config.skinScale, 
		mMap.NUI_SKELETON_POSITION_ANKLE_LEFT:getFrame().translation:copy()*config.skinScale, 
		mMap.NUI_SKELETON_POSITION_WRIST_RIGHT:getFrame().translation:copy()*config.skinScale, 
		mMap.NUI_SKELETON_POSITION_WRIST_LEFT:getFrame().translation:copy()*config.skinScale,
	}
	self.CON=Constraints(unpack(pos))
end
function KinectTrackerFromDevice:trackSkeleton()
	local state=intvectorn(NUI_SKELETON_POSITION_COUNT+1)
	local data=vectorn(NUI_SKELETON_POSITION_COUNT*3)
	state:setAllValue(STATE_TRACKED)
	data:setAllValue(0)

	-- A : meter unit
	-- B : kinect unit
	-- C : cm unit == A*skinScale
	-- C==B*kinectScale+kinectPosOffset
	-- (C-kinectPosOffset)*(1/kinectScale) == B
	self:conposUpdateFromUser()	
	self.CON:drawConstraints()
	local pos=(self.CON.conPos-config.kinectPosOffset)*(1/config.kinectScale)
	data:setVec3(3*NUI_SKELETON_POSITION_HIP_CENTER, pos(0))
	data:setVec3(3*NUI_SKELETON_POSITION_ANKLE_RIGHT, pos(1))
	data:setVec3(3*NUI_SKELETON_POSITION_ANKLE_LEFT, pos(2))
	data:setVec3(3*NUI_SKELETON_POSITION_WRIST_RIGHT, pos(3))
	data:setVec3(3*NUI_SKELETON_POSITION_WRIST_LEFT, pos(4))
	data:setVec3(3*NUI_SKELETON_POSITION_HIP_RIGHT, pos(0)-self.deltas(0))
	data:setVec3(3*NUI_SKELETON_POSITION_HIP_LEFT, pos(0)-self.deltas(1))
	data:setVec3(3*NUI_SKELETON_POSITION_SHOULDER_RIGHT, pos(0)-self.deltas(2))
	data:setVec3(3*NUI_SKELETON_POSITION_SHOULDER_LEFT, pos(0)-self.deltas(3))
--	if self.tracking then
--		self:drawSkeletonJoints()
--	end
	
	if false then
		local v=vectorn(5*3)
		v:setVec3(3*0, pos(0)*config.kinectScale+config.kinectPosOffset+vector3(10,0,0))
		v:setVec3(3*1, pos(1)*config.kinectScale+config.kinectPosOffset+vector3(10,0,0))
		v:setVec3(3*2, pos(2)*config.kinectScale+config.kinectPosOffset+vector3(10,0,0))
		v:setVec3(3*3, pos(3)*config.kinectScale+config.kinectPosOffset+vector3(10,0,0))
		v:setVec3(3*4, pos(4)*config.kinectScale+config.kinectPosOffset+vector3(10,0,0))
		dbg.namedDraw("PointClouds", "featureKK", v, "redCircle", "Z")
		v:setSize(4*3)
		v:setVec3(3*0, pos(0)-self.deltas(0)+vector3(10,0,0))
		v:setVec3(3*1, pos(0)-self.deltas(1)+vector3(10,0,0))
		v:setVec3(3*2, pos(0)-self.deltas(2)+vector3(10,0,0))
		v:setVec3(3*3, pos(0)-self.deltas(3)+vector3(10,0,0))
		dbg.namedDraw("PointClouds", "featureK2", v, "blueCircle", "Z")
	end
	return state, data
end

function KinectTrackerFromDevice:drawSkeletonJoints()--ToDo: 실제 그려지는 ball은 19개. collar가 문제인듯.
	for i=0, 23 do
--		if not(i==9 or i==15 or i==19 or i==23) then
		if (i==3 or i==7 or i==13 or i==18 or i==22) then
			dbg.draw("Sphere", self:getJointPos(i) - self:getDistance(), "ball"..i, "red", 3)
		end
	end
end

function KinectTrackerFromDevice:getJointPos(idx)
	local pos = vector3()
	--pos.x = self.nuiListener:getJointRealCoords(idx,1)/10
	--pos.y = self.nuiListener:getJointRealCoords(idx,1)/10 + 130
	--pos.z = -self.nuiListener:getJointRealCoords(idx,2)/10 --지금 카메라각도에서 wrl과 맞추기 위해 -1x
	pos.x = self.nuiListener:getJointRealCoords(idx,2)/10
	--pos.y = self.nuiListener:getJointRealCoords(idx,1)/10+130
	pos.y = self.nuiListener:getJointRealCoords(idx,1)/10
	pos.z = self.nuiListener:getJointRealCoords(idx,0)/10
	return pos
end

function KinectTrackerFromDevice:getDistance()
	local userRoot = self:getJointPos(3)
	local skinRoot = self.CON.conPos(0)
	local distance = vector3()
	distance = userRoot-skinRoot
	return distance 
end

function KinectTrackerFromDevice:conposUpdateFromUser()
	self.CON.conPos(0):assign(self:getJointPos(3)-self:getDistance())
	self.CON.conPos(1):assign(self:getJointPos(22)-self:getDistance())
	self.CON.conPos(2):assign(self:getJointPos(18)-self:getDistance())
	self.CON.conPos(3):assign(self:getJointPos(13)-self:getDistance())
	self.CON.conPos(4):assign(self:getJointPos(7)-self:getDistance())
end
