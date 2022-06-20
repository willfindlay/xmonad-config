# William Findlay's Xmonad Configs

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

label-urgent = %icon% %name%
label-urgent-background = ${colors.alert}
label-urgent-padding = 2

label-empty =
```
