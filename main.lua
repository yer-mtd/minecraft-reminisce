function math.round(value)
if value > 0.5 then return math.ceil(value) end
if value < 0.5 then return math.floor(value) end
if value == 0.5 then return value end
end

function is_intersecting_player()
if lit_mouse_x+mouse_chunk*16 > entity[0].xpos-0.7 and lit_mouse_x+mouse_chunk*16 < entity[0].xpos+0.7 and lit_mouse_y > entity[0].ypos - 0.3 and lit_mouse_y < entity[0].ypos+2 then return true end
end


function debug_dummy() 
--For use with debug.debug()
end


function debug_draw() 
--For use with debug.debug()
end
ec = 0
function entity_spawn(etype,nx,ny)
ec = ec + 1
entity[ec] = {}
setmetatable(entity[ec],{__index = etype})
entity[ec].xpos = nx
entity[ec].ypos = ny
end

function block_setBlockId(x,y,value,isbg)

math.randomseed(3)

local target_chunk = tostring(math.floor(x/16))
local rel_x = (math.floor(x)%16)
local rel_y = math.floor(y)
if rel_y < 63 or rel_y > 1 then 
if isbg == 0 or nil then block[target_chunk][rel_x][rel_y] = value elseif isbg == 1 then
bgblock[target_chunk][rel_x][rel_y] = value elseif isbg == 2 then
bgblock2[target_chunk][rel_x][rel_y] = value elseif isbg == 3 then
fgblock[target_chunk][rel_x][rel_y] = value
end
end

--print(target_chunk,rel_x,rel_y)

end

function block_getBlockId(x,y,bg)



local target_chunk = tostring(math.floor(x/16))
local rel_x = (math.floor(x)%16)
local rel_y = math.floor(y)
if rel_y < 63 or rel_y > 1 then 
if not bg then return block[target_chunk][rel_x][rel_y] end
if bg then return bgblock[target_chunk][rel_x][rel_y] end
end



end

function block_getScreenCoordinates(f_chunk,f_x,f_y)

if f_y == nil then

f_y = f_x
f_x = f_chunk
f_chunk = math.floor(f_x/16)

end

return math.floor(f_x*__scale+(f_chunk*16*__scale)-render_x) ,math.floor(__origin-(f_y-1)*__scale-render_y)

end

block_solidLookupTable = {1,2,3,4,5,6,7,8}

function block_isSolid(x,y,bg)

local id = block_getBlockId(math.floor(x) or 0,math.ceil(y or 0),bg)
for key,value in pairs(block_solidLookupTable) do
	if id == value then return true end
end


end


function global_saveChunk(num,dir)
dir = dir or "saves"
love.filesystem.remove("saves/chunk_" .. num)
love.filesystem.remove("saves/bgchunk_" .. num)
local column = ""
	for x = 0,15,1 do
		for y = 0,63,1 do
			column = column .. block[tostring(num)][x][y] .. ", "
		end 
		column = column .. "\n"
	end
love.filesystem.append("saves/chunk_" .. num, column)
love.filesystem.remove("saves/bg_chunk_" .. num)
local column = ""
	for x = 0,15,1 do
		for y = 0,63,1 do
			column = column .. bgblock[tostring(num)][x][y] .. ", "
		end 
		column = column .. "\n"
	end
love.filesystem.append("saves/bgchunk_" .. num, column)
end
function global_loadChunk(num,dir)
dir = dir or "saves"
	x = 0
	local linetable = {}
	for line in assert(love.filesystem.lines("saves/chunk_"..num)) do
		linetable[x] = line
		x = x + 1
	end 
	for x = 0,15,1 do
		y = 0
		for b in string.gmatch(linetable[x],"%d+") do
		block[tostring(num)][x][y] = tonumber(b)
			y = y + 1
		end 
	end
	x = 0
	local linetable = {}
	for line in assert(love.filesystem.lines("saves/bgchunk_"..num)) do
		linetable[x] = line
		x = x + 1
	end 
	for x = 0,15,1 do
		y = 0
		for b in string.gmatch(linetable[x],"%d+") do
		
		bgblock[tostring(num)][x][y] = tonumber(b)
			y = y + 1
		end 
	end
