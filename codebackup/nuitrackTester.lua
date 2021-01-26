require("config")
require("module")
require("common")

start = false
tracking = false

function ctor()
	--UI init
	this:create("Button", "Start Nuitrack", "Start Nuitrack")
	this:widget(0):buttonShortcut("s")
	this:create("Check_Button", "Tracking", "Tracking")
	this:widget(0):checkButtonValue(false)
	this:widget(0):buttonShortcut("t")
	this:create("Button", "Load Stick_Human", "Load Stick_Human")
	this:widget(0):buttonShortcut("l")
	this:create("Button", "Check Viewpoint", "Check Viewpoint")
--	this:create("Check_Button", "drawAxes", "drawAxes")
--	this:widget(0):checkButtonValue(false)

	this:updateLayout()
	
	--camera init
	RE.viewpoint().vpos:set(0, 238, 334)
	RE.viewpoint().vat:set(9, 109, 15)
	RE.viewpoint():update()

	nuiListener = NuiListener()
	
--	dbg.namedDraw("Axes", transf(quater(1,0,0,0), vector3(0,0,100)), "axes")
--	dbg.namedDraw("Sphere", vector3(0,0,0), "O", "red", 5)
end

real = vector3()
function drawSkeleton()--ToDo: 실제 그려지는 ball은 19개. collar가 문제인듯.
	if nuiListener:isTracking() then
		for i=0, 23 do
			real.x = nuiListener:getJointRealCoords(i,0)/10
			real.y = nuiListener:getJointRealCoords(i,1)/10 + 100
			real.z = nuiListener:getJointRealCoords(i,2)/10
			if not(i==9 or i==15 or i==19 or i==23) then
				dbg.draw("Sphere", real, "ball"..i, "blue", 5)
			end
		end
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
	elseif w:id()=="Load Stick_Human" then
		mLoader=MainLib.VRMLloader ("../../taesooLib/Resource/motion/locomotion_hyunwoo/hyunwoo_lowdof_T.wrl")
		mSkin = RE.createVRMLskin(mLoader, false)
		mSkin:scale(100,100,100)
		mSkin:setTranslation(0,0,0)
		mLoader:printHierarchy()
--	elseif w:id()=="drawAxes" then
--		if w:checkButtonValue() then
--			dbg.namedDraw("Axes", transf(quater(1,0,0,0), vector3(0,0,100)), "axes")
--		else
--			dbg.erase("Axes", "axes")
--		end
	end
end

function frameMove(fElapsedTime)
	if tracking then
		nuiListener:waitUpdate()
		drawSkeleton()
	end
end

function dtor()
end
