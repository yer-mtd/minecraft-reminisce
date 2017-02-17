function math.round(value)
if value > 0.5 then return math.ceil(value) end
if value < 0.5 then return math.floor(value) end
if value == 0.5 then return value end
end



function block_setBlockId(x,y,value)

math.randomseed(3)

local target_chunk = math.floor(x/16)
local rel_x = (math.floor(x)%16)
local rel_y = math.floor(y)
if rel_y < 63 or rel_y > 1 then block[target_chunk][rel_x][rel_y] = value end

--print(target_chunk,rel_x,rel_y)

end

function block_getBlockId(x,y)



local target_chunk = math.floor(x/16)
local rel_x = (math.floor(x)%16)
local rel_y = math.floor(y)
if rel_y < 63 or rel_y > 1 then return block[target_chunk][rel_x][rel_y] end



end

function block_getScreenCoordinates(f_chunk,f_x,f_y)

if f_y == nil then

f_y = f_x
f_x = f_chunk
f_chunk = math.floor(f_x/16)

end

return f_x*__scale+(f_chunk*16*__scale)-render_x ,__origin-(f_y-1)*__scale-render_y

end

block_solidLookupTable = {1,2,3,4,5,6,7,8}

function block_isSolid(x,y)

local id = block_getBlockId(x or 0,y or 0)
for key,value in pairs(block_solidLookupTable) do
	if id == value then return true end
end


end


function global_saveChunk(num)

	

end

--PLAYER CLASS-----------------------------------------------------------------------------------------------------------------

player = {cdt = 0, ypos = 64, xpos = 32, vspeed = -0.1, hspeed = 0, health = 20, ground = 0}
function player.tick(this)
if this.ground == 0 then this.vspeed = this.vspeed - 0.005 end
if math.abs(this.vspeed) > 1 then this.vspeed = 0.9 end

if block_isSolid(this.xpos,math.ceil(this.ypos)) or block_isSolid(this.xpos,math.ceil(this.ypos+1)) then 
--Vertical collision
if this.vspeed < 0 then this.ypos = math.ceil(this.ypos) this.ground = 1 this.ypos = math.ceil(this.ypos) end
if this.vspeed > 0 then this.ypos = math.ceil(this.ypos-1) this.vspeed = 0 end


elseif not block_isSolid(this.xpos,math.ceil(this.ypos)) and this.ground == 1 then this.ground = 0 end

if this.ground == 1 then this.vspeed = 0 this.ypos = math.ceil(this.ypos) end
this.hspeed = this.hspeed * 0.9

if block_isSolid(this.xpos + this.hspeed,this.ypos+1) or block_isSolid(this.xpos + this.hspeed,this.ypos+2) then 

if this.hspeed > 0 then this.xpos = math.ceil(this.xpos) - 0.05 this.hspeed = 0 end 
if this.hspeed < 0 then this.xpos = math.floor(this.xpos) + 0.05 this.hspeed = 0 end 


end
this.xpos = this.xpos + this.hspeed
this.ypos = this.ypos + this.vspeed 

if this.hspeed > 0 and this.hspeed < 0.001 then this.hspeed = 0 end
if this.hspeed < 0 and this.hspeed > -0.001 then this.hspeed = 0 end

end 
function player.render(this)
	local r_x, r_y = block_getScreenCoordinates(this.xpos,this.ypos)
	love.graphics.rectangle("fill",400-2,300-__scale,4,__scale*2)
	render_y = __origin-(this.ypos)*__scale-300
	render_x = (this.xpos)*__scale-400
	love.graphics.print(this.hspeed .. " " .. this.vspeed .. " \n" .. this.xpos .. " " .. this.ypos,32,32)
	
end 



-------------------------------------------------------------------------------------------------------------------------------