end


function entity_getScreenCoordinates(x,y)

return x*__scale-render_x,__origin-(y-1)*__scale-render_y

end
function entity_castShadow(this,x,y,bg)
t,ty = block_getLowerBlock(x,y,bg)
qx,qy = entity_getScreenCoordinates(x,y-ty)
qy = qy + this.vshift
love.graphics.setColor(0,0,0,255-ty*50)
love.graphics.ellipse("fill",qx,qy,8,4)
love.graphics.setColor(255,255,255,255)
love.graphics.print(love.mouse.getX() .. " " .. love.mouse.getY() .. " " .. qx .. " " .. qy,64,64)
end


function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function entityphysics(this)



local xcol = 0
local ycol = 0
if this.ground == 0 then this.vspeed = this.vspeed - 0.005 end
if this.vspeed < -0.8 then this.vspeed = -0.8 end

if this.hspeed > 0 then
if block_isSolid(this.xpos + this.hspeed + this.xhit,this.ypos+0.5,this.bg) or block_isSolid(this.xpos + this.hspeed + this.xhit,this.ypos+1.5,this.bg) then this.hspeed = 0 xcol = 1 end
end

if this.hspeed < 0 then
if block_isSolid(this.xpos + this.hspeed - this.xhit,this.ypos+0.5,this.bg) or block_isSolid(this.xpos + this.hspeed - this.xhit,this.ypos+1.5,this.bg) then this.hspeed = 0 xcol = 1 end
end
this.xpos = this.xpos + this.hspeed
this.ypos = this.ypos + this.vspeed
if this.hspeed > 0 and this.hspeed < 0.001 then this.hspeed = 0 end
if this.hspeed < 0 and this.hspeed > -0.001 then this.hspeed = 0 end



if this.vspeed < 0 then
if block_isSolid(this.xpos+this.xhit,this.ypos,this.bg) or block_isSolid(this.xpos-this.xhit,this.ypos,this.bg) then this.vspeed = 0 this.ground = 1 this.ypos = math.ceil(this.ypos) ycol = 1 end
end
 
if this.vspeed > 0 then
if block_isSolid(this.xpos+this.xhit,this.ypos+2,this.bg) or block_isSolid(this.xpos-this.xhit,this.ypos+2,this.bg) then this.vspeed = 0 ycol = 1 end
end

if not block_isSolid(this.xpos + this.xhit,this.ypos,this.bg) and not block_isSolid(this.xpos - this.xhit,this.ypos,this.bg) then this.ground = 0 end

return xcol,ycol

end

--Block top textures are listed here
btop = {}
btop[3] = 0
btop[8] = 9



