function i_fucking_love_dick(ab)
	print("OwO") -- dummy function
end
   
-- globals.lua
-- show all global variables

local seen={} -- temporary value to make sure we dont loop anything twice 

local whitelist = { -- event whitelist
"TriggerEventInternal", 
"TriggerServerEventInternal", 
"TriggerClientEventInternal"
}  

local knownFuncs = {} -- functions we already know about

function dump(t,i) -- dumps global function table
	seen[t]=true
	local s={}
	local n=0
	for k in pairs(t) do
		--print("k = "..k)
		table.insert(knownFuncs, k)
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		--print(i,v)
		--print("i = "..i..", v = "..v )
		table.insert(knownFuncs,v)
		v=t[v]
		if type(v)=="table" and not seen[v] then
			dump(v,i.."\t")
		end
	end
end

function checkfornewfunc()
	local oldFuncs = {}
	for i,v in pairs(knownFuncs) do
		oldFuncs[i] = v -- create a 2nd table to compare infos with later on
	end
	seen={} -- reset this
	dump(_G, "") 

	for i,func in pairs(knownFuncs) do
		local found=false
		for o,f2 in pairs(oldFuncs) do 
			if f2 == func then 
				found=true -- if we are aware of it then mark it as seen, its not new
			end
		end
		for i, item in pairs(whitelist) do 
			if item == func then 
				found = true -- if its part of whitelist, mark it as seen, its not new
			end
		end
		if not found then
			print("something fishy is going on, func "..func.." is new.") -- what happens if a function seems new
		end
	end
end


AddEventHandler("wowtest", function() --test event to emulate a vm injection

	print("wowie") -- does not trigger anything


	function wowTester() -- this gets picked up

		print("created func") -- this doesn't
	end
	wowTester() -- make sure to trigger the function at least once
	i_fucking_love_dick() -- old created functions dont get picked up!
end)


RegisterCommand("chc", function(source, args, rawCommand)
	checkfornewfunc()
end, false)

RegisterCommand("event", function(source, args, rawCommand)
	TriggerEvent("wowtest")
end, false)
Citizen.CreateThread(function()
	dump(_G,"")
end)
