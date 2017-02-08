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

return f_x*__scale+(f_chunk*16*__scale)-render_x ,__origin-(f_y-1)*__scale-render_y

end

block_solidLookupTable = {1,2,3,4,5,6,7,8}

function block_isSolid(x,y)

local id = block_getBlockId(x,y)
for key,value in pairs(block_solidLookupTable) do
	if id == value then return true end
end


end


function global_saveChunk(num)

	

end

--PLAYER CLASS-----------------------------------------------------------------------------------------------------------------

player = {ypos = 64, xpos = 32, vspeed = -0.1, hspeed = 0, health = 20, ground = 0}
function player.tick(this)
if this.ground == 0 then this.vspeed = this.vspeed - 0.01 end
if math.abs(this.vspeed) > 1 then this.vspeed = 0.9 end

if block_isSolid(this.xpos+0.5,math.ceil(this.ypos)) and block_isSolid(this.xpos-0.5,math.ceil(this.ypos)) then 
--Vertical collision
if this.vspeed < 0 then this.ypos = math.ceil(this.ypos) this.ground = 1 this.ypos = math.ceil(this.ypos) end
if this.vspeed > 0 then this.ypos = math.ceil(this.ypos-2) this.ground = 1 this.vspeed = 0 end


 end

if this.ground == 1 then this.vspeed = 0 this.ypos = math.ceil(this.ypos) end
this.hspeed = this.hspeed * 0.9
this.xpos = this.xpos + this.hspeed
this.ypos = this.ypos + this.vspeed


end 
function player.render(this)

	love.graphics.rectangle("fill",400-16,300-32,3,64)
	render_y = __origin-(this.ypos)*__scale-300
	render_x = (this.xpos)*__scale-400
	
	
end 

entity = {}
entity[0] = {}
setmetatable(entity[0],{__index = player})

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
		n = love.math.noise(pseudoseed,(x)/300)*10
		m = love.math.noise(pseudoseed,(x)/110)*20
		q = love.math.noise(pseudoseed,(x)/10)*2
		block_setBlockId(x,math.abs(n+q)+m+32,3)
		--print(n+26)
	end
	--Soiling.
	for chunk = 0,4,1 do 
		for x = 0,15,1 do
			for y = 0,63,1 do
				if block[chunk][x][y] == 3 then 
				m = math.ceil(math.abs(love.math.noise(x))*8)
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
	pseudoseed = os.time()%9999
	--Load terrain png and shear it into quads
	terrain = love.graphics.newImage("terrain.png")
	terrain:setFilter("nearest")
	qq = 0
	render_x = 0
	render_y = 0
	texture = {}
	for i=0,256,16 do
		for ii=0,256,16 do
			texture[qq] = love.graphics.newQuad(ii,i,16,16,256,256)
			qq = qq + 1
		end
	end
	__scale = 32
	__origin = 63 * __scale
	block = {}
	__generate()
end

function love.draw()
	--Debug block grid
	for chunk = 0,4,1 do 
		for x = 0,15,1 do
			for y = 0,63,1 do
				if block[chunk][x][y] > 0 and chunk > player.xpos/16-2 and chunk < player.xpos/16+2 then 
				i_x, i_y = block_getScreenCoordinates(chunk or 0,x or 0,y or 0)
				love.graphics.draw(terrain,texture[block[chunk][x][y]],i_x,i_y,0,__scale/16,__scale/16)
				end
			end 
		end
	end
	love.graphics.print(love.timer.getFPS())
	--love.graphics.print({render_x .. " " .. render_y},32,32)
	for id,obj in pairs(entity) do
		obj:render()
	end	
end

function love.keypressed(key)
	if key == 'r' then __generate() end
	if key == 'a' then entity[0].hspeed = -0.06 end
	if key == 'd' then entity[0].hspeed = 0.06 end
	if key == 'w' then entity[0].ypos = entity[0].ypos + 0.1 entity[0].ground = 0 entity[0].vspeed = 0.16 end
end





function love.update(dt)
	if dt < 1/30 then
		love.timer.sleep(1/60 - dt)
	end
	for id,obj in pairs(entity) do
		obj:tick()
	end	
end