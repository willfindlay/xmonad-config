# William Findlay's Xmonad Configs

Warning: I'll probably be force pushing to main for a bit until things are more finalized.

## Polybar

```
[module/ewmh]
type = internal/xworkspaces

pin-workspaces = true
enable-click = true
enable-scroll = false

label-active = %icon% %name%
label-active-underline = ${colors.white}
label-active-padding = 2

label-occupied = %icon% %name%
label-occupied-padding = 2

label-urgent = %icon%
label-urgent-background = ${colors.alert}
label-urgent-padding = 2

label-empty =
```
