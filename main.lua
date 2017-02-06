function block_setBlockId(x,y,value)

math.randomseed(3)

local target_chunk = math.floor(x/16)
local rel_x = (math.floor(x)%16)
local rel_y = math.floor(y)
if rel_y < 63 or rel_y > 1 then block[target_chunk][rel_x][rel_y] = value end

print(target_chunk,rel_x,rel_y)

end

function block_getBlockId(x,y,value)

math.randomseed(1)

local target_chunk = math.floor(x/16)
local rel_x = (math.floor(x)%16)
local rel_y = math.floor(y)
if rel_y < 63 or rel_y > 1 then return block[target_chunk][rel_x][rel_y] end



end

function global_saveChunk(num)

	

end

--MONSTER CLASS----------------------------------------------------------------------------------------------------------------

player = {ypos = 64, xpos = 32, vspeed = 0, hspeed = 0, health = 20, ground = 0}
function player.tick(this)

if block_getBlockId(this.xpos,this.ypos-0.01) == 1 then ground = 1 end
if block_getBlockId(this.xpos,this.ypos-0.01) ~= 0 then this.vspeed = 0 this.ground = 0 end 

if this.ground == 0 then this.vspeed = this.vspeed - 0.01 end


this.xpos = this.xpos + this.hspeed
this.ypos = this.ypos + this.vspeed


end 
function player.render(this)

	love.graphics.rectangle("fill",this.xpos*__scale,__origin-this.ypos*__scale,5,5)
	love.graphics.print(this.ground .. " " .. this.xpos .. " " .. this.ypos,this.xpos*__scale,__origin-(this.ypos*__scale-32))
	love.graphics.translate(this.xpos * __scale,this.ypos * __scale)
end 

entity = {}
entity[0] = {}
setmetatable(entity[0],{__index = player})

-------------------------------------------------------------------------------------------------------------------------------


--LOVE FUNCTIONS---------------------------------------------------------------------------------------------------------------
function love.load()
	--Load terrain png and shear it into quads
	terrain = love.graphics.newImage("terrain.png")
	terrain:setFilter("nearest")
	qq = 0
	texture = {}
	for i=0,256,16 do
		for ii=0,256,16 do
			texture[qq] = love.graphics.newQuad(ii,i,16,16,256,256)
			qq = qq + 1
		end
	end
	--We're gonna have 16x64 chunks for now. Let's get generating. Raising.
	__scale = 3
	__origin = 64 * __scale
	block = {}
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
		n = love.math.noise((x)/80)*30
		block_setBlockId(x,math.abs(n)+32,3)
		print(n+26)
	end
	--Soiling.
	for chunk = 0,4,1 do 
		for x = 0,15,1 do
			for y = 0,63,1 do
				if block[chunk][x][y] == 3 then 
					for n = y,y-3,-1 do
						block[chunk][x][n] = 2
					end
					for n = y-3,0,-1 do
						block[chunk][x][n] = 1
					end 
				end
			end 
		end
	end --]]--
end

function love.draw()
	--Debug block grid
	for chunk = 0,4,1 do 
		love.graphics.line((chunk+1)*__scale*16,0,chunk*16*__scale,64)
		for x = 0,15,1 do
			for y = 63,0,1 do
				if block[chunk][x][y] > 0 then 
				--local image_x = block[chunk][x][y]%16
				--local image_y = math.floor(block[chunk][x][y]/16)
				love.graphics.draw(terrain,texture[block[chunk][x][y]],x*__scale+chunk*16*__scale,y*__scale,0,__scale/16,__scale/16)
				
				end
			end 
		end
	end
	love.graphics.print(love.timer.getFPS())
	for id,obj in pairs(entity) do
		obj:render()
	end	
end

function love.keypressed(key)

end





function love.update(dt)
	if dt < 1/30 then
		love.timer.sleep(1/30 - dt)
	end
	for id,obj in pairs(entity) do
		obj:tick()
	end	
end