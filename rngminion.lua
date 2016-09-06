-- This script is a modification of Feder96's Lua_Script_4thGen_USA lua script
-- taken from http://pokerng.forumcommunity.net/?t=56443955&p=396434984

mdword=memory.readdwordunsigned
mbyte=memory.readbyte
rshift=bit.rshift

-- Your Configuration
local targetdelay = 633 -- the delay we want to hit
local hasjournal = true -- whether a journal will open or not (will be set to false on HGSS)

-- Initialize on Script Startup
local frame = 0
local seed = 0
local initial = 0
local state = 0 -- to keep track of what we're doing now
local presstime = 0 -- to keep track of how much longer A should be pressed
local pressstart = 2 -- how many frames to keep A pressed
local pressbutton = {} -- which buttons to press

-- DPPt Delays
introdelay = 377 -- dismiss intro
startdelay = 445 -- dismiss start screen
journaldelay = 41 -- dismiss journal
if hasjournal then
	menudelay = 43 -- open menu with journal
else
	menudelay = 50 -- open menu
end

-- Detect Game Version
if mdword(0x02FFFE0C) == 0x45555043 then
	game = 'Pt'
	off = 0			-- Initial/Current Seed
	off2 = 0		-- Delay
	off3 = 0		-- IVRNG Frame
elseif mdword(0x02FFFE0C) == 0x45414441 then
	game = 'D'
	off = 0x5234	-- Initial/Current Seed
	off2 = 0x523C	-- Delay
	off3 = 0x5374	-- IVRNG Frame
elseif mdword(0x02FFFE0C) == 0x45415041 then
	game = 'P'
	off = 0x5234	-- Initial/Current Seed
	off2 = 0x523C	-- Delay
	off3 = 0x537C	-- IVRNG Frame
else
	game = 'HGSS'
	off = 0x11A94	-- Initial/Current Seed
	off2 = 0x11A90	-- Delay
	off3 = 0xEE98	-- IVRNG Frame

	-- HGSS Delays
	hasjournal = false -- no journal in HGSS
	introdelay = 245 -- dismiss intro
	startdelay = 313 -- dismiss start screen
	menudelay = 50 -- open menu
end

-- Poorly Written State Machine
function fsm()
	delay = getdelay()
	if state == 0 then
		state_waitforintro(delay)
	elseif state == 1 then
		state_waitforstart(delay)
	elseif state == 2 then
		state_waitfordelay(delay)
	elseif state == 3 then
		state_waitforjournal(delay)
	elseif state == 4 then
		state_waitformenu(delay)
	end
	if presstime > 0 then
		-- we need to keep the button pressed for more than one frame
		joypad.set(1, pressbutton)
		presstime = presstime - 1
	end
end

function state_waitforintro(delay)
	if delay < introdelay then
		return
	end
	press({A=1})
	state = 1
end

function state_waitforstart(delay)
	if delay < startdelay then
		return
	end
	press({A=1})
	state = 2
end

function state_waitfordelay(delay)
	if delay < targetdelay then
		return
	end
	press({A=1})
	if hasjournal then
		state = 3
	else
		state = 4
	end
end

function state_waitforjournal(delay)
	if delay < targetdelay + journaldelay then
		return
	end
	press({B=1})
	state = 4
end

function state_waitformenu(delay)
	maxdelay = targetdelay + menudelay
	if hasjournal then
		maxdelay = maxdelay + journaldelay
	end
	if delay < maxdelay then
		return
	end
	press({X=1})
	state = 5
end

-- Start Pressing Button
function press(button)
	print(button)
	pressbutton = button
	presstime = pressstart
end

function buildseed()
	delay=mdword(0x021BF6A8+off2)+21
	timehex=mdword(0x023FFDEC)
	datehex=mdword(0x023FFDE8)
	hour=string.format("%02X",(timehex%0x100)%0x40)	-- memory stores as decimal, but Lua reads as hex. Convert.
	minute=string.format("%02X",(rshift(timehex%0x10000,8)))
	second=string.format("%02X",(mbyte(0x02FFFDEE)))
	year=string.format("%02X",(mbyte(0x02FFFDE8)))
	month=string.format("%02X",(mbyte(0x02FFFDE9)))
	day=string.format("%02X",(mbyte(0x02FFFDEA)))
	ab=(month*day+minute+second)%256	-- Build Seed
	cd=hour
	cgd=delay%65536 +1		-- can tweak for calibration
	abcd=ab*0x100+cd
	efgh=(year+cgd)%0x10000
	nextseed=ab*0x1000000+cd*0x10000+efgh	-- Seed is built
	return nextseed		
end

function getdelay()
	return mdword(0x021BF6A8+off2)+21
end

local function main()
	currseed = mdword(0x021BFB14+off)
	seed = mdword(0x021BFB18+off)
	fcurrseed = mdword(0x021BFB14+off)
	finitial = mdword(0x021BFB18+off)
	frame = 1
	
	-- Detect initial seeding
	if mdword(0x021BFB18+off) == currseed then
		initial = mdword(0x021BFB14+off)
		if currseed ~= 0x00000000 then
			frame = 1
		end
	end
	if mdword(0x021BFB14) == 0x00000000 then	-- if seed is 0, reset everything
		frame = 1
	end

	function next(s)
		local a=0x41C6*(s%65536)+rshift(s,16)*0x4E6D
		local b=0x4E6D*(s%65536)+(a%65536)*65536+0x6073
		local c=b%4294967296
		return c
	end

	-- PIDRNG Frame Counting
	if fcurrseed ~= finitial then
		if fcurrseed ~= 0x00000000 then
			while finitial ~= fcurrseed do
				finitial = next(finitial)
				initial = mdword(0x021BFB18+off)
				frame = frame + 1
				if frame > 9999 then 
				break
				end
			end
		end
	end

	-- Print variables in corner of bottom screen
	gui.text(0,0,string.format("State: %d", state))
	gui.text(0,150,string.format("Delay: %d", getdelay()))
	gui.text(0,160,string.format("Next Seed: %08X", buildseed()))
	gui.text(0,170,string.format("Initial Seed: %08X", initial))
	gui.text(0,180,string.format("PIDRNG Frame: %d", frame))
end

emu.registerbefore(fsm)
gui.register(main)
emu.reset()