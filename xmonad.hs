import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.EwmhDesktops
import XMonad.Prompt.ConfirmPrompt
import XMonad.Hooks.DynamicLog
import XMonad.Util.SpawnOnce
import XMonad.Hooks.StatusBar
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map as M

import qualified Icons
import qualified Colors

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
    ]
    ++
    -- M-[1..=]   -> Switch workspaces
    -- M-S-[1..=] -> Move window to workspace
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) ([xK_1 .. xK_9] ++ [xK_0, xK_minus, xK_equal])
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

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
        }
