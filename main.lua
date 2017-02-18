function math.round(value)
if value > 0.5 then return math.ceil(value) end
if value < 0.5 then return math.floor(value) end
if value == 0.5 then return value end
end

function is_intersecting_player()
if lit_mouse_x+mouse_chunk*16 > entity[0].xpos-0.5 and lit_mouse_x+mouse_chunk*16 < entity[0].xpos+0.5 then local xo = 1 else xo = nil end
if lit_mouse_y > entity[0].ypos and lit_mouse_y < entity[0].ypos+2 then local yo = 1 else yo = nil end
if xo and yo then return true end
end


function debug_dummy() 
--For use with debug.debug()
end


function debug_draw() 
--For use with debug.debug()
end



function block_setBlockId(x,y,value)

math.randomseed(3)

local target_chunk = tostring(math.floor(x/16))
local rel_x = (math.floor(x)%16)
local rel_y = math.floor(y)
if rel_y < 63 or rel_y > 1 then block[target_chunk][rel_x][rel_y] = value end

--print(target_chunk,rel_x,rel_y)

end

function block_getBlockId(x,y)



local target_chunk = tostring(math.floor(x/16))
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

local id = block_getBlockId(x or 0,math.ceil(y or 0))
for key,value in pairs(block_solidLookupTable) do
	if id == value then return true end
end


end


function global_saveChunk(num)

	

end

function entityphysics(this)

if this.ground == 0 then this.vspeed = this.vspeed - 0.005 end
if math.abs(this.vspeed) > 1 then this.vspeed = 0.9 end

if this.hspeed > 0 then
if block_isSolid(this.xpos + this.hspeed + this.xhit,this.ypos+0.5) or block_isSolid(this.xpos + this.hspeed + this.xhit,this.ypos+1.5) then this.hspeed = 0 end
end

if this.hspeed < 0 then
if block_isSolid(this.xpos + this.hspeed - this.xhit,this.ypos+0.5) or block_isSolid(this.xpos + this.hspeed - this.xhit,this.ypos+1.5) then this.hspeed = 0 end
end

if this.vspeed < 0 then
if block_isSolid(this.xpos+this.xhit,this.ypos) or block_isSolid(this.xpos-this.xhit,this.ypos) then this.vspeed = 0 this.ground = 1 this.ypos = math.ceil(this.ypos) end
end
 
if this.vspeed > 0 then
if block_isSolid(this.xpos+this.xhit,this.ypos+2) or block_isSolid(this.xpos-this.xhit,this.ypos+2) then this.vspeed = 0 end
end

if not block_isSolid(this.xpos + this.xhit,this.ypos) and not block_isSolid(this.xpos - this.xhit,this.ypos) then this.ground = 0 end

this.xpos = this.xpos + this.hspeed
this.ypos = this.ypos + this.vspeed 
if this.hspeed > 0 and this.hspeed < 0.001 then this.hspeed = 0 end
if this.hspeed < 0 and this.hspeed > -0.001 then this.hspeed = 0 end


end


--PLAYER CLASS-----------------------------------------------------------------------------------------------------------------

player = {n = 0, facing = 0, xhit = 0.3 , yhit = 2, cdt = 0, ypos = 64, xpos = 0, vspeed = 0, hspeed = 0, health = 20, ground = 1}
function player.tick(this)

entityphysics(this)

end 
function player.render(this)
	this.n = this.n + 0.08
	if math.abs(this.hspeed) < 0.01 then n = 0 end 
	local p_x = 400-2
	if p_x < love.mouse.getX() then this.facing = 1 else this.facing = -1 end
	local p_y = 300-__scale
	--love.graphics.rectangle("fill",400-2,300-__scale,4,__scale*2)
	render_y = __origin-(this.ypos)*__scale-300
	render_x = (this.xpos)*__scale-400
	love.graphics.print(this.hspeed .. " " .. this.vspeed .. " \n" .. this.xpos .. " " .. this.ypos,32,32)
	ix,iy = block_getScreenCoordinates(this.xpos,this.ypos)
	--offset_factor = mouse_x-32+mouse_chunk*16
	love.graphics.draw(char_sprite,playermodel.backarm,p_x+2,p_y+16,math.sin(-this.n)*(this.hspeed*20),64/__scale*this.facing,64/__scale,2,0)
	love.graphics.draw(char_sprite,playermodel.body,p_x+2,p_y,0,64/__scale*this.facing,64/__scale,2,-8)
	if this.facing == 1 then headangle = math.atan2(love.mouse.getY()-p_y,love.mouse.getX()-p_x) else headangle = math.atan2(p_y-love.mouse.getY(),p_x-love.mouse.getX()) end 
	love.graphics.draw(char_sprite,playermodel.head,p_x+2,p_y+16,headangle,64/__scale*this.facing,64/__scale,4,8)
	love.graphics.draw(char_sprite,playermodel.hat,p_x+2,p_y+16,headangle,(64/__scale+0.3)*this.facing,64/__scale+0.3,4,8)
	love.graphics.draw(char_sprite,playermodel.frontarm,p_x+2,p_y+16,math.sin(this.n)*(this.hspeed*20),64/__scale*this.facing,64/__scale,2,0)
	love.graphics.draw(char_sprite,playermodel.backleg,p_x+2,p_y+40,math.sin(this.n)*(this.hspeed*20),64/__scale*this.facing,64/__scale,2,0)
	love.graphics.draw(char_sprite,playermodel.frontleg,p_x+2,p_y+40,math.sin(-this.n)*(this.hspeed*20),64/__scale*this.facing,64/__scale,2,0)
	
	--print(offset_factor)
	--print(facing)