function graphics_update()
	render_x = math.floor(render_x)
	render_y = math.floor(render_y)
	local localplayer = entity[0]
	local renderblock = 0
	local block = block
	bgbatch:clear()
	disbatch:clear()
	ffacebatch:clear()
	bg2batch:clear()
	fgbatch:clear()
	for chunk = math.max(math.floor(localplayer.xpos/16)-2,-chunkcount),math.min(math.floor(localplayer.xpos/16)+2,chunkcount),1 do 
		for x = 0,15,1 do
			for y=0,63,1 do
				--if x+chunk*16 > entity[0].xpos-14 and x+chunk*16 < entity[0].xpos+13 and y>entity[0].ypos-9 and y<entity[0].ypos+12 then 
				if x+chunk*16 > localplayer.xpos-17 and x+chunk*16 < localplayer.xpos+16 and y>localplayer.ypos-17 and y<localplayer.ypos+16 then 
					renderblock = renderblock + 1
				if bgblock[tostring(chunk)][x][y] > 0 and chunk > localplayer.xpos/16-2 and chunk < localplayer.xpos/16+1 then 
					local i_x, i_y = block_getScreenCoordinates(chunk or -1,x or 0,y or -1)
					i_x = i_x + render_x
					i_y = i_y + render_y - 8
					if bgblock[tostring(chunk)][x][y+1] == 0 then
					bgbatch:setColor(255,255,255)
					bgbatch:add(texture[btop[bgblock[tostring(chunk)][x][y]] or bgblock[tostring(chunk)][x][y]],i_x,i_y-__scale/4+4,0,__scale/16,__scale/16/4)
					end
					bgbatch:setColor(178,178,178)
					bgbatch:add(texture[(bgblock[tostring(chunk)][x][y])],i_x,i_y+4,0,__scale/16,__scale/16)
				end
					-----
				if block[tostring(chunk)][x][y]> 0 and chunk > localplayer.xpos/16-2 and chunk < localplayer.xpos/16+1 then 
					local i_x, i_y = block_getScreenCoordinates(chunk or -1,x or 0,y or -1)
					i_x = i_x + render_x
					i_y = i_y + render_y
					if block[tostring(chunk)][x][y+1] == 0 then
					disbatch:setColor(255,255,255)
					disbatch:add(texture[btop[block[tostring(chunk)][x][y]] or block[tostring(chunk)][x][y]],i_x,i_y-__scale/4+4,0,__scale/16,__scale/16/4)
					end
					ffacebatch:setColor(210,210,210)
					ffacebatch:add(texture[(block[tostring(chunk)][x][y])],i_x,i_y+4,0,__scale/16,__scale/16)
				end
					----
				if bgblock2[tostring(chunk)][x][y]> 0 and chunk > localplayer.xpos/16-2 and chunk < localplayer.xpos/16+1 then 
					local i_x, i_y = block_getScreenCoordinates(chunk or -1,x or 0,y or -1)
					i_x = i_x + render_x
					i_y = i_y + render_y - 16
					if bgblock2[tostring(chunk)][x][y+1] == 0 then
					bg2batch:setColor(255,255,255)
					bg2batch:add(texture[btop[bgblock2[tostring(chunk)][x][y]] or bgblock2[tostring(chunk)][x][y]],i_x,i_y-__scale/4+4,0,__scale/16,__scale/16/4)
					end
					bg2batch:setColor(140,140,140)
					bg2batch:add(texture[(bgblock2[tostring(chunk)][x][y])],i_x,i_y+4,0,__scale/16,__scale/16)
				end
					----
				if fgblock[tostring(chunk)][x][y]> 0 and chunk > localplayer.xpos/16-2 and chunk < localplayer.xpos/16+1 then 
					local i_x, i_y = block_getScreenCoordinates(chunk or -1,x or 0,y or -1)
					i_x = i_x + render_x
					i_y = i_y + render_y + 8
					if fgblock[tostring(chunk)][x][y+1] == 0 then
					fgbatch:setColor(255,255,255,a)
					fgbatch:add(texture[btop[fgblock[tostring(chunk)][x][y]] or fgblock[tostring(chunk)][x][y]],i_x,i_y-__scale/4+4,0,__scale/16,__scale/16/4)
					end
					fgbatch:setColor(210,210,210,a)
					fgbatch:add(texture[(fgblock[tostring(chunk)][x][y])],i_x,i_y+4,0,__scale/16,__scale/16)
				end
				end
			end 
		end
	end	
print(renderblock)
end
function graphics_cursor()
	love.graphics.rectangle("fill",love.mouse.getX()-8,love.mouse.getY(),16,2)
	love.graphics.rectangle("fill",love.mouse.getX()-1,love.mouse.getY()-7,2,16)
	love.mouse.setVisible(false)
end

