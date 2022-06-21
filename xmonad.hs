import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.EwmhDesktops
import XMonad.Prompt.ConfirmPrompt
import XMonad.Util.SpawnOnce
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map as M

import qualified Icons
import qualified Colors
import XMonad.Hooks.InsertPosition

-- Use tux key as mod
myMod = mod4Mask

-- Use alacritty as terminal
myTerminal = "alacritty"

-- Define workspaces
-- FontAwesome Icons
myWorkspaces = [
    "1 " ++ Icons.terminal
    , "2 " ++ Icons.terminal
    , "3 " ++ Icons.terminal
    , "4 " ++ Icons.terminal
    , "5 " ++ Icons.terminal
    , "6 " ++ Icons.firefox
    , "7 " ++ Icons.firefox
    , "8 " ++ Icons.slack
    , "9 " ++ Icons.spotify
    , "0 " ++ Icons.mail
    , "- " ++ Icons.discord
    , "= " ++ Icons.zoom
    ]

-- Startup hook
myStartupHook = do
    spawn "$HOME/.config/polybar/launch.sh"
    spawnOnce "setbg $HOME/.cache/bg"

-- Commands to run in keybindings
dmenuCmd = "dmenu_run -fn 'Meslo LGS:pixelsize=24'"

-- Define custom keybindings
myKeys conf@XConfig {XMonad.modMask = modm, XMonad.terminal = term} = M.fromList $
    [
    -- Kill focused window
    ((modm .|. shiftMask, xK_q), kill)
    -- Exit out of XMonad
    , ((modm .|. shiftMask, xK_e), confirmPrompt def "exit" $ io exitSuccess)
    -- Reload XMonad config
    , ((modm .|. shiftMask, xK_r), spawn "xmonad --restart")
    -- Launch terminal emulator
    , ((modm, xK_Return), spawn term)
    -- Launch dmenu
    , ((modm,  xK_d), spawn dmenuCmd)
    -- Rotate through layouts
    , ((modm, xK_space ), sendMessage NextLayout)
    -- Reset to default layout
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    -- Shrink master pane
    , ((modm,  xK_h), sendMessage Shrink)
    -- Expand master pane
    , ((modm,  xK_l), sendMessage Expand)
    -- Prev window
    , ((modm,  xK_j), windows W.focusDown)
    -- Next window
    , ((modm,  xK_k), windows W.focusUp)
    -- Swap focused with next
    , ((modm .|. shiftMask,  xK_j), windows W.swapDown)
    -- Swap focused with prev
    , ((modm .|. shiftMask,  xK_k), windows W.swapUp)
    -- Swap focused with master
    , ((modm .|. shiftMask,  xK_m), windows W.swapMaster)
    -- Toggle window between floating and tiling
    , ((modm,  xK_f), toggleFloat)
    -- Push window to floating
    , ((modm .|. shiftMask,  xK_f), withFocused $ windows . centerFloat)
    -- Push window to tiling
    , ((modm, xK_t), withFocused $ windows . W.sink)
    ]
    ++
    -- M-[1..=]   -> Switch workspaces
    -- M-S-[1..=] -> Move window to workspace
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) ([xK_1 .. xK_9] ++ [xK_0, xK_minus, xK_equal])
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    -- TODO: have ctrl switch workspaces between windows
    -- See https://stackoverflow.com/q/54581406

centerRect = W.RationalRect 0.25 0.25 0.5 0.5

centerFloat w = W.float w centerRect

floatOrNot f n = withFocused $ \windowId -> do
    floats <- gets (W.floating . windowset)
    if windowId `M.member` floats -- if the current window is floating...
       then f
       else n

toggleFloat = floatOrNot (withFocused $ windows . W.sink) (withFocused $ windows . centerFloat)

-- Main entrypoint
main :: IO()
main = do
    -- Define config options
    xmonad $ ewmh $ ewmhFullscreen $ desktopConfig
        {
        terminal = myTerminal
        , modMask = myMod
        , workspaces = myWorkspaces
        , keys = myKeys
        , startupHook = myStartupHook
        , borderWidth = 1
        , focusedBorderColor = Colors.green
        , normalBorderColor = Colors.black
        , manageHook = manageHook desktopConfig <+> insertPosition Below Newer
        }