end 



-------------------------------------------------------------------------------------------------------------------------------

function __generate()
chunkcount = 8
--highseed = math.floor(os.time()%9999999999 / 100000)
--lowseed = (os.time()%9999999999 / 100000)%math.floor(os.time()%9999999999/100000)*100000
--rint(pseudoseed,os.time()%9999999999)
pseudoseed = os.time()%999999
--pseudoseed = 0
--We're gonna have 16x64 chunks for now. Let's get generating. Raising.
for chunk = -chunkcount,chunkcount,1 do 
		block[tostring(chunk)] = {}
		for x = 0,15,1 do
			block[tostring(chunk)][x] = {}
			for y = 0,63,1 do
				block[tostring(chunk)][x][y] = 0
			end 
		end
	end
	for x = -chunkcount*16,chunkcount*16-1,1 do
		n = love.math.noise(pseudoseed,x/30)*10
		m = love.math.noise(pseudoseed,x/70)*10
		q = love.math.noise(pseudoseed,x/3)*2
		block_setBlockId(x,math.abs(n+q)+32+m,3)
		--print(n+26)
	end
	--Soiling.
	for chunk = -chunkcount,chunkcount,1 do 
		for x = 0,15,1 do
			for y = 0,63,1 do
				if block[tostring(chunk)][x][y] == 3 then 
				m = 3+math.floor(love.math.noise(pseudoseed,x/3)*2)
				print(m)
					for n = y-1,y-m,-1 do
						block[tostring(chunk)][x][n] = 2
					end
					for n = y-m,0,-1 do
						block[tostring(chunk)][x][n] = 1
					end 
				end
			end 
		end
	end
	--Carving.
	for chunk = -chunkcount,chunkcount,1 do
		for x=0,15,1 do
			for y=0,63,1 do
				cave = love.math.noise(((y+0.9)/120)*12,((x+chunk*16)/120)*12,pseudoseed)
				--print(cave)
				if cave > 0.6 and block[tostring(chunk)][x][y] ~= 0 then block[tostring(chunk)][x][y] = block[tostring(chunk)][x][y] + 256 end 
				--cave = love.math.noise(((y+0.9)/180)*10,((x+chunk*16)/180)*10,pseudoseed)
				--print(cave)
				--if cave > 0.8 then block[tostring(chunk)][x][y] = 0 end 
			end 
		end
	end


end

--LOVE FUNCTIONS---------------------------------------------------------------------------------------------------------------
function love.load()
	http = require("socket.http")
	local b, c, h = http.request("http://mcapi.ca/rawskin/MetoolDaddy")
	love.filesystem.write("skin.png", b)
	font = love.graphics.newFont("minecraft.ttf",8)
	love.graphics.setFont(font)
	love.graphics.setBackgroundColor(0,190,255)
	selectedblock = 1
	min_dt = 1/120
	next_time = love.timer.getTime()
	--Load terrain png and shear it into quads
	terrain = love.graphics.newImage("terrain.png")
	terrain:setFilter("nearest")
	qq = 0
	render_x = 0
	render_y = 0
	mouse_x, mouse_y, mouse_chunk = 0
	texture = {}
	-- char.png quads
	char_sprite = love.graphics.newImage("skin.png")
	char_sprite:setFilter "nearest"
	playermodel = {}
	playermodel.head = love.graphics.newQuad(0,8,8,8,64,64)
	playermodel.hat = love.graphics.newQuad(32,8,8,8,64,64)
	playermodel.body = love.graphics.newQuad(16,20,4,12,64,64)
	playermodel.frontarm = love.graphics.newQuad(40,20,4,12,64,64)
	playermodel.backarm = love.graphics.newQuad(32,52,4,12,64,64)
	playermodel.frontleg = love.graphics.newQuad(0,20,4,12,64,64)
	playermodel.backleg = love.graphics.newQuad(16,52,4,12,64,64)
	
	for i=0,240,16 do
		for ii=0,240,16 do
			texture[qq] = love.graphics.newQuad(ii,i,16,16,256,256)
			qq = qq + 1
		end
	end
	disbatch = love.graphics.newSpriteBatch(terrain,567,'stream')
	__scale = 32
	__origin = 63 * __scale
	block = {}
	__height = {}
	__generate()
	entity = {}
	entity[0] = {}
	setmetatable(entity[0],{__index = player})