function radian_ray(rx,ry,ang,dist,maxint,func)
	interrupts = 0
	maxint = maxint or 99
	local xdir = math.cos(ang)
	local ydir = math.sin(ang)
	for i=0,dist,1 do
		rx = rx-xdir
		ry = ry+ydir
		--print('Literal',math.floor(rx),math.floor(ry))
		--print('Chunk',math.floor(rx/16),math.floor(rx)%16,math.abs(math.floor(ry)))
		--print(block[tostring(math.floor(rx/16))][math.floor(rx)%16][math.abs(math.floor(ry))])
		if block[tostring(math.floor(rx/16))][math.floor(rx)%16][math.abs(math.floor(ry))] ~= 0 then interrupts = interrupts + 1 end
		if func then func(tostring(math.floor(rx/16)),math.floor(rx)%16,math.abs(math.floor(ry))) end
	end
	return interrupts
end

function explosion(x,y,radius)
print(math.random(math.pi*2))
for i=0,64,1 do
radian_ray(entity[0].xpos,entity[0].ypos+2,math.random(math.pi*2)+math.random(),math.random(1,5),5,function (q,w,e) if interrupts < 3 then block[q][w][e] = 0 else return 1 end end)
end
graphics_update()
end

function block_getLowerBlock(x,y,bg)
local sy = y
repeat 
sy = sy - 1
until block_getBlockId(x,sy,bg) ~= 0
--print(y,sy)
return block_getBlockId(x,sy,bg), y - math.floor(sy)


end

--PLAYER CLASS-----------------------------------------------------------------------------------------------------------------
oldxpos = 0
oldypos = 0
player = {vshift = 0, n = 0, facing = 0, xhit = 0.3 , yhit = 2, cdt = 0, ypos = 64, xpos = 0, vspeed = 0, hspeed = 0, health = 20, ground = 1}
function player.tick(this)

if love.keyboard.isDown(keyBackgroundMode) and not (block_isSolid(math.floor(this.xpos),this.ypos+1.5,1) or block_isSolid(math.floor(this.xpos),this.ypos+0.5,1)) then
this.bg = true end
if not love.keyboard.isDown(keyBackgroundMode) and not (block_isSolid(math.floor(this.xpos),this.ypos+1.5) or block_isSolid(math.floor(this.xpos),this.ypos+0.5)) then
this.bg = false end
entityphysics(this)

end 
handanim = 0
function player.render(this)
	if this.xpos + 3 < oldxpos or this.xpos - 3 > oldxpos or this.ypos + 3 < oldypos or this.ypos - 3 > oldypos then graphics_update() oldxpos = this.xpos oldypos = this.ypos end
	--print(this.xpos,oldxpos)
	if not pause then this.n = this.n + 0.04 + math.abs(this.hspeed) end
	handanim = handanim + 0.007
	handval = math.sin(handanim)/15 * this.facing
	--if this.hspeed ~= 0 then handanim = -0.1 end
	if math.abs(this.hspeed) < 0.01 then this.n = 0 end 
	this.p_x = 400-2
	if this.p_x < love.mouse.getX() then this.facing = 1 else this.facing = -1 end
	this.p_y = 300-__scale - math.abs(math.sin(this.n)*2) + this.vshift
	if this.bg and this.vshift > -8 then this.vshift = this.vshift - 1 end
	if this.vshift < 0 and not this.bg then this.vshift = this.vshift + 1 end
	--love.graphics.rectangle("fill",400-2,300-__scale,4,__scale*2)
	--love.graphics.print(this.hspeed .. " " .. this.vspeed .. " \n" .. this.xpos .. " " .. this.ypos,32,32)
	ix,iy = block_getScreenCoordinates(this.xpos+2,this.ypos)
	--offset_factor = mouse_x-32+mouse_chunk*16
	love.graphics.draw(char_sprite,playermodel.backarm,this.p_x+2,this.p_y+16,math.sin(-this.n)*(this.hspeed*20)-handval,64/__scale*this.facing,64/__scale,2,0)
	love.graphics.draw(char_sprite,playermodel.body,this.p_x+2,this.p_y,0,64/__scale*this.facing,64/__scale,2,-8)
	if this.facing == 1 then headangle = math.atan2(love.mouse.getY()-(this.p_y+8),love.mouse.getX()-this.p_x) else headangle = math.atan2((this.p_y+8)-love.mouse.getY(),this.p_x-love.mouse.getX()) end 
	love.graphics.draw(char_sprite,playermodel.head,this.p_x+2,this.p_y+16,headangle,64/__scale*this.facing,64/__scale,4,8)
	love.graphics.draw(char_sprite,playermodel.hat,this.p_x+2,this.p_y+16,headangle,(64/__scale+0.3)*this.facing,64/__scale+0.3,4,8)
	love.graphics.draw(char_sprite,playermodel.frontarm,this.p_x+2,this.p_y+16,math.sin(this.n)*(this.hspeed*20)+handval,64/__scale*this.facing,64/__scale,2,0)
	love.graphics.draw(char_sprite,playermodel.backleg,this.p_x+2,this.p_y+40,math.sin(this.n)*(this.hspeed*20),64/__scale*this.facing,64/__scale,2,0)
	love.graphics.draw(char_sprite,playermodel.frontleg,this.p_x+2,this.p_y+40,math.sin(-this.n)*(this.hspeed*20),64/__scale*this.facing,64/__scale,2,0)
	
	--print(offset_factor)
	--print(facing)
end 
 
monster = {aim = 1, ai = 0, n = 0, facing = 1, xhit = 0.3 , yhit = 2, cdt = 0, ypos = 0, xpos = 0, vspeed = 0, hspeed = 0, health = 20, ground = 1}
function monster.tick(this)

if this.ai == 0 then 
this.ai = math.random(260,620)
this.aim = -this.aim
end
this.ai = this.ai - 1
if math.abs(this.hspeed) < 0.04 then this.hspeed = this.hspeed + this.aim * 0.002 end
xcol,ycol = entityphysics(this)
if xcol == 1 and this.ground == 1 then this.vspeed = 0.12 this.ground = 0 end
end
steve = love.graphics.newImage("steve.png")
steve:setFilter('nearest')
function monster.render(this)
	if this.hspeed > 0 then this.facing = 1 end
	if this.hspeed < 0 then this.facing = -1 end
	--print(this.xpos,oldxpos)
	if not pause then this.n = this.n + 0.04 + math.abs(this.hspeed) end
	handval = math.sin(handanim)/15 * this.facing
	--if this.hspeed ~= 0 then handanim = -0.1 end
	if math.abs(this.hspeed) < 0.01 then this.n = 0 end 
	local p_x, p_y = entity_getScreenCoordinates(this.xpos,this.ypos+2)
	--if p_x < 0 then p_x = p_x + 16*__scale end
	
	--if p_x < love.mouse.getX() then this.facing = 1 else this.facing = -1 end
	love.graphics.draw(steve,playermodel.backarm,p_x+2,p_y+16,math.sin(-this.n)*(this.hspeed*20)-handval,64/__scale*this.facing,64/__scale,2,0)
	love.graphics.draw(steve,playermodel.body,p_x+2,p_y,0,64/__scale*this.facing,64/__scale,2,-8)
	headangle = 0
	love.graphics.draw(steve,playermodel.head,p_x+2,p_y+16,headangle,64/__scale*this.facing,64/__scale,4,8)
	love.graphics.draw(steve,playermodel.hat,p_x+2,p_y+16,headangle,(64/__scale+0.3)*this.facing,64/__scale+0.3,4,8)
	love.graphics.draw(steve,playermodel.frontarm,p_x+2,p_y+16,math.sin(this.n)*(this.hspeed*20)+handval,64/__scale*this.facing,64/__scale,2,0)
	love.graphics.draw(steve,playermodel.backleg,p_x+2,p_y+40,math.sin(this.n)*(this.hspeed*20),64/__scale*this.facing,64/__scale,2,0)
	love.graphics.draw(steve,playermodel.frontleg,p_x+2,p_y+40,math.sin(-this.n)*(this.hspeed*20),64/__scale*this.facing,64/__scale,2,0)

end


-------------------------------------------------------------------------------------------------------------------------------

function __generate()
__prep()
--highseed = math.floor(os.time()%9999999999 / 100000)
--lowseed = (os.time()%9999999999 / 100000)%math.floor(os.time()%9999999999/100000)*100000
--rint(pseudoseed,os.time()%9999999999)
pseudoseed = os.time()%999999

--pseudoseed = 0
--We're gonna have 16x64 chunks for now. Let's get generating. 
	--Raising.
	for x = -chunkcount*16,chunkcount*16-1,1 do
		n = love.math.noise(pseudoseed,x/30)*10
		m = love.math.noise(pseudoseed,x/70)*10
		q = love.math.noise(pseudoseed,x/3)*2
		block_setBlockId(x,math.abs(n+q)+32+m,3,0)
		block_setBlockId(x,math.abs(n+q)+32+m,3,1)
		block_setBlockId(x,math.abs(n+q)+32+m,3,2)
		block_setBlockId(x,math.abs(n+q)+32+m,3,3)
		--print(n+26)
	end
	--Soiling.
	for chunk = -chunkcount,chunkcount,1 do 
		for x = 0,15,1 do
			for y = 0,63,1 do
				if block[tostring(chunk)][x][y] == 3 then 
				m = 3+math.floor(love.math.noise(pseudoseed,x/3)*2)
					for n = y-1,y-m,-1 do
						block[tostring(chunk)][x][n] = 2
						bgblock[tostring(chunk)][x][n] = 2
						bgblock2[tostring(chunk)][x][n] = 2
						fgblock[tostring(chunk)][x][n] = 2
					end
					for n = y-m,0,-1 do
						block[tostring(chunk)][x][n] = 1
						bgblock[tostring(chunk)][x][n] = 1
						bgblock2[tostring(chunk)][x][n] = 1
						fgblock[tostring(chunk)][x][n] = 1
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
				--print (chunk,x,y,block[tostring(chunk)][x][y],bgblock[tostring(chunk)][x][y])
				if cave > 0.6 and block[tostring(chunk)][x][y] ~= 0 then bgblock[tostring(chunk)][x][y] = block[tostring(chunk)][x][y] fgblock[tostring(chunk)][x][y] = 0 block[tostring(chunk)][x][y] = 0 end 
				end 
		end
	end


end


function __prep()
	block = {}
	bgblock = {}
	bgblock2 = {}
	fgblock = {}
	chunkcount = 16
	for chunk = -chunkcount,chunkcount,1 do 
		bgblock[tostring(chunk)] = {}
		bgblock2[tostring(chunk)] = {}
		block[tostring(chunk)] = {}
		fgblock[tostring(chunk)] = {}
		for x = 0,15,1 do
			bgblock[tostring(chunk)][x] = {}
			bgblock2[tostring(chunk)][x] = {}
			block[tostring(chunk)][x] = {}
			fgblock[tostring(chunk)][x] = {}
			for y = 0,63,1 do
				bgblock[tostring(chunk)][x][y] = 0
				bgblock2[tostring(chunk)][x][y] = 0
				block[tostring(chunk)][x][y] = 0
				fgblock[tostring(chunk)][x][y] = 0
			end 
		end
	end


end


--LOVE FUNCTIONS---------------------------------------------------------------------------------------------------------------






function love.load()
	http = require("socket.http")
  --check if settings file exists and if not create one from the pastebin U9wyV2jL
  if not love.filesystem.exists("settings.lua") then 
    b, c, h = http.request("http://pastebin.com/raw/U9wyV2jL")
    love.filesystem.write("settings.lua", b)
    print "No settings file located. Downloading new one."
  end
  settings = require("settings")
	local b, c, h = http.request("http://mcapi.ca/rawskin/" .. playerSkin)
	love.filesystem.write("skin.png", b)
	font = love.graphics.newFont("minecraft.ttf",16)
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
		for j=0,240,16 do
			texture[qq] = love.graphics.newQuad(j,i,16,16,256,256)
			qq = qq + 1
		end
	end
	disbatch = love.graphics.newSpriteBatch(terrain,1500,'dynamic')
	bgbatch = love.graphics.newSpriteBatch(terrain,1500,'dynamic')
	ffacebatch = love.graphics.newSpriteBatch(terrain,1500,'dynamic')
	bg2batch = love.graphics.newSpriteBatch(terrain,1500,'dynamic')
	fgbatch = love.graphics.newSpriteBatch(terrain,1500,'dynamic')
	__scale = 32
	__origin = 63 * __scale
	__prep()
	__height = {}
	entity = {}
	entity[0] = {}
	setmetatable(entity[0],{__index = player})
	if not love.filesystem.exists("saves/") then love.filesystem.createDirectory("saves") print "No save directory detected. Created." __generate() else

	for c = -chunkcount,chunkcount,1 do
		global_loadChunk(c)
	end
	end
	master=socket.tcp()
	print(master:bind("*",25564))
	skygrad = love.graphics.newImage("sky.png")
	__generate()
end







function love.draw()
	render_x = math.floor(render_x)
	render_y = math.floor(render_y)
	love.graphics.setLineWidth(0.1)
	local i_x, i_y = entity_getScreenCoordinates(mouse_x+mouse_chunk*16,mouse_y)
	i_x = i_x --+ render_x
	i_y = i_y -8--+ render_y - 8
	love.graphics.draw(skygrad)
	render_y = __origin-(entity[0].ypos)*__scale-300
	render_x = (entity[0].xpos)*__scale-400
	love.graphics.draw(bg2batch,-render_x,-render_y)
	love.graphics.draw(bgbatch,-render_x,-render_y)
	if love.keyboard.isDown(keyBackgroundMode) then
	i_y = i_y -8--+ render_y - 8
	love.graphics.setColor(20,20,20)
	love.graphics.rectangle("line",i_x,i_y+12,32,32)
	if bgblock[tostring(mouse_chunk)][mouse_x][mouse_y] == 0 or bgblock[tostring(mouse_chunk)][mouse_x][mouse_y+1] == 0 then love.graphics.rectangle("line",i_x,i_y+4,32,8) end
	love.graphics.setColor(255,255,255)
	end
	for id,obj in pairs(entity) do
		if obj.bg then obj:render() end 
	end
	if block[tostring(math.floor(entity[0].xpos/16))][math.floor(entity[0].xpos)%16][math.floor(entity[0].ypos+1)] ~= 0 and block[tostring(math.floor(entity[0].xpos/16))][math.floor(entity[0].xpos)%16][math.floor(entity[0].ypos + 2)] ~= 0 then love.graphics.setColor(255,255,255,90) end
	love.graphics.draw(disbatch,-render_x,-render_y)
	for id,obj in pairs(entity) do
		if not obj.bg then obj:render() end
	end
	love.graphics.draw(ffacebatch,-render_x,-render_y)
	if fgblock[tostring(math.floor(entity[0].xpos/16))][math.floor(entity[0].xpos)%16][math.floor(entity[0].ypos+1)] ~= 0 and fgblock[tostring(math.floor(entity[0].xpos/16))][math.floor(entity[0].xpos)%16][math.floor(entity[0].ypos + 2)] ~= 0 then love.graphics.setColor(255,255,255,90) end
	love.graphics.draw(fgbatch,-render_x,-render_y)
	for id,obj in pairs(entity) do
		entity_castShadow(obj,obj.xpos,obj.ypos + 1,obj.bg)
	end
	love.graphics.print(collectgarbage("count")*1024,0,32)
	local draw = nil
	local col = nil
	love.graphics.draw(terrain,texture[selectedblock],700,64,0,3)
	love.graphics.setColor(128,128,128,255)
	love.graphics.print(love.timer.getFPS() .. " // " .. gdt,4,4)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print(love.timer.getFPS() .. " // " .. gdt,2,2)
	local cur_time = love.timer.getTime()
	love.timer.sleep(next_time - cur_time)
		love.graphics.setColor(0,0,0,64)
		--love.graphics.rectangle("fill",0,0,800,600)
		love.graphics.setColor(255,255,255,255)
	if pmenu then
		for name,func in pairs(buttons) do
			tl = tablelength(buttons)
			if love.mouse.getX() > 400 and love.mouse.getX() < 400+256 and love.mouse.getY() > 300 - (tl * 64) / 2 and love.mouse.getY() < 300 - (tl * 64) - 64 / 2 then love.graphics.setColor(200,200,200) else love.graphics.setColor(0,0,0) end
			love.graphics.rectangle("fill",400,300,256,32)
			love.graphics.setColor(128,128,128)
			love.graphics.rectangle("fill",402,302,252,28)
			love.graphics.setColor(64,64,64,255)
			love.graphics.printf(name,402,310,256,"center")
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf(name,400,308,256,"center")
		end

	end
	if not love.keyboard.isDown(keyBackgroundMode) then
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line",i_x,i_y+12,32,32)
	if block[tostring(mouse_chunk)][mouse_x][mouse_y] == 0 or block[tostring(mouse_chunk)][mouse_x][mouse_y+1] == 0 then love.graphics.rectangle("line",i_x,i_y+4,32,8) end
	love.graphics.setColor(255,255,255)
	end
	graphics_cursor()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
end
buttons = {}
buttons["Test"] = function ()

print 'Clicked'


end
function love.mousepressed( x, y, button, istouch )
	if not pause then 
		if mouse_y < 63 then
			if button == 1 and not love.keyboard.isDown(keyBackgroundMode) then block[tostring(mouse_chunk)][mouse_x][mouse_y] = 0 end
			if button == 1 and love.keyboard.isDown(keyBackgroundMode) then bgblock[tostring(mouse_chunk)][mouse_x][mouse_y] = 0 end
			if button == 2 and love.keyboard.isDown(keyBackgroundMode) then bgblock[tostring(mouse_chunk)][mouse_x][mouse_y] = selectedblock end
			if button == 2 and not love.keyboard.isDown(keyBackgroundMode) then block[tostring(mouse_chunk)][mouse_x][mouse_y] = selectedblock end
		end
		graphics_update()
		oldxpos = entity[0].xpos
		oldypos = entity[0].ypos
	end --of gameplay mode
	if pause then
		
		
		
	end
end

function love.wheelmoved(x, y)
	selectedblock = ((selectedblock) + y)%256
end


function love.keypressed(key)
	if key == keyExplosion then explosion(entity[0].xpos,entity[0].ypos,5) end
	if key == keyCrash then debug.debug() end
	if key == keyRegenerate then __generate() entity[0].ypos = 63 entity[0].ground = 0 end
	if key == keyJump and entity[0].ground == 1 then entity[0].ypos = entity[0].ypos + 0.1 entity[0].ground = 0 entity[0].vspeed = 0.12 entity[0].cdt = gdt end
	if key == keySpawnMonster then
		entity_spawn(monster,entity[0].xpos,63)
		print(entity[0].xpos)
	end
end





function love.update(dt)
gdt = dt
next_time = next_time + min_dt
	render_x = math.floor(render_x)
	render_y = math.floor(render_y)
	if not pause or multiplayer then
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
		
	end
collectgarbage()
if isserver then


end
end

function love.quit()
	love.window.close( )
	print 'See you next time!'
 	for c = -chunkcount,chunkcount,1 do
		global_saveChunk(c)
		io.write(".")
	end
end

function becomeserver()
	master:listen(1)
	isserver = 1
	master:settimeout(0,"b")
end