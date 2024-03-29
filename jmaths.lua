--[[
	jmaths.lua
	Maths library, by Josh (J) Douglass-Molloy
]]--

--euclidean distance between two points 
function euclid(x0, x1, y0, y1)
	return magni(x0 - x1, y0 - y1)
end

function magni(x, y)
	return math.sqrt( math.pow( x, 2.0 ) + math.pow( y, 2.0 ) )
end

--canonical modulus
function canMod(n, m)
	return math.mod((math.mod(n, m) + m), m) 
end

--check if two polygons collide
function collidePolygons(p1, p2)
	--interior angle test - each point of p2 on p1
	for i = 1, #p2 -1, 2 do
		pointi = {x = p2[i], y = p2[i+1]}
		if pointToPoly(pointi, p1) == true then
			return true
		end	
	end
	return false
end

--check if point is inside polygon
function pointToPoly(point, verts)
	res = 0.0
	tol = 0.1
	
	polypoints = {}

	--turn raw sequence of vertex info into points
	for i = 1, #verts - 1, 2 do		
		table.insert(polypoints, {verts[i], verts[i+1]})
	end
	
	
	for i = 1, #polypoints - 1 do
		vec0 = {point.x - polypoints[i][1], point.y - polypoints[i][2] }
		vec1 = {point.x - polypoints[i+1][1], point.y - polypoints[i+1][2] }
		res = res + math.acos(dot(vec0[1], vec0[2], vec1[1], vec1[2] )/(magni(vec0[1], vec0[2])*magni(vec1[1], vec1[2])))
	end
	
	
	vec0 = {point.x - polypoints[#polypoints][1], point.y - polypoints[#polypoints][2]}
	vec1 = {point.x - polypoints[1][1], point.y - polypoints[1][2]}
	
	res = res + math.acos(dot(vec0[1], vec0[2], vec1[1], vec1[2] )/(magni(vec0[1], vec0[2])*magni(vec1[1], vec1[2])))
	
	print(res + tol)	
	if res + tol < 2*math.pi then
		return false
	else
		return true
	end
	
end

--moves an entity
function moveEntity(e)
	e.velocity.x = e.velocity.x + e.accel.x
	e.velocity.y = e.velocity.y + e.accel.y
	e.pos.x = canMod(e.pos.x + e.velocity.x, UNIVERSE_WIDTH)
	e.pos.y = canMod(e.pos.y + e.velocity.y, UNIVERSE_HEIGHT)
end

--dot product of two vectors
function dot(x0, y0, x1,y1) 
	return x0 * x1 + y0 * y1
end
--[[function dot(x0, x1, y0, y1)
	return x0*x1 + y0*y1 
end-]]--

--obtains direction from rotation (provided in radians)
function rotationToDir(rot)	
	x = math.cos(rot)
	y = math.sin(rot)
	
	return {x, y}
end

--degrees to radians and vice versa
function degToRad(theta)
	return theta/180.0 * math.pi
end	

function radToDeg(theta)
	return theta * 180.0/math.pi
end

--checks two circles for intersection
function circleTest(centre0, r0, centre1, r1)
	return euclid(centre0[1], centre0[2], centre1[1], centre1[2]) <= r0 + r1 
end

--regular n-polygon in circle of given radius at origin
function constructPoly(n, radius)
	vertices = {}
	for i = 1.0, i < 2* math.pi, 2*math.pi/n do
		x = math.cos(i) * radius
		y = math.sin(i) * radius
		table.insert(vertices, x)
		table.insert(vertices, y)
	end
	return vertices
end

function clamp(x, minimum, maximum)
	if x > maximum then
		return maximum
	elseif x < minimum then
		return minimum
	else
		return x
	end
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
--COLLISION TESTING
--[[
function collision_test()
positive_triangle = {
	0.0, 0.0, --bottom left
	0.0, 0.5, --top
	0.5, 0.0 --bottom right
}

negative_triangle = {
	0.0, 0.0, --bottom left
	0.0, -0.5, --top
	-0.5, 0.0 --bottom right
}

test_points = {
	{x = -0.15, y = -0.15}, --true
	{x = -0.5, y =  -0.5}, --false 
	{x=-0.5, y = 0.0} --true
	}


test_points = {
	{x = 0.15, y = 0.15}, --true
	{x = 0.5, y =  0.5}, --false 
	{x=0.5, y = 0.0} --true
	}
	print( pointToPoly( test_points[1], positive_triangle )) -- true
	print( pointToPoly( test_points[2], positive_triangle )) -- false
print( pointToPoly( test_points[3], positive_triangle )) -- true
print( pointToPoly( test_points[1], negative_triangle )) -- true
	print( pointToPoly( test_points[2], negative_triangle )) -- false
print( pointToPoly( test_points[3], negative_triangle )) -- true

end

collision_test()	
]]--