end

function love.draw()
	renderblock = 0
	disbatch:clear()
	for chunk = math.max(math.floor(entity[0].xpos/16)-2,-chunkcount),math.min(math.floor(entity[0].xpos/16)+2,chunkcount),1 do 
		for x = 0,15,1 do
			--print(math.max(math.ceil(entity[0].ypos-12)%63,0),math.min(math.ceil(entity[0].ypos+12)%63,63))
			for y=0,63,1 do
				if block[tostring(chunk)][x][y] > 0 and chunk > entity[0].xpos/16-2 and chunk < entity[0].xpos/16+1 then 
				if x+chunk*16 > entity[0].xpos-14 and x+chunk*16 < entity[0].xpos+13 and y>entity[0].ypos-9 and y<entity[0].ypos+12 then 
					renderblock = renderblock + 1
					i_x, i_y = block_getScreenCoordinates(chunk or -1,x or 0,y or -1)
					if block[tostring(chunk)][x][y] > 256 then disbatch:setColor(190,190,190) end
					disbatch:add(texture[(block[tostring(chunk)][x][y])%256],i_x,i_y,0,__scale/16,__scale/16)
					if block[tostring(chunk)][x][y] > 256 then disbatch:setColor(255,255,255) end
				end
				end
			end 
		end
	end
	love.graphics.draw(disbatch)
	--disbatch:flush()
	local draw = nil
	local col = nil
	love.graphics.draw(terrain,texture[selectedblock],700,64,0,3)
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
	debug_draw()
end

function love.mousepressed( x, y, button, istouch )
if is_intersecting_player then
	if button == 1 and love.keyboard.isDown('lshift') then if block[tostring(mouse_chunk)][mouse_x][mouse_y] < 256 then block[tostring(mouse_chunk)][mouse_x][mouse_y] = block[tostring(mouse_chunk)][mouse_x][mouse_y] + 256 else block[tostring(mouse_chunk)][mouse_x][mouse_y] = block[tostring(mouse_chunk)][mouse_x][mouse_y] - 256 end end
	if button == 1 and not love.keyboard.isDown('lshift') then block[tostring(mouse_chunk)][mouse_x][mouse_y] = 0 end
	if button == 2 and ((mouse_y > entity[0].ypos+2 or mouse_y < entity[0].ypos+1) or (mouse_x + mouse_chunk*16 ~= math.floor(entity[0].xpos)) or (mouse_x + mouse_chunk*16 ~= math.floor(entity[0].xpos-0.5)))
	then block[tostring(mouse_chunk)][mouse_x][mouse_y] = selectedblock end
	if button == 2 and love.keyboard.isDown('lshift') then block[tostring(mouse_chunk)][mouse_x][mouse_y] = selectedblock + 256 end
end
end

function love.wheelmoved(x, y)
	selectedblock = ((selectedblock) + y)%256
end


function love.keypressed(key)
	if key == 'c' then debug.debug() end
	if key == 'r' then __generate() entity[0].ypos = 63 entity[0].ground = 0 end
	if key == 'w' and entity[0].ground == 1 then entity[0].ypos = entity[0].ypos + 0.1 entity[0].ground = 0 entity[0].vspeed = 0.12 entity[0].cdt = gdt end
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
	lit_mouse_x = (love.mouse.getX()/__scale+render_x/__scale)%16
	mouse_y = math.ceil(math.abs((love.mouse.getY())/__scale+render_y/__scale-64))
	lit_mouse_y = math.abs((love.mouse.getY())/__scale+render_y/__scale-64)
	if love.keyboard.isDown 'a' then entity[0].hspeed = -0.05 end
	if love.keyboard.isDown 'd' then entity[0].hspeed = 0.05 end
	entity[0].hspeed = entity[0].hspeed * 0.8
	debug_dummy()
end