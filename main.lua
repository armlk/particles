local tick = require("tick")

function map(s1, e1, s2, e2, v)
	if v >= e1 then
		return e2
	end

	return s2 + (e2 - s2) * (v - s1) / (e1 - s1)
end

function love.load()
	tick.framerate = 60
	SCREEN_WIDTH, SCREEN_HEIGHT = 800, 800
	love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
	RADIUS = 8
	SIZE = 8
	GAP = 10
	G = 1e1
	DAMPENING = 0.9999
	pos, vel, acc = {}, {}, {}
	for i = 1, SIZE do
		for j = 1, SIZE do
			pos[(i - 1) * SIZE + j] = { x = 10 + i * RADIUS * GAP, y = 10 + j * RADIUS * GAP }
			vel[(i - 1) * SIZE + j] = { x = math.random(-30, 30), y = math.random(-30, 30) }
			acc[(i - 1) * SIZE + j] = { x = 0, y = 0 }
		end
	end
end

function love.update(dt)
	for i = 1, #pos do
		vel[i] = {
			x = ((vel[i].x * DAMPENING) or 0) + (acc[i].x or 0) * dt,
			y = ((vel[i].y * DAMPENING) or 0) + (acc[i].y or 0) * dt,
		}
		pos[i] = { x = (pos[i].x or 0) + (vel[i].x or 0) * dt, y = (pos[i].y or 0) + (vel[i].y or 0) * dt }

		if pos[i].x > SCREEN_WIDTH - RADIUS then
			pos[i].x = SCREEN_WIDTH - RADIUS
			vel[i].x = -vel[i].x
		elseif pos[i].x < RADIUS then
			pos[i].x = RADIUS
			vel[i].x = -vel[i].x
		end

		if pos[i].y < RADIUS then
			pos[i].y = RADIUS
			vel[i].y = -vel[i].y
		elseif pos[i].y > SCREEN_HEIGHT - RADIUS then
			pos[i].y = SCREEN_HEIGHT - RADIUS
			vel[i].y = -vel[i].y
		end
	end

	for i = 1, #pos do
		acc[i] = { x = 0, y = 0 }
	end

	for i = 1, #pos - 1 do
		for j = i + 1, #pos do
			local d = math.sqrt((pos[i].x - pos[j].x) ^ 2 + (pos[i].y - pos[j].y) ^ 2)
			local theta = math.atan2(pos[i].y - pos[j].y, pos[j].x - pos[i].x)

			if d < RADIUS * 2 then
				-- local offset = (RADIUS - d) * 2
				-- pos[i] = { x = pos[i].x - offset * math.cos(theta), y = pos[i].y + offset * math.sin(theta) }
				-- pos[j] = {
				-- 	x = pos[j].x + offset * math.cos(theta),
				-- 	y = pos[j].y - offset * math.sin(theta),
				-- }

				vel[i] = { x = -vel[i].x * math.cos(theta), y = vel[i].y * math.sin(theta) }
				vel[j] = { x = vel[j].x * math.cos(theta), y = -vel[j].y * math.sin(theta) }

				-- acc[i] = { x = -acc[i].x, y = -acc[i].y }
				-- acc[j] = { x = -acc[j].x, y = -acc[j].y }
			end

			local f = G / (d ^ 2)
			acc[i] = {
				x = (acc[i].x or 0) - f * math.cos(theta) * dt,
				y = (acc[i].y or 0) + f * math.sin(theta) * dt,
			}
			acc[j] = {
				x = (acc[j].x or 0) + f * math.cos(theta) * dt,
				y = (acc[j].y or 0) - f * math.sin(theta) * dt,
			}
		end
	end
end

function love.draw()
	for i = 1, #pos do
		local val = map(0, 200, 0, 1, math.sqrt(vel[i].x ^ 2 + vel[i].y ^ 2))
		love.graphics.setColor(val, 1 - val, 0)
		love.graphics.circle("fill", pos[i].x, pos[i].y, RADIUS)

		-- love.graphics.setColor(0, 0, 1)
		-- love.graphics.line(pos[i].x, pos[i].y, pos[i].x + vel[i].x, pos[i].y + vel[i].y)
		--
		love.graphics.setColor(0, 1, 0)
		love.graphics.line(pos[i].x, pos[i].y, pos[i].x + acc[i].x, pos[i].y + acc[i].y)
	end
end
