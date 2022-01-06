﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Other settings
#SingleInstance, Force
#WinActivateForce
DetectHiddenWindows, On

; Check DisableLockWorkstation
RegRead, DisableLockWorkstation, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System, DisableLockWorkstation
If (DisableLockWorkstation != 1)
{
    MsgBox, 0, Warning, Please DISABLE locking workstation first!
    ExitApp
}

RunOrRaiseRegularApps(ClassName, ProcessName, Target)
{
    ; Define matching criteria
    WinTitle := "ahk_class " ClassName " ahk_exe " ProcessName

    ; Create a unique window group
    SplitPath, ProcessName,,,, ProcessNameNoExt
    GroupName := ClassName ProcessNameNoExt
    GroupAdd, %GroupName%, %WinTitle%

    If (!WinExist(WinTitle))
        Run, %Target%
    Else If (WinActive(WinTitle))
        GroupActivate, %GroupName%, R
    Else
    {
        ; Windows are retrieved in order from topmost to bottommost
        WinGet, Windows, List, % "ahk_group " GroupName
        WinActivate, % "ahk_id " Windows%Windows%
    }
    Return
}

; Function parameters      #ClassName                       #ProcessName           #Target
#+f::RunOrRaiseRegularApps("CabinetWClass",                 "Explorer.EXE",        "explorer.exe")
#+w::RunOrRaiseRegularApps("Chrome_WidgetWin_1",            "chrome.exe",          "chrome.exe")
#+t::RunOrRaiseRegularApps("CASCADIA_HOSTING_WINDOW_CLASS", "WindowsTerminal.exe", "wt.exe")
#+Enter::Gosub, #+t

; Launch new apps
#f::Run, "explorer.exe"
#w::Run, "chrome.exe"
#t::Run, "wt.exe"
#Enter::Gosub, #t

; Vim-like mappings
#If, GetKeyState("LWin", "P")
    *h::Left
    *j::Down
    *k::Up
    *l::Right
#If

; Other mappings
#+q::WinClose, A
#+r::Reload
#+v::
    Clipboard = %Clipboard%
    Send, ^v
    Sleep, 50
Return