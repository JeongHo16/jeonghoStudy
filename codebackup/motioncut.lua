function cutStartFrame(motion, startFrame)
    for i=startFrame,motion:rows()-1 do
	motion:row(i-startFrame):assign(motion:row(i));
	end
    motion:resize(motion:numFrames()-startFrame)

    mMotionDOFcontainer.mot:assign(motion)
	mSkin:applyMotionDOF(mMotionDOFcontainer.mot)
	RE.motionPanel():motionWin():addSkin(mSkin)
end
--cut motion frame until endFrame
--i.e) if endFrame = 900, entire num of frame = 1,000
--motion dof file is resampled to 0~900
function cutEndFrame(motion, endFrame)
    motion:resize(endFrame)
    mMotionDOFcontainer.mot:assign(motion)
	mSkin:applyMotionDOF(mMotionDOFcontainer.mot)
	RE.motionPanel():motionWin():addSkin(mSkin)
end
--cut num of endFrame from 0 to endFrame
--i.e) if endFrame = 200, entire num of frame = 1,000
--motion dof file is resampled to 0~800
function cutEndFrame2(motion, endFrame)
    motion:resize(motion:rows()-endFrame)
    mMotionDOFcontainer.mot:assign(motion)
	mSkin:applyMotionDOF(mMotionDOFcontainer.mot)
	RE.motionPanel():motionWin():addSkin(mSkin)
end

function modExport(motioncontainer,file_name,directory)
	motioncontainer:exportMot(directory..file_name)
	print('motion file exporting done!!!')
	print('please check file in',directory..file_name)
end
