require("config")

package.projectPath='../Samples/classification/'
package.path=package.path..";../Samples/classification/lua/?.lua" --;"..package.path
require("common")
require("module")
require("moduleIK")


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

function ctor()
--[[
	local data = vectorn()
	data:setSize(9)
	for i=0, data:size()-1 do
		data:set(i,i+1)
		print(data(i))
	end
	local test = vector3N(1)
	test(0):assign(data:toVector3(3)) 
	print(test)
]]

	mot = loadMotion(social_p[1].skel,social_p[1].mot,nil,nil)
	mLoader = mot.loader
	mSkin = mot.skin
	mMotionDOFcontainer=mot.motionDOFcontainer
	mMotionDOF=mMotionDOFcontainer.mot

	mSkin= RE.createVRMLskin(mLoader, false);
	mSkin:scale(1,1,1);
	mSkin:setPoseDOF(mMotionDOF:row(0));

	mSkin:applyMotionDOF(mMotionDOF)
	mSkin:setFrameTime(1/120)
	RE.motionPanel():motionWin():detachSkin(mSkin)
	RE.motionPanel():motionWin():addSkin(mSkin)

	mot2 = loadMotion(social_p[2].skel,social_p[2].mot,nil,nil)
	mLoader2 = mot2.loader
	mSkin2 = mot2.skin
	mMotionDOFcontainer2=mot2.motionDOFcontainer
	mMotionDOF2=mMotionDOFcontainer2.mot

	mSkin2= RE.createVRMLskin(mLoader, false);
	mSkin2:scale(1,1,1);
	mSkin2:setPoseDOF(mMotionDOF2:row(0));

	mSkin2:applyMotionDOF(mMotionDOF2)
	mSkin2:setFrameTime(1/120)
	RE.motionPanel():motionWin():detachSkin(mSkin2)
	RE.motionPanel():motionWin():addSkin(mSkin2)

	this:create('Button', 'attach motion to UI', 'attach motion to UI')
	this:create('Button', 'start game loop', 'start game loop')
	this:updateLayout()

	g_gameLoopStarted=false
end

function dtor()
	RE.motionPanel():motionWin():detachSkin(mSkin)
end

function handleRendererEvent(ev, button, x, y)
	return 0
end

function onCallback(w, userData)
	if w:id()=='attach motion to UI' then
		mSkin:applyMotionDOF(mMotionDOF)
		mSkin:setFrameTime(1/120)
		RE.motionPanel():motionWin():addSkin(mSkin)
	elseif w:id()=='start game loop' then
		RE.motionPanel():motionWin():detachSkin(mSkin) -- detach from UI if connected already.
		g_gameLoopStarted=true
	end
end

elapsedTime=0
			
function frameMove(fElapsedTime)
	if g_gameLoopStarted then
		elapsedTime=elapsedTime+fElapsedTime
		local currFrame=math.round(elapsedTime*120) -- assuming 120hz

		--mLoader:setPoseDOF(mMotionDOF:row(currFrame))
		mSkin:setPoseDOF(mMotionDOF:row(currFrame))
		mSkin2:setPoseDOF(mMotionDOF2:row(currFrame))
	end
end
