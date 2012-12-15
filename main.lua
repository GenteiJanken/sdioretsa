--[[
		main.lua - main loop and callbacks for SDIORETSA
		
		A game for Ludum Dare 25 by Josh Douglass-Molloy
		
		Released under the MIT License
]]--
require("jmaths")

function love.load()
	entities = {1}
	UNIVERSE_WIDTH = 1000
	UNIVERSE_HEIGHT = 1000
	ASTEROID_SIZES = {10, 20, 40, 80}
	asteroidpow = 4
	love.graphics.setColor(255, 255, 255)
	love.graphics.setBackgroundColor(0,0,0)
end

function love.update(dt)
-- update motion, wrap around screen if applicable
--	for i =1, #entities do
	--	moveEntity(entities[i])
--end
end

function love.draw()
	
end

--draws an equilateral triangle centered on a 2d point
-- l defines the length of a side
function drawTriangle(x, y, l, rot)
	h = sqrt(3)/2*l
	--vertices: top, left, right
	verts = {x, y + h/2, x - l/2, y - h/2, x + l/2, y - h/2}  
	--rotate triangle around centre
	love.graphics.polygon('line', verts)
end
--[[
	SHOOTAN ASTEROIDS
	Player has an asterbar, divided into quarters: 
		-4 bars allow the launching of a giant asteroid 
		-3 bars allow the launching of a large asteroid (giant/2)
		-2 bars allow the launching of a medium asteroid (large/2)
		-1 bars allow the launching of a small asteroid (medium/2)
	When destroyed, an asteroid will yield two asteroids of the next largest size
]]--
--creates the geometry of an asteroid and endows it with direction - a janky polygon (octogon)
function makeAsteroids(size, direction)
--make an octogon with length size on a side, moving in direction 

--randomise points slightly to create natural look

end

