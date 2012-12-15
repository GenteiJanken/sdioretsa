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
	--update motion, wrap around screen if applicable
--	for i =1, #entities do
	--	moveEntity(entities[i])
--end
end

function love.draw()

end

--draws an equilateral triangle centered on a 2d point
--can rotate
function drawTriangle(x, y, size, rot)

end

--creates the geometry of an asteroid and endows it with direction - a janky polygon (octogon)
function makeAsteroids(size, direction)
--make an octogon with length size on a side, moving in direction 

--randomise points slightly to create natural look

end

--MATHS

--euclidean distance between two points 
function euclid(x0, x1, y0, y1)
	return magni(x0 - x1, y0 - y1)
end

function magni(x, y)
	return sqrt( math.pow( x, 2 ), math.pow( y, 2 ) )
end

--canonical modulus
function canMod(n, m)
	return math.mod((math.mod(n, m) + m), m) 
end

--check if two polygons collide
function collidePolygons(p1, p2)
	--interior angle - each point of p2 on p1
	for i = 1, #p2.points do
		pointToPoly(p2.points[i], p1) 
	end
end

--check if point is inside polygon
function pointToPoly(point, poly)
	res = 0.0
	tol = 5.0
	for i = 1, #poly.points - 1 do
		vec0 = {point.x - poly.points[i].x, point.y - poly.points[i].y }
		vec1 = {poly.points[i].x - poly.points[i+1].x, poly.points[i].y - poly.points[i+1].y }
		res = res + acos(dot(vec0[1], vec0[2], vec1[1], vec1[2] )/magnitude(vec0)*magnitude(vec1))
	end
	
	if res < 2*math.pi + tol then
		return true
	end
	
	return false
end

--moves an entity
function moveEntity(e)
	e.velocity.x = e.velocity.x + e.accel.x
	e.velocity.y = e.velocity.y + e.accel.y
	e.pos.x = canMod(e.pos.x + e.velocity.x, UNIVERSE_WIDTH)
	e.pos.y = canMod(e.pos.y + e.velocity.y, UNIVERSE_HEIGHT)
end

function dot(x0, x1, y0, y1)
	return x0*x1 + y0*y1 
end