function __generate()
pseudoseed = os.time()%99999
--pseudoseed = 0
--We're gonna have 16x64 chunks for now. Let's get generating. Raising.
for chunk = 0,4,1 do 
		block[chunk] = {}
		for x = 0,15,1 do
			block[chunk][x] = {}
			for y = 0,63,1 do
				block[chunk][x][y] = 0
			end 
		end
	end
	for x = 0,5*16-1,1 do
		n = love.math.noise(pseudoseed,x/30)*10
		m = love.math.noise(pseudoseed,x/70)*10
		q = love.math.noise(pseudoseed,x/3)*2
		block_setBlockId(x,math.abs(n+q)+32+m,3)
		--print(n+26)
	end
	--Soiling.
	for chunk = 0,4,1 do 
		for x = 0,15,1 do
			for y = 0,63,1 do
				if block[chunk][x][y] == 3 then 
				m = 3+math.floor(love.math.noise(pseudoseed,x/3)*2)
				print(m)
					for n = y-1,y-m,-1 do
						block[chunk][x][n] = 2
					end
					for n = y-m,0,-1 do
						block[chunk][x][n] = 1
					end 
				end
			end 
		end
	end
	--Carving.
	for chunk = 0,4,1 do
		for x=0,15,1 do
			for y=0,63,1 do
				cave = love.math.noise(((y+0.9)/120)*12,((x+chunk*16)/120)*12,pseudoseed)
				--print(cave)
				if cave > 0.6 then block[chunk][x][y] = 0 end 
				--cave = love.math.noise(((y+0.9)/180)*10,((x+chunk*16)/180)*10,pseudoseed)
				--print(cave)
				--if cave > 0.8 then block[chunk][x][y] = 0 end 
			end 
		end
	end


end

--LOVE FUNCTIONS---------------------------------------------------------------------------------------------------------------
function love.load()
	min_dt = 1/120
	next_time = love.timer.getTime()
	pseudoseed = os.time()%9999
	--Load terrain png and shear it into quads
	terrain = love.graphics.newImage("terrain.png")
	terrain:setFilter("nearest")
	qq = 0
	render_x = 0
	render_y = 0
	mouse_x, mouse_y, mouse_chunk = 0
	texture = {}
	for i=0,256,16 do
		for ii=0,256,16 do
			texture[qq] = love.graphics.newQuad(ii,i,16,16,256,256)
			qq = qq + 1
		end
	end
	__scale = 16
	__origin = 63 * __scale
	block = {}
	__generate()
	entity = {}
	entity[0] = {}
	setmetatable(entity[0],{__index = player})
end

function love.draw()
	renderblock = 0
	for chunk = 0,4,1 do 
		for x = 0,15,1 do
			--print(math.max(math.ceil(entity[0].ypos-12)%63,0),math.min(math.ceil(entity[0].ypos+12)%63,63))
			for y=0,63,1 do
				if block[chunk][x][y] > 0 and chunk > entity[0].xpos/16-2 and chunk < entity[0].xpos/16+1 then 
				if x+chunk*16 > entity[0].xpos-14 and x+chunk*16 < entity[0].xpos+13 and y>entity[0].ypos-9 and y<entity[0].ypos+12 then 
					renderblock = renderblock + 1
					i_x, i_y = block_getScreenCoordinates(chunk or -1,x or 0,y or -1)
					love.graphics.draw(terrain,texture[block[chunk][x][y]],i_x,i_y,0,__scale/16,__scale/16)
					--love.graphics.print(renderblock,i_x,i_y)
				end
				end
			end 
		end
	end
	love.graphics.print(love.timer.getFPS() .. " // " .. renderblock .. " // " .. gdt)
	--love.graphics.print({render_x .. " " .. render_y},32,32)
	for id,obj in pairs(entity) do
		obj:render()
	end	
	--mouse debug
	love.graphics.print(mouse_chunk .. " " .. mouse_x .. " " .. mouse_y,64,64)
	
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

function love.mousepressed( x, y, button, istouch )

	if button == 1 then block[mouse_chunk][mouse_x][mouse_y] = 0 end
	if button == 2 then block[mouse_chunk][mouse_x][mouse_y] = 1 end
	
end

function love.keypressed(key)
	if key == 'r' then __generate() end
	if key == 'w' and entity[0].ground < 7 then entity[0].ypos = entity[0].ypos + 0.1 entity[0].ground = 0 entity[0].vspeed = 0.12 entity[0].cdt = gdt end
end





function love.update(dt)
gdt = dt
next_time = next_time + min_dt
	--dt = math.min(dt, 1/60)
	for id,obj in pairs(entity) do
		obj:tick()
	end	
	mouse_chunk = math.floor(math.floor((love.mouse.getX())/__scale+render_x/__scale)/16)
	mouse_x = math.floor((love.mouse.getX())/__scale+render_x/__scale)%16
	mouse_y = math.ceil(math.abs((love.mouse.getY())/__scale+render_y/__scale-64))
	if love.keyboard.isDown 'a' then entity[0].hspeed = -0.06 end
	if love.keyboard.isDown 'd' then entity[0].hspeed = 0.06 end
end