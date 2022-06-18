import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.EwmhDesktops
import XMonad.Prompt.ConfirmPrompt
import XMonad.Hooks.DynamicLog
import XMonad.Util.SpawnOnce
import XMonad.Prompt
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map as M
import qualified DBus as D
import qualified DBus.Client as D
import qualified Codec.Binary.UTF8.String as UTF8

import qualified Icons

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
    spawnOnce "/home/will/.config/polybar/launch.sh"
    spawnOnce "setbg /home/will/.cache/bg"

-- Commands to run in keybindings
dmenuCmd = "dmenu_run -fn 'Meslo LGS:pixelsize=24'"

-- Define custom keybindings
myKeys conf@XConfig {XMonad.modMask = mod, XMonad.terminal = term} = M.fromList $
    [
    -- Kill focused window
    ((mod .|. shiftMask, xK_q), kill)
    -- Exit out of XMonad
    , ((mod .|. shiftMask, xK_e), confirmPrompt def "exit" $ io exitSuccess)
    -- Reload XMonad config
    , ((mod .|. shiftMask, xK_r), spawn "xmonad --restart")
    -- Launch terminal emulator
    , ((mod, xK_Return), spawn term)
    -- Launch dmenu
    , ((mod,  xK_d), spawn dmenuCmd)
    ]
    ++
    -- M-[1..=]   -> Switch workspaces
    -- M-S-[1..=] -> Move window to workspace
    [((m .|. mod, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) ([xK_1 .. xK_9] ++ [xK_0, xK_minus, xK_equal])
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

-- Main entrypoint
main :: IO()
main = do
    -- Spawn dbus client
    dbus <- D.connectSession
    D.requestName dbus (D.busName_ "org.xmonad.Log")
        [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]

    -- Define config options
    xmonad $ ewmh desktopConfig
        {
        terminal = myTerminal
        , modMask = mod4Mask
        , workspaces = myWorkspaces
        , keys = myKeys
        , logHook = dynamicLogWithPP (dbusLogHook dbus)
        }

-- A log hook for producing dbus events
dbusLogHook :: D.Client -> PP
dbusLogHook dbus = def {
        ppOutput = dbusOutput dbus
        , ppCurrent = id
        -- , ppCurrent = wrap ("%{B" ++ bg2 ++ "} ") " %{B-}"
    }

-- A helper to log events to dbus
dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str = do
    let signal = (D.signal objectPath interfaceName memberName) {
        D.signalBody = [D.toVariant str]
    }
    D.emit dbus signal
    where
        objectPath = D.objectPath_ "/org/xmonad/Log"
        interfaceName = D.interfaceName_ "org.xmonad.Log"
        memberName = D.memberName_ "Update"
