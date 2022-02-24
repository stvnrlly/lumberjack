--
-- require the `mods` module to gain access to hooks, menu, and other utility
-- functions.
--

local mod = require 'core/mods'

--
-- [optional] a mod is like any normal lua module. local variables can be used
-- to hold any state which needs to be accessible across hooks, the menu, and
-- any api provided by the mod itself.
--
-- here a single table is used to hold some x/y values
--

local state = {
  x = 0,
  start = 0,
  matron = "yes",
  sc = "no",
  crone = "no",
  jack = "no"
}


--
-- [optional] hooks are essentially callbacks which can be used by multiple mods
-- at the same time. each function registered with a hook must also include a
-- name. registering a new function with the name of an existing function will
-- replace the existing function. using descriptive names (which include the
-- name of the mod itself) can help debugging because the name of a callback
-- function will be printed out by matron (making it visible in maiden) before
-- the callback function is called.
--
-- here we have dummy functionality to help confirm things are getting called
-- and test out access to mod level state via mod supplied fuctions.
--

mod.hook.register("system_post_startup", "lumberjack startup", function()
  state.start = util.os_capture('date "+%Y-%m-%d %H:%M:%S"')
end)

mod.hook.register("script_pre_init", "lumberjack save point", function()
  state.start = util.os_capture('date "+%Y-%m-%d %H:%M:%S"')
end)


--
-- [optional] menu: extending the menu system is done by creating a table with
-- all the required menu functions defined.
--

local m = {}

m.key = function(n, z)
  if n == 2 and z == 1 then
    -- return to the mod selection menu
    mod.menu.exit()
  end
  if n==3 and z==1 then
    if state.x == 1 then
      -- dump log
      local services = ''
      if state.matron == 'yes' then
        services = services..' -u norns-matron.service'
      end
      if state.sc == 'yes' then
        services = services..' -u norns-sclang.service'
      end
      if state.crone == 'yes' then
        services = services..' -u norns-crone.service'
      end
      if state.jack == 'yes' then
        services = services..' -u norns-jack.service'
      end
      local s = norns.state.name..' - '
      local script = string.gsub(s,'/','-')
      os.execute('mkdir -p '.._path.data..'lumberjack/')
      os.execute('journalctl '..services..' --since="'..state.start..'" > "'.._path.data..'lumberjack/'..script..state.start..'.txt"')
    elseif state.x == 2 then
      state.matron = state.matron=="no" and "yes" or "no"
    elseif state.x == 3 then
      state.sc = state.sc=="no" and "yes" or "no"
    elseif state.x == 4 then
      state.crone = state.crone=="no" and "yes" or "no"
    elseif state.x == 5 then
      state.jack = state.jack=="no" and "yes" or "no"
    end
  end
  mod.menu.redraw()
end

m.enc=function(n,d)
  if d>0 then 
    d=1 
  elseif d<0 then 
    d=-1 
  end
  state.x=util.clamp(state.x+d,1,5)
  mod.menu.redraw()
end

m.redraw = function()
  screen.clear()
  -- save
  screen.level(state.x==1 and 15 or 5)
  screen.move(64,12)
  screen.text_center('get logs')
  -- toggle matron
  screen.level(state.x==2 and 15 or 5)
  screen.move(64,24)
  screen.text_center('matron: '..state.matron)
  -- toggle sc
  screen.level(state.x==3 and 15 or 5)
  screen.move(64,36)
  screen.text_center('supercollider: '..state.sc)
  -- toggle crone
  screen.level(state.x==4 and 15 or 5)
  screen.move(64,48)
  screen.text_center('crone: '..state.crone)
  -- toggle jack
  screen.level(state.x==5 and 15 or 5)
  screen.move(64,60)
  screen.text_center('jack: '..state.jack)
  
  screen.update()
end

-- m.redraw=function()
--   local yy=-8
--   screen.clear()
--   screen.level(state.x==1 and 15 or 5)
--   screen.move(64,20+yy)
--   screen.text_center(state.is_running and "online" or "offline")
--   if state.station~="" then
--     screen.level(5)
--     screen.move(64,32+yy)
--     screen.text_center("broadcast.norns.online/")
--     screen.move(64,40+yy)
--     screen.text_center(state.station..".mp3")
--   end
--   screen.level(state.x==2 and 15 or 5)
--   screen.move(64,52+yy)
--   screen.text_center("edit station name")
--   screen.level(state.x==3 and 15 or 5)
--   screen.move(35,62+yy)
--   screen.text_center("advertise:"..state.advertise)
--   screen.level(state.x==4 and 15 or 5)
--   screen.move(36+64,62+yy)
--   screen.text_center("archive:"..state.archive)
--   screen.update()
-- end

m.init = function() end -- on menu entry, ie, if you wanted to start timers
m.deinit = function() end -- on menu exit

-- register the mod menu
--
-- NOTE: `mod.this_name` is a convienence variable which will be set to the name
-- of the mod which is being loaded. in order for the menu to work it must be
-- registered with a name which matches the name of the mod in the dust folder.
--
mod.menu.register(mod.this_name, m)