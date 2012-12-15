--[[
function love.load()
	entities = {}
	UNIVERSE_WIDTH = 1000
	UNIVERSE_HEIGHT = 1000
	ASTEROID_SIZES = {10, 20, 40, 80}
	
	
end

function love.update(dt)
	--update motion, wrap around screen if applicable
	for i =1, #entities
		moveEntity(entities[i])
	end
end

function love.draw()

end

]]--

--draws an equilateral triangle centered on a 2d point
--can rotate
function drawTriangle(x, y, size, rot)

end

--creates the geometry of an asteroid and endows it with direction - a janky polygon (octogon)
function makeAsteroids(size, direction)

end


--MATHS

--euclidean distance between two points 
function euclid(x0, x1, y0, y1)
	return sqrt( math.pow( x0 - x1, 2 ), math.pow( x0 - x1, 2 ) )
end

--canonical modulus
function canmod(n, m)
	return math.mod((math.mod(n, m) + m), m) 
end

--check if two polygons collide
function collidePolygons(p1, p2)
	--interior angle - each point of p2 on p1

end

--moves an entity
function moveEntity(e)
	e.velocity.x = e.velocity.x + e.accel.x
	e.velocity.y = e.velocity.y + e.accel.y
	e.pos.x = canmod(e.pos.x + e.velocity.x, UNIVERSE_WIDTH)
	e.pos.y = canmod(e.pos.y + e.velocity.y, UNIVERSE_HEIGHT)
end
