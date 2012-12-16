--[[
	jmaths.lua
	Maths library, by Josh (J)
]]--

--euclidean distance between two points 
function euclid(x0, x1, y0, y1)
	return magni(x0 - x1, y0 - y1)
end

function magni(x, y)
	return math.sqrt( math.pow( x, 2 ), math.pow( y, 2 ) )
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
	tol = 0.1
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
--dot product of two vectors
function dot(x0, x1, y0, y1)
	return x0*x1 + y0*y1 
end


--degrees to radians and vice versa
function degtorad(theta)
	return theta/180.0 * math.pi
end	

function radtodeg(theta)
	return theta * 180/math.pi
end

--[[
Generalisation - construct n-polygon enscribed in circle of given radius

var cx
var cy

for (var i=0; i <  Math.PI*2; i+=Math.PI*2/n){
	var x = cx + Math.Cos(i) * radius;
	var y = cy + Math.Angle(i) * radius;
}
]]--
