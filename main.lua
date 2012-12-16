--[[
		main.lua - main loop and callbacks for SDIORETSA
		
		A game for Ludum Dare 25 by Josh Douglass-Molloy
		
		Released under the MIT License
]]--
local jmaths = require "jmaths" 

function love.load()

	poss_states = {"GAME", "SPAWN"}
	game_state = poss_states[1]
	asteroids = {}
	bullets = {}
	UNIVERSE_WIDTH = 1000
	UNIVERSE_HEIGHT = 1000
	ASTEROID_SIZES = {small = 10, medium = 20, large = 40, huge = 80}
	asteroidpow = 4
	love.graphics.setColor(255, 255, 255)
	love.graphics.setBackgroundColor(0,0,0)
	testeroids = {
		makeAsteroids({400, 400}, ASTEROID_SIZES.huge, -1),
		makeAsteroids({200, 200}, ASTEROID_SIZES.medium, -1),
		makeAsteroids({800, 800}, ASTEROID_SIZES.large, -1),	
		makeAsteroids({100, 100}, ASTEROID_SIZES.small, -1)
	}
	
	ship = {
		pos = {x = UNIVERSE_WIDTH/2, y = UNIVERSE_HEIGHT/2},
		velocity = {0.0, 0.0},
		maxspeed = magni(10.0, 10.0),
		rot = 0,
		accel = 0.0	
	}

end

function love.update(dt)
--accept input from mouse and keyboard
	if love.keyboard.isDown("left") then
		ship.rot = canMod(ship.rot + 100 * dt, 360)
	elseif love.keyboard.isDown("right") then
		ship.rot = canMod(ship.rot - 100 * dt, 360)
	elseif love.keyboard.isDown("up") then
		ship.accel = 0.5
		
		
	end
-- update motion, wrap around screen if applicable
--	for i =1, #entities do
	--	moveEntity(entities[i])
--end
moveShip()
end

function love.draw()
	--draws ship
	drawShip()
	
	for i = 1, #testeroids do
		drawPoly(testeroids[i].verts)
	end
	
end

function drawShip()
	drawTriangle(ship.pos.x, ship.pos.y, 30, ship.rot)
end



function moveShip(dt)
	ship.velocity[1] = ship.velocity[1] + math.cos(degToRad(ship.rot)) * ship.accel
	ship.velocity[2] = ship.velocity[2] + math.sin(degToRad(ship.rot)) * ship.accel
	
	ship.pos.x = canMod(ship.pos.x + ship.velocity[1], UNIVERSE_WIDTH)
	ship.pos.y = canMod(ship.pos.x + ship.velocity[1], UNIVERSE_HEIGHT)
	ship.accel = 0.0
end

--move entity other than ship (these have infinite acceleration)
function moveEntity(e, dt)

end

--draws an equilateral triangle centered on a 2d point
-- l defines the length of a side
function drawTriangle(x, y, l, rot)
	h = math.sqrt(3)/2*l
	rads = degToRad(rot)
	--vertices: top, left, right
	verts = {x, y + h/2, x - l/2, y - h/2, x, y - h/4, x + l/2, y - h/2}  
	--verts = {0, h/2, -l/2, -h/2, l/2, -h/2}  
	vertsdash = {}
	--rotate triangle around centre
	for i = 1, #verts - 1, 2 do 
		xdash = verts[i]
		ydash = verts[i+1]	
			
		--[[xdashdash = x + (x - xdash) * math.cos(rads) - (y - ydash) * math.sin(rads)
		ydashdash = y + (x - xdash) * math.sin(rads) + (y - ydash) * math.cos(rads) 
		]]--
		xdashdash = x + (xdash - x) * math.cos(rads) - (ydash - y) * math.sin(rads)
		ydashdash = y + (xdash - x) * math.sin(rads) + (ydash - y) * math.cos(rads) 
		
		table.insert(vertsdash, xdashdash)
		table.insert(vertsdash, ydashdash)
		
	end	
	
	drawPoly(vertsdash)
	
end

--converts world coordinates to screen and draws polygon
function drawPoly(vertices)
	screenverts = {}
	for i = 1, #vertices - 1, 2 do 
		x = vertices[i]
		y = vertices[i+1]
		screencoords = worldToScreen(x, y)
		table.insert(screenverts, screencoords[1])
		table.insert(screenverts, screencoords[2])
	end
	
	love.graphics.polygon('line', screenverts)
end
--[[
	SHOOTAN ASTEROIDS
	Player has an "asterbar", divided into quarters: 
		-4 bars allow the launching of a giant asteroid 
		-3 bars allow the launching of a large asteroid (giant/2)
		-2 bars allow the launching of a medium asteroid (large/2)
		-1 bars allow the launching of a small asteroid (medium/2)
	When destroyed, an asteroid will yield two asteroids of the next largest size
]]--
--creates the geometry of an asteroid and endows it with direction - a janky polygon (octogon)
--returns the asteroid polygon and direction
function makeAsteroids(centre, radius, direction)
--make an octagon 
	vertices = {}
	for i=1.0, 2.0* math.pi, math.pi/4.0 do
		x = centre[1] + math.cos(i) * radius
		y = centre[2] + math.sin(i) * radius
		table.insert(vertices, x)
		table.insert(vertices, y)
	end

--randomise points a bit to create natural look
	for i = 1, #vertices do
		vertices[i] = vertices[i] + math.random(-radius/3, radius/3)
	end
	
	asteroid = {pos = centre, verts = vertices, velocity = direction}
	return asteroid
end

--ship fires bullet in current direction
function fire()
	--bullet vector must be derived from ship rotation, which can oppose its velocity 
	bveloc = {}

	
	
	return {pos = ship.pos, velocity = bveloc } --return entity with position initialised to ship's, fired at ship's facing	
end

--converts world coordinates to a position on the screen FIX THIS
function worldToScreen(x, y)
	sw = love.graphics.getWidth()
	sh = love.graphics.getHeight()
	 
	 
	res = {x/UNIVERSE_WIDTH * sw, (1 - y/UNIVERSE_HEIGHT) * sh }
	return res
end
