--[[
		main.lua - main loop and callbacks for SDIORETSA
		
		A game for Ludum Dare 25 by Josh Douglass-Molloy
		
		Released under the MIT License
]]--
local jmaths = require "jmaths" 


--colour palettes have three colours - background, foreground, HUD
default_colours = { 
	{0, 0, 0}, --black
	{255, 255, 255}, --white
	{255, 0, 0} --red

}

alt_colours = {

}

function love.load()

	poss_game_states = {"RUN", "SPAWN", "END"}
	game_state = "RUN"
	poss_ship_states = {"REST", "AVOID", "HUNT"}
	ship_state = poss_ship_states[1]
	
	--draggy stuff
	spawn_point = {}	
	spawn_time = 0.0
	spawn_size = "none"
	
	asteroids = {}
	bullets = {}
	UNIVERSE_WIDTH = 1000
	UNIVERSE_HEIGHT = 1000	
	ASTEROID_SPAWN_TIMES = {small = 0.5, medium = 1.0, large = 2.0, huge = 4.0}
	ASTEROID_SIZES = {small = 10, medium = 20, large = 40, huge = 80}
	ASTEROID_BASE_SPEED = 16.0
	ASTEROID_SPEEDS = {small = 8.0, medium = 4.0, large = 2.0, huge = 1.0} --scales whatever minimum asteroid speed is chosen 
	ASTEROID_HP = {small = 1, medium = 2, large = 4, huge = 8}
	
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.setBackgroundColor(0,0,0)
	--[[testeroids = {
		makeAsteroid({400, 400}, "huge", {-100.0,0}),
		makeAsteroid({200, 200}, "medium", {-100.0,0}),
		makeAsteroid({800, 800}, "large", {0,0}),	
		makeAsteroid({100, 100}, "small", {0,0})
	}]]--
	
	ship = {
		pos = {x = UNIVERSE_WIDTH/2, y = UNIVERSE_HEIGHT/2},
		velocity = {x = 0.0, y = 0.0},
		maxspeed = 1000.0, -- both components of ship velocity will be clamped to [-maxspeed, maxspeed]
		rot = 0.0,
		accel = 0.0,	
		lives = 5
	}	
--settings
		love.mouse.setGrab(true)
--audio
	music = love.audio.newSource("bgm.ogg")
	music:setVolume(0.1)
	music:setLooping(true)
	sfx = {
		shot = love.audio.newSource("pew.wav", "static"),
		explosion = love.audio.newSource("boom.wav", "static"),
		upgrade = love.audio.newSource("upgrade.wav", "static")
	}
	sfx.shot:setVolume(0.5)
	sfx.explosion:setVolume(0.5)
	sfx.upgrade:setVolume(0.5)
	--love.audio.play(music)
end

function love.keyreleased(key)
	if key == " " then
		table.insert(bullets, fire())
	elseif key == "up" then
		ship.accel = 0.0
	end
end

--mouse management for draggy asteroid spawning
function love.mousepressed(x, y, button)
	if button == "l" then
		if game_state ~= "SPAWN" then		
			game_state = "SPAWN"
			coords = screenToWorld(x, y)			
			table.insert(spawn_point, coords[1])
			table.insert(spawn_point, coords[2])
		end
		love.graphics.print("(" .. spawn_point[1] .. ", " .. spawn_point[2] .. ")", 200, 400)
	end

end

--TOFIX - asteroids launched vertically received immediately scaled velocity, achieving unreasonable speeds
function love.mousereleased(x,y,button)
	--only spawn if there is mouse delta during click
	if button ~= "l" or spawn_size == "none" then
		return
	end
	
	newmouse = screenToWorld(x, y)
	deltamouse = euclid(spawn_point[1], spawn_point[2], newmouse[1], newmouse[2])
	direct = {newmouse[1] - spawn_point[1], newmouse[2] - spawn_point[2]} --vector between points of press and release 
	directbar = magni(direct[1], direct[2])
	direct[1] = direct[1] / directbar --normalise vector
	direct[2] = direct[2] / directbar
	
	direct[1] = direct[1] * ASTEROID_SPEEDS[spawn_size] * ASTEROID_BASE_SPEED
	direct[2] = direct[2] * ASTEROID_SPEEDS[spawn_size] * ASTEROID_BASE_SPEED
	
	if spawn_point[1]~=newmouse[1] or spawn_point[2] ~= newmouse[2] then
		table.insert(asteroids, makeAsteroid({spawn_point[1], spawn_point[2]}, ASTEROID_SIZES[spawn_size], direct))
	end
	
	game_state = "RUN"
	spawn_point = {}
	spawn_time = 0.0
	spawn_size = "none"
end




function love.update(dt)
-- accept input from mouse and keyboard
	if love.keyboard.isDown("left") then
		ship.rot = canMod(ship.rot + 360.0 * dt, 360.0)
	elseif love.keyboard.isDown("right") then
		ship.rot = canMod(ship.rot - 360.0 * dt, 360.0)
	elseif love.keyboard.isDown("up") then
		ship.accel = 8.0		
	elseif love.keyboard.isDown("escape") then
		love.event.push("quit")
	end
--[[	
	for i = 1, #testeroids do
		updateEntity(testeroids[i], dt, "asteroid")
	end
]]--
-- update motion, wrap around screen if necessary
	

	for i = 1, #bullets do
		if bullets[i].ttl <= 0.0 then
			table.remove(bullets, i)
			break
		end
		updateEntity(bullets[i], dt, "bullet")
	end 
	moveShip(dt)
	
	for i = 1, #asteroids do
		updateEntity(asteroids[i], dt, "asteroid")
	end

	if love.mouse.isDown("l") then
	
	if game_state == "SPAWN" then
		setSpawnSize(dt)
		
	end
	end
	
end

function setSpawnSize(dt) 
	spawn_time = spawn_time + dt

	for k, v in pairs(ASTEROID_SPAWN_TIMES) do
		if spawn_time > v and (spawn_size == "none" or ASTEROID_SIZES[k] > ASTEROID_SIZES[spawn_size]) then
			spawn_size = k
		end		
	end
	
end

function love.draw()
	--draws ship
	drawShip()	
	--[[
	for i = 1, #testeroids do
		drawPoly(testeroids[i].verts)
	end]]--
	love.graphics.setLine(5, "smooth")
	for i = 1, #bullets do
		drawBullet(bullets[i])
	end
	love.graphics.setLine(1, "smooth")
	for i = 1, #asteroids do
		drawAsteroid(asteroids[i])
	end
	shape = {pos = {x = 400, y = 400}, verts = {-10, -10, -10, 10, 10, -10, 10, 10}}
	--drawAsteroid(shape)
	drawHud()
end

function drawShip()
	drawTriangle(ship.pos.x, ship.pos.y, 15, ship.rot)
end

function buildShip()
	ship = {
		pos = {x = UNIVERSE_WIDTH/2, y = UNIVERSE_HEIGHT/2},
		velocity = {x = 0.0, y = 0.0},
		maxspeed = magni(1000.0, 1000.0),
		rot = 0.0,
		accel = 0.0,	
		
	}		
	
end

function drawBullet(b)
	x0 = b.pos.x
	y0 = b.pos.y
	x1 = b.pos.x + b.head.x
	y1 = b.pos.y + b.head.y
	p0 = worldToScreen(x0, y0) 
	p1 = worldToScreen(x1, y1)
	love.graphics.line(p0[1], p0[2], p1[1], p1[2])
end

function drawAsteroid(a)
	trans_verts = {}		
	for i = 1, #a.verts - 1, 2 do 
		xdash = a.pos.x + a.verts[i]
		ydash = a.pos.y + a.verts[i+1]

		table.insert(trans_verts, xdash)
		table.insert(trans_verts, ydash)
	end
	drawPoly(trans_verts)

end

function moveShip(dt)
	
	ship.velocity.x = clamp(ship.velocity.x + math.cos(degToRad(ship.rot)) * ship.accel, -ship.maxspeed, ship.maxspeed)
	ship.velocity.y = clamp(ship.velocity.y + math.sin(degToRad(ship.rot)) * ship.accel, -ship.maxspeed, ship.maxspeed)
	
	ship.pos.x = canMod(ship.pos.x + ship.velocity.x * dt, UNIVERSE_WIDTH)
	ship.pos.y = canMod(ship.pos.y + ship.velocity.y * dt, UNIVERSE_HEIGHT)
	
end

--move entity other than ship (these have infinite acceleration)
function updateEntity(e, dt, etype)
	e.pos.x = canMod(e.pos.x + e.velocity.x * dt, UNIVERSE_WIDTH)
	e.pos.y = canMod(e.pos.y + e.velocity.y * dt, UNIVERSE_HEIGHT)

	if etype == "bullet" then
		e.ttl = e.ttl - dt
	end
end

--draws an equilateral triangle centered on a 2d point
-- l defines the length of a side
function drawTriangle(x, y, r, rot)
	rads = degToRad(rot)
	--vertices: top, left, right
	--verts = {x, y + h/2, x - l/2,  y - h/2, x + l/2, y - h/2}  
	verts = {}
	
	for i=1.0, 2.0* math.pi, math.pi * 2.0/3.0 do
		xdash = x + math.cos(i + math.pi) * r
		ydash = y + math.sin(i + math.pi) * r
		table.insert(verts, xdash)
		table.insert(verts, ydash)
	end
	
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
function makeAsteroid(centre, radius, direction)
--make an octagon 
	vertices = {}
	
	for i=1.0, 2.0* math.pi, math.pi/4.0 do
		x = centre[1] + math.cos(i) * radius
		y = centre[2] + math.sin(i) * radius
		table.insert(vertices, x)
		table.insert(vertices, y)
	end

-- (translate back to og)
	for i = 1, #vertices - 1, 2 do 
		vertices[i] = vertices[i] - centre[1]
		vertices[i+1] = vertices[i+1] - centre[2]
	end
--randomise points a bit to create natural look
	for i = 1, #vertices do
		vertices[i] = vertices[i] + math.random(-radius/3, radius/3)
	end
	
	return {pos = {x = centre[1], y = centre[2]}, verts = vertices, velocity = {x = direction[1], y = direction[2]}}

end

--destroys asteroid, possibly dividing it but possibly finishing it off
function destroyAsteroid(a)

end

--ship fires bullet in current direction
function fire()
	--bullet vector must be derived from ship rotation, which can oppose its velocity 
	bveloc = {}
	bhead = {}
	bveloc.x = math.cos(degToRad(ship.rot)) * 1000.0
	bveloc.y = math.sin(degToRad(ship.rot)) * 1000.0
	bhead.x = math.cos(degToRad(ship.rot)) * 10.0
	bhead.y = math.sin(degToRad(ship.rot)) * 10.0
	
	sfx.shot:play()
	sfx.shot:rewind()
	return {pos = { x = ship.pos.x, y = ship.pos.y}, velocity = bveloc, head = bhead, ttl = 0.8 } --return entity with position initialised to ship's, fired at ship's facing	
end

--converts world coordinates to a position on the screen 
function worldToScreen(x, y)
	sw = love.graphics.getWidth()
	sh = love.graphics.getHeight()
	 
	res = {x/UNIVERSE_WIDTH * sw, (1.0 - y/UNIVERSE_HEIGHT) * sh }
	return res
end

--converts screen coordinates to world coordinates (essential for mouse)
function screenToWorld(x,y)
	sw = love.graphics.getWidth()
	sh = love.graphics.getHeight()
	res = { x / sw * UNIVERSE_WIDTH, (1.0 - y/sh) * UNIVERSE_HEIGHT}
	return res
end


--Draws HUD with representation of asteroid charge and number of ship lives. Uses third colour
function drawHud()	
	if game_state == "SPAWN" and spawn_size ~="none" then
	--	love.graphics.print("(" .. love.mouse.getX() .. ", " .. love.mouse.getY() .. ")", 200, 200) 
		position = {UNIVERSE_WIDTH * 0.1, UNIVERSE_HEIGHT * 0.1}
		a = makeAsteroid(position, ASTEROID_SIZES[spawn_size]* 0.5 ,{0.0, 0.0})
		love.graphics.setColor(default_colours[3])
		drawAsteroid(a)
		love.graphics.setColor(default_colours[2])
	end

end

--tests for collision between two entities
--has two modes - circletest, point to polygon (bullet -> asteroid)
--				- circletest, polygon to polygon (asteroid <-> ship)
--accepts two entities and a table enumerating the type of entity in the same order eg entityCollision(ship, asteroid[i], {"polygon", "polygon"})
function entityCollision(e1, e2, etypes)
	
	--polygon to polygon
	if etypes[1] == etypes[2] then 
		if circletest({e1.pos.x, e1.pos.y}, e1.radius, {e2.pos.x, e2.pos.y}, e2.radius) then
			return collidePolygons({e1.verts}, {e2.verts})
		else
			return false
		end
	else --point to polygon (provided that order)
		if euclid(e1.pos.x, e1.pos.y, e2.pos.x, e2.pos.y) < e2.radius then
			return pointToPoly({e1.pos.x, e1.pos.y}, {e2.verts})
		else
			return false
		end
	end
	

end

--produced desired result from collision of two entities
function resolveCollision(e1, e2, etypes)
	--remove appropriate entities
	
	--play sound effect
	sfx.explosion:play()
	sfx.explosion:rewind()
end
