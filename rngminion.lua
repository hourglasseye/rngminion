--[[
Latest version (and instructions) at https://github.com/hourglasseye/rngminion

This script is a modification of the Lua_Script_4thGen_USA script
by u/Feder96 aka Real.96 of the Noob (New Order Of Breeding) forum
and was taken from http://pokerng.forumcommunity.net/?t=56443955&p=396434984
--]] 

mdword = memory.readdwordunsigned
mbyte = memory.readbyte
rshift = bit.rshift

-- Your Configuration
targetdelay = 633 -- the delay we want to hit
targetframe = 114 -- the frame we want to advance to
hasjournal = true -- whether a journal will open or not (will be set to false on HGSS)

-- Initialize on Script Startup
frame = 0
seed = 0
initial = 0
presstime = 0 -- to keep track of how much longer A should be pressed
pressstart = 2 -- how many frames to keep A pressed
pressbutton = {} -- which buttons to press

-- DPPt Delays
introdelay = 377 -- dismiss intro
startdelay = 68 -- dismiss start screen
journaldelay = 41 -- dismiss journal
if hasjournal then
	menudelay = 44 -- open menu with journal
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
	startdelay = 68 -- dismiss start screen
	menudelay = 50 -- open menu
end

-- Bot Script

journalstep = {}
if hasjournal then
	journalstep.d = journaldelay
	journalstep.b = {B=1}
	journalstep.m = "Dismissed Journal"
else
	journalstep.d = 0
	journalstep.b = {}
end
targetstep = {
	d=targetdelay-(introdelay + startdelay),
	b={A=1},
	m="Delay Hit"
}

steps = {
	{d=introdelay,	b={A=1},		m="Dismissed Intro"},
	{d=startdelay,	b={A=1},		m="Dismissed Start Menu"},
	targetstep, -- hit target delay
	journalstep, -- dismiss journal
	{d=menudelay,	b={X=1},		m="Menu Opened"},
	{d=3,			b={down=1},		m="Highlighted Pokemon Button"},
	{d=3,			b={A=1},		m="Opened Pokemon List"},
	{d=65,			b={right=1},	m="Highlighted 2nd Pokemon"},
	{d=3,			b={A=1},		m="Clicked 2nd Pokemon"},
	{d=3,			b={A=1},		m="Opened 2nd Pokemon's Summary"},
	{d=50,			b={},			m="Starting Advances"},
	{a=true}, -- start advances,
	{d=3,			b={B=1},		m="Frame Advances Done"}
}
stepidx = 1
laststepdelay = 0
onfirst = true

function bot()
	step = steps[stepidx]
	delay = getdelay()
	if step ~= nil then
		if step.a == true then
			-- here is where we do frame advancement via chatots
			if frame < targetframe then
				if delay >= laststepdelay + 5 then
					if onfirst then
						press({down=1})
						onfirst = false
					else
						press({up=1})
						onfirst = true
					end
					laststepdelay = delay
				end
			else
				stepidx = stepidx + 1
				laststepdelay = delay
			end
		elseif delay >= laststepdelay + step.d then
			-- here is where we press the button at the end of a step's delay
			press(step.b)
			if step.m ~= nil then
				print(step.m)
			end
			stepidx = stepidx + 1
			laststepdelay = delay
		end
	end

	if presstime > 0 then
		-- we need to keep the button pressed for more than one frame
		joypad.set(1, pressbutton)
		presstime = presstime - 1
	end
end

-- Start Pressing Button
function press(button)
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
	gui.text(0,150,string.format("Delay: %d", getdelay()))
	gui.text(0,160,string.format("Next Seed: %08X", buildseed()))
	gui.text(0,170,string.format("Initial Seed: %08X", initial))
	gui.text(0,180,string.format("PIDRNG Frame: %d", frame))
end

emu.registerbefore(bot)
gui.register(main)
emu.reset()