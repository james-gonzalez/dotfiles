-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

o.rebind("SUPER + SHIFT + W", "Typora", { launch = "typora --enable-wayland-ime" })

-- Monitor brightness (Dell AW3423DW via DDC/CI, step 10%)
o.bind("SUPER + F1", "Brightness down", "ddcutil setvcp 10 -- $(( $(ddcutil getvcp 10 --brief | awk '{print $4}') - 25 ))")
o.bind("SUPER + F2", "Brightness up", "ddcutil setvcp 10 -- $(( $(ddcutil getvcp 10 --brief | awk '{print $4}') + 25 ))")
