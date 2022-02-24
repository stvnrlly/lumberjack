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
  start = 0
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

mod.hook.register("system_post_startup", "logger startup", function()
  state.start = util.os_capture('date "+%Y-%m-%d %H:%M:%S"')
end)

mod.hook.register("script_pre_init", "logger save point", function()
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
    -- dump log
    local s = norns.state.name..' - '
    local script = string.gsub(s,'/','-')
    os.execute('mkdir -p '.._path.data..'logger/')
    os.execute('journalctl -u norns-matron.service --since="'..state.start..'" > "'.._path.data..'logger/'..script..state.start..'.txt"')
  end
  mod.menu.redraw()
end

-- m.enc = function(n, d)
--   if n == 2 then state.x = state.x + d
--   elseif n == 3 then state.y = state.y + d end
--   -- tell the menu system to redraw, which in turn calls the mod's menu redraw
--   -- function
--   mod.menu.redraw()
-- end

m.redraw = function()
  screen.clear()
  screen.move(64,18)
  screen.text_center('press k3 to save')
  screen.move(64,26)
  screen.text_center('current script log')
  screen.move(64,42)
  screen.text_center('since: '..state.start)
  screen.update()
end

m.init = function() end -- on menu entry, ie, if you wanted to start timers
m.deinit = function() end -- on menu exit

-- register the mod menu
--
-- NOTE: `mod.this_name` is a convienence variable which will be set to the name
-- of the mod which is being loaded. in order for the menu to work it must be
-- registered with a name which matches the name of the mod in the dust folder.
--
mod.menu.register(mod.this_name, m)