--[[
		main.lua - main loop and callbacks for SDIORETSA
		
		A game for Ludum Dare 25 by Josh Douglass-Molloy
		
		Released under the MIT License
]]--
local jmaths = require "jmaths" 

default_colours = {



}

alt_colours = {

}

function love.load()

	poss_game_states = {"RUN", "SPAWN", "END"}
	game_state = poss_game_states[1]
	poss_ship_states = {"REST", "AVOID", "HUNT"}
	ship_state = poss_ship_states[1]
	
	--draggy stuff
	spawn_point = {}	
	
	asteroids = {}
	bullets = {}
	UNIVERSE_WIDTH = 1000
	UNIVERSE_HEIGHT = 750
	ASTEROID_SIZES = {small = 10, medium = 20, large = 40, huge = 80}
	ASTEROID_BASE_SPEED = 5.0
	ASTEROID_SPEEDS = {small = 8.0, medium = 4.0, large = 2.0, huge = 1.0} --scales whatever minimum asteroid speed is chosen 
	ASTEROID_HP = {small = 1, medium = 2, large = 4, huge = 8}
	
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.setBackgroundColor(0,0,0)
	testeroids = {
		makeAsteroid({400, 400}, "huge", {0,0}),
		makeAsteroid({200, 200}, "medium", {0,0}),
		makeAsteroid({800, 800}, "large", {0,0}),	
		makeAsteroid({100, 100}, "small", {0,0})
	}
	
	ship = {
		pos = {x = UNIVERSE_WIDTH/2, y = UNIVERSE_HEIGHT/2},
		velocity = {x = 0.0, y = 0.0},
		maxspeed = magni(10.0, 10.0),
		rot = 0.0,
		accel = 0.0,	
		lives = 5
	}	

	music = love.audio.newSource("bgm.ogg")
	music:setVolume(0.1)
	love.audio.play(music)
end

function love.keyreleased(key)
	if key == " " then
		table.insert(bullets, fire())
	end
end

--mouse management for draggy asteroid spawning
function love.mousepressed(x, y, button)
	if game_state ~= poss_game_states[2] then
		if button == "l" then
			game_state = poss_game_states[2]
			coords = worldToScreen(x, y)
			table.insert(spawn_point, coords[1])
			table.insert(spawn_point, coords[2])
		end
	end
end

function love.mousereleased(x,y,button)
	
	--only spawn if there is mouse delta during click
	realp = screenToWorld(x, y)
	deltamouse = euclid(spawn_point[1], spawn_point[2], realp[1], realp[2])
	direct = {realp[1] - spawn_point[1], realp[2] - spawn_point[2]} --vector between points of press and release 
	directbar = magni(direct[1], direct[2])

	if deltamouse ~= 0.0 then
		table.insert(asteroids, makeAsteroid({spawn_point[1], spawn_point[2]}, "medium", direct))
	end
	game_state = poss_game_states[1]
end

function love.update(dt)
-- accept input from mouse and keyboard
	if love.keyboard.isDown("left") then
		ship.rot = canMod(ship.rot + 100.0 * dt, 360.0)
	elseif love.keyboard.isDown("right") then
		ship.rot = canMod(ship.rot - 100.0 * dt, 360.0)
	elseif love.keyboard.isDown("up") then
		ship.accel = 10.0		
	end
	
-- update motion, wrap around screen if necessary
	for i = 1, #asteroids do
		updateEntity(asteroids[i], dt, "asteroid")
	end

	for i = 1, #bullets do
		if bullets[i].ttl <= 0.0 then
			table.remove(bullets, i)
			break
		end
		updateEntity(bullets[i], dt, "bullet")
	end 

	moveShip(dt)
	
end

function love.draw()
	--draws ship
	drawShip()	
	for i = 1, #testeroids do
		drawPoly(testeroids[i].verts)
	end
	love.graphics.setLine(5, "smooth")
	for i = 1, #bullets do
		drawBullet(bullets[i])
	end
	love.graphics.setLine(1, "smooth")
	for i = 1, #asteroids do
		drawAsteroid(asteroids[i])
	end
	
	
	
	drawHud()
end

function drawShip()
	drawTriangle(ship.pos.x, ship.pos.y, 15, ship.rot)
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
	ship.velocity.x = ship.velocity.x + math.cos(degToRad(ship.rot)) * ship.accel
	ship.velocity.y = ship.velocity.y + math.sin(degToRad(ship.rot)) * ship.accel
	
	ship.pos.x = canMod(ship.pos.x + ship.velocity.x * dt, UNIVERSE_WIDTH)
	ship.pos.y = canMod(ship.pos.y + ship.velocity.y * dt, UNIVERSE_HEIGHT)
	ship.accel = 0.0
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
function makeAsteroid(centre, size, direction)
--make an octagon 
	vertices = {}
	radius = ASTEROID_SIZES[size]
	
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
	
	asteroid = {pos = {x = centre[1], y = centre[2]}, verts = vertices, velocity = {x = direction[1], y = direction[2]}}
	return asteroid
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
	love.graphics.print("BULLET", 800, 800)
	return {pos = { x = ship.pos.x, y = ship.pos.y}, velocity = bveloc, head = bhead, ttl = 1.0 } --return entity with position initialised to ship's, fired at ship's facing	
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
	--
	if game_state == poss_game_states[2] then
		love.graphics.print("(" .. love.mouse.getX() .. ", " .. love.mouse.getY() .. ")", 200, 200) 
	end

end


