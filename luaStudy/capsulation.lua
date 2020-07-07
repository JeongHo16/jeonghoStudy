
function NewInstanceFigure(agWidth, agHeight)

	local this = {width = agWidth, height = agHeight}

	local calculate = 
	function()
		return this.width * this.height
	end

	local getWidth = function() return this.width end
	local getHeight = function() return this.height end

	local getWidthAndHeight = 
	function()
		return getWidth(), getHeight()
	end

	return{
		Calculate= calculate,
		GetWidthAndHeight = getWidthAndHeight
	}
end

function
