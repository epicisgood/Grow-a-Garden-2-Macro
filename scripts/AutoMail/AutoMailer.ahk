#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn VarUnset, Off
; #NoTrayIcon
SetWorkingDir A_ScriptDir . "\..\..\"
KeyDelay := 40

Setkeydelay KeyDelay
GetRobloxClientPos()
pToken := Gdip_Startup()
bitmaps := Map()
bitmaps.CaseSense := 0
currentWalk := {pid:"", name:""} ; stores "pid" (script process ID) and "name" (pattern/movement name)
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"

WKey:="sc011" ; w
AKey:="sc01e" ; a
SKey:="sc01f" ; s
Dkey:="sc020" ; d


RotLeft := "vkBC" ; ,
RotRight := "vkBE" ; .
RotUp := "sc149" ; PgUp
RotDown := "sc151" ; PgDn
ZoomIn := "sc017" ; i
ZoomOut := "sc018" ; o
Ekey := "sc012" ; e
Rkey := "sc013" ; r
Lkey := "sc026" ; l
EscKey := "sc001" ; Esc
EnterKey := "sc01c" ; Enter
SpaceKey := "sc039" ; Space
SlashKey := "vk6F" ; /
SC_LShift:="sc02a" ; LShift

global settingsFile := A_WorkingDir . "\settings.ini"

#Include "%A_ScriptDir%"
#include ..\..\lib\

#Include FormData.ahk
#Include Gdip_All.ahk
#include Gdip_ImageSearch.ahk
#include json.ahk
#Include roblox.ahk
#Include ComVar.ahk
#Include Promise.ahk
#Include WebView2.ahk
#Include WebViewToo.ahk
#Include DiscordWebhook.ahk
#Include OCR.ahk
#Include ImagePut.ahk

#Include ..\images\
#include bitmaps.ahk



bitmaps["Jandel"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAUAAAAGCAYAAAAL+1RLAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABhSURBVBhXRcy7DYAgFEbhCzfEBCx8NLewMTqDve5Cx0iswRasRH4NaDzlVxzCW0oJWms4w6APvfdQSmEbbcNSCkQERIRjGRrmnMHMsIZxrnPDGGP9Sd/9GEKov31yuB68AWgCRIA+Z8DOAAAAAElFTkSuQmCC")
Click_Jandel(){
    Sleep(500)
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Jandel"] , &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY + 30
        MouseMove(x, y)
        Sleep(300)
        Click
    } else {
        Send("{" Ekey " down}")
        Sleep(1500)
        Send("{" Ekey " up}")
        Gdip_DisposeImage(pBMScreen)
        pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
        if (Gdip_ImageSearch(pBMScreen, bitmaps["Jandel"] , &OutputList, , , , , 25) = 1) {
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + windowX
            y := Cords[2] + windowY + 30
            MouseMove(x, y)
            Sleep(300)
            Click
        }
    }
    Gdip_DisposeImage(pBMScreen)
}



Type_Username(username){
    Sleep(500)
    Send "{Text}" Username ""
    Sleep(250)
    Send("{" EnterKey "}")
    Sleep(250)

    MouseGetPos(&x,&y)
    MouseMove(x,y + 80)
    Sleep(200)
    Click
    Sleep(750)
}

Select_Mail_item(imagebitmap, itemCount){    
    if itemCount >= 20 {
        LoopAmount := 20
        itemCount -= 20
    } else {
        LoopAmount := itemCount
        itemCount -= itemCount
    }


    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + windowHeight * 0.3 "|" windowWidth "|" windowHeight * 0.5)
    if (Gdip_ImageSearch(pBMScreen, imagebitmap , &OutputList, , , , , 50) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY + windowHeight * 0.3
        MouseMove(x, y)
        Sleep(300)
        loop LoopAmount {
            Click
            Sleep(50)
        }
    } else {
        ; Scoll down in a loop until we see the thing
        Gdip_DisposeImage(pBMScreen)

        loop {
            if (CheckDisconnnect() == 1) {
                return 
            }
            ; MsgBox("Scoll down")
            ScrollDown(0.7)
            Sleep(250)
            pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + windowHeight * 0.3 "|" windowWidth "|" windowHeight * 0.5)
            Sleep(250)
            if (Gdip_ImageSearch(pBMScreen, imagebitmap , &OutputList, , , , , 50) = 1) {
                Cords := StrSplit(OutputList, ",")
                x := Cords[1] + windowX
                y := Cords[2] + windowY + windowHeight * 0.3
                MouseMove(x, y)
                Sleep(300)
                loop LoopAmount {
                    Click
                    Sleep(20)
                }
                break
            }
            Gdip_DisposeImage(pBMScreen)
        }

    }
    Gdip_DisposeImage(pBMScreen)
    Sleep(250)

    return itemCount


}

bitmaps["SendButton"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAgAAAAECAYAAACzzX7wAAAAYElEQVR4ATyMMQ6AIBAEN/cnP+ZffAXPIHQYCkNnR2EorImg4oIJl51m57LigquNeZkrJgyUUb2X8hQ00pVAPfC7772Ulw8kHOGX4FVAW43m+kK+M+xmaRghjFkN4hnxAQAA///lkEavAAAABklEQVQDALjrQjlWWZfVAAAAAElFTkSuQmCC")
Click_Send_Mail(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + windowHeight * 0.5 "|" windowWidth "|" windowHeight * 0.5)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["SendButton"] , &OutputList, , , , , 50) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY + windowHeight * 0.5
        MouseMove(x, y)
        Sleep(300)
        Click
    }
    Gdip_DisposeImage(pBMScreen)

    PlayerStatus("Sent Mail ezz", "0x000000",,false,,true)
}


F1::{
    Start()

}


Start(*) {

    PlayerStatus("Starting Auto Mail GAG 2 Macro by epic", "0xFFFF00", , false, , false)
    ; OnError (e, mode) => (mode = "return") * (-1)
    Loop {
        MainLoop() 
    }
}
Mainloop() {
    ActivateRoblox()
    ResizeRoblox()
    Username := IniRead(settingsFile,'AutoMail',"username")
    totalItemCount := Integer(IniRead(settingsFile,'AutoMail',"itemcount"))
    scorchDir := A_WorkingDir . "\images\scorch.png"
    bitmaps["scorch"] := Gdip_BitmapFromBase64(ImagePutBase64(scorchDir, "png"))

    RedX_Shop_Button()
    Sleep(250)
    loop {
        CheckDisconnnect()
        Click_Jandel()
        Type_Username(Username)
        totalItemCount := Select_Mail_item(bitmaps['scorch'], totalItemCount)
        Click_Send_Mail()
        Sleep(8000)

        if totalItemCount == 0 {
            PlayerStatus("Finished Sending all mail!", "0x00ffff",,true,,true)
            MsgBox("Finished sending all items!!!")
            Send("{F3}")
        }
    }
}


F2::{
    PauseMacro()
}





setItem_Image(){
    ActivateRoblox()
    ResizeRoblox()

    if (MsgBox("Click OK, then take a picture of the seed you want to send.", "Auto Mail Program", 0x40001) = "Cancel")
        ExitApp

    A_Clipboard := ""

    Run("ms-screenclip:")

    if !ClipWait(10, 1) {
        MsgBox("Snipping timed out or was cancelled.", "Error", 0x10)
        return
    }

    Sleep(500)

    pToken := Gdip_Startup() 

    pBMScreen := Gdip_CreateBitmapFromClipboard()
    
    if (pBMScreen > 0) {
        if !DirExist(A_WorkingDir . "/images")
            DirCreate(A_WorkingDir . "/images")

        Gdip_SaveBitmapToFile(pBMScreen, A_WorkingDir . "/images/scorch.png")
        Gdip_DisposeImage(pBMScreen)
        MsgBox("Image saved successfully!", "Success", 0x40)
    } else {
        MsgBox("Failed to get image from clipboard. Make sure you took a snip.", "Error", 0x10)
    }

    Gdip_Shutdown(pToken)

    ActivateRoblox()
    relativeMouseMove(0.1, 0.1)
    Sleep(250)
    Send("{F3}")
}
























bitmaps["MailXbutton"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAYAAABWKLW/AAAAK0lEQVR4AWI6yMX5/zoQP+Lm+s/0598/hqdA/AaImXj+/2f4AWQ8//uXAQAAAP//Tq+ktQAAAAZJREFUAwCacRZZP4M0TgAAAABJRU5ErkJggg==")
RedX_Shop_Button(clickit := 1){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX + windowWidth * 0.6
    capY := windowY + windowHeight * 0.1
    capW := windowWidth * 0.2
    capH := windowHeight * 0.3
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["MailXbutton"], &OutputList, , , , , 25) = 1) {
        if (clickit == 1){
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + capX
            y := Cords[2] + capY
            MouseMove(x, y)
            Sleep(300)
            Click
        }
        return 1
    }
    Gdip_DisposeImage(pBMScreen)
    return 0
}






HyperSleep(ms) {
    static freq := (DllCall("QueryPerformanceFrequency", "Int64*", &f := 0), f)
    DllCall("QueryPerformanceCounter", "Int64*", &begin := 0)
    current := 0, finish := begin + ms * freq / 1000
    while (current < finish) {
        if ((finish - current) > 30000) {
            DllCall("Winmm.dll\timeBeginPeriod", "UInt", 1)
            DllCall("Sleep", "UInt", 1)
            DllCall("Winmm.dll\timeEndPeriod", "UInt", 1)
        }
        DllCall("QueryPerformanceCounter", "Int64*", &current)
    }
}

global settingsFile := 'settings.ini'


Walk_Studs(studs, MoveKey1, MoveKey2:=0) {
	currentWalkSpeed := Integer(IniRead(settingsFile,"Settings", "MoveSpeed", 16))
	sleepTime := (studs / currentWalkSpeed) * 1000
	Send "{" MoveKey1  " down}" (MoveKey2 ? "{" MoveKey2  " down}" : "")
	HyperSleep sleepTime
	Send "{" MoveKey1  " up}" (MoveKey2 ? "{" MoveKey2  " up}" : "")
}







CheckDisconnnect(){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos()
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) = 1 || GetRobloxHWND() == 0)  {
        PlayerStatus("Starting Grow A Garden 2", "0x00a838", ,false, ,false)    
        Gdip_DisposeImage(pBMScreen)
        CloseRoblox()
        PlaceID := 97598239454123

        linkCode := ""
        shareCode := ""
        VipLink := IniRead(settingsFile, "Settings", "VipLink","")

        if RegExMatch(VipLink, "privateServerLinkCode=(\d+)", &match)
            linkCode := match[1]
        else if RegExMatch(VipLink, "code=([a-f0-9]+)&type=Server", &match)
            shareCode := match[1]
        
        if linkCode {
        DeepLink := "roblox://placeID=" PlaceID "&linkCode=" linkCode
        } else if shareCode {
            DeepLink := "https://www.roblox.com/share?code=" shareCode "&type=Server"
        } else {
            DeepLink := "roblox://placeID=" PlaceID
        }
        try Run DeepLink

        loop 60 {
            if GetRobloxHWND() {
                Sleep(500)
                CloseBrowserTab()
                Sleep(500)
                ActivateRoblox()
                Sleep(500)
                ResizeRoblox()
                ActivateRoblox()
                GetRobloxClientPos(GetRobloxHWND())
                Sleep(25000) ; Game Loading Time here dynamiically would be perfect to check loading time.
                MouseMove windowX + windowWidth * 0.5, windowY + windowHeight * 0.5
                Sleep(500)
                Click
                Click
                PlayerStatus("Game Succesfully loaded", "0x00a838", ,false)
                Sleep(1000)
                CloseChat()
                Close_Leaderboard()
                Sleep(1500)
                Walk_Studs(17, Dkey)
                Sleep(1000)
                return 1
            }
            Sleep(1000)
        }
        if (A_Index == 60){
            Sleep(500)
            CloseBrowserTab()
            Sleep(500)
        }
        Gdip_DisposeImage(pBMScreen)
        return 0

    } else {
        Gdip_DisposeImage(pBMScreen)
        return 0
    }
}



CloseChat(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth * 0.25 "|" windowHeight * 0.125)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["ChatOpen"] , &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY
        MouseMove(x, y)
        Sleep(300)
        Click
    }
    Gdip_DisposeImage(pBMScreen)
}

CloseBrowserTab(){
    for hwnd in WinGetList(,, "Program Manager")
    {
        p := WinGetProcessName("ahk_id " hwnd)
        if (InStr(p, "Roblox") || InStr(p, "AutoHotkey"))
            continue ; skip roblox and AHK windows
        title := WinGetTitle("ahk_id " hwnd)
        if (title = "")
            continue ; skip empty title windows
        s := WinGetStyle("ahk_id " hwnd)
        if ((s & 0x8000000) || !(s & 0x10000000))
            continue ; skip NoActivate and invisible windows
        s := WinGetExStyle("ahk_id " hwnd)
        if ((s & 0x80) || (s & 0x40000) || (s & 0x8))
            continue ; skip ToolWindow and AlwaysOnTop windows
        try
        {
            WinActivate "ahk_id " hwnd
            WinMaximize("ahk_id " hwnd)
            Sleep 500
            Send "^{w}"
        }
        break
    }
}

Close_Leaderboard(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX + windowWidth - 300  
    capY := windowY                      
    capW := 300                          
    capH := 200                          
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Leaderboard"], , , , , , 25) = 1) {
        Send("{Tab}")
        Sleep(100)
        Gdip_DisposeImage(pBMScreen)
        return true
    }
    Gdip_DisposeImage(pBMScreen)
    return false 
}





ScrollDown(amount := 1) {
    BaseHeight := 1080

    ; Scale factor (based mostly on height, since scroll is vertical)
    Scale := WindowHeight / BaseHeight

    AdjustedAmount := Round(-amount * 120 * Scale)

    DllCall("user32.dll\mouse_event"
        , "UInt", 0x0800   ; MOUSEEVENTF_WHEEL
        , "UInt", 0
        , "UInt", 0
        , "UInt", AdjustedAmount
        , "UPtr", 0)
}

relativeMouseMove(relx, rely) {
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    moveX := windowX + Round(relx * windowWidth)
    moveY := windowY + Round(rely * windowHeight)
    MouseMove(moveX,moveY)
}






; SHITTY UI USED FOR THIS FUCKING PROGRAM



settingsFile := "settings.ini"


if (A_IsCompiled) {
	WebViewCtrl.CreateFileFromResource((A_PtrSize * 8) "bit\WebView2Loader.dll", WebViewCtrl.TempDir)
    WebViewSettings := {DllPath: WebViewCtrl.TempDir "\" (A_PtrSize * 8) "bit\WebView2Loader.dll"}
    guipath := A_WorkingDir
} else {
    WebViewSettings := {}
    TraySetIcon("images\\GameIcon.ico")
    guipath := ''
}

MyWindow := WebViewGui("-Resize -Caption ",,,WebViewSettings) ; ignore error it somehow works with it.....
MyWindow.Navigate(guipath "\scripts\AutoMail\Gui\index.html")
MyWindow.OnEvent("Close", (*) => StopMacro())
; MyWindow.Navigate("scripts/Gui/index.html")
MyWindow.AddHostObjectToScript("ButtonClick", { func: WebButtonClickEvent })
MyWindow.AddHostObjectToScript("Save", { func: SaveSettings })
MyWindow.AddHostObjectToScript("ReadSettings", { func: SendSettings })

MyWindow.Show("w600 h400")




F3::{
    ResetMacro
}

Alt & S:: {
    ResetMacro
}


ResetMacro(*) { 
    ; PlayerStatus("Stopped Grow A Garden 2 Macro", "0xff8800", , false, , false)
    Send "{" Dkey " up}{" Wkey " up}{" Akey " up}{" Skey " up}{F14 up}"
    Try Gdip_Shutdown(pToken)
    Reload 
}
StopMacro(*) {
    PlayerStatus("Closed Auto Mail GAG 2 Macro", "0xff5e00", , false, , false)
    Send "{" Dkey " up}{" Wkey " up}{" Akey " up}{" Skey " up}{F14 up}"
    Try Gdip_Shutdown(pToken)
    exe_path32 := A_AhkPath
    scriptPath := A_WorkingDir . "\scripts\Epic's_GAG2_macro.ahk"
    run '"' exe_path32 '" /script "' scriptPath '"'
    ExitApp()
}

PauseToggle := true
PauseMacro(*){
    global PauseToggle
    PauseToggle := !PauseToggle
    if PauseToggle {
        Pause(false) ; Unpause
        ToolTip "Macro Unpaused"
        PlayerStatus("Unpaused Auto Mail GAG 2 Macro", "0x91ff00", , false, , false)
    } else {
        Pause(true)  ; Pause
        ToolTip "Macro Paused"
        PlayerStatus("Paused Auto Mail GAG 2 Macro", "0x003cff", , false, , false)
    }
    SetTimer () => ToolTip(), -1000
}




ScreenResolution() {
    if (A_ScreenDPI != 96) {
        MsgBox "
        (
        Your Display Scale seems to be ≠100%. The macro will NOT work correctly!
        Set Scale to 100% in Display Settings, then restart Roblox & this macro.
        Windows key > change the resolution of display > Scale > 100%
        )", "WARNING!!", 0x1030 " T60"
    }
}
ScreenResolution()

if (WinExist("Roblox ahk_exe ApplicationFrameHost.exe")){
        MsgBox "
        (
        Please change your roblox to website version, Your corrently are using microsoft version.
        Download roblox from the official website https://www.roblox.com/download
        )", "WARNING!!", 0x1030 " T60"
}




WebButtonClickEvent(button) {
    switch button {
        case "Start":
            Send("{F1}")
        case "Pause":
			Send("{F2}")
        case "Stop":
			Send("{F3}")
        case "InitImage":
            setItem_Image() 
	}
}



global CORE_SETTINGS := ["username", "itemcount"]

SaveSettings(settingsJson) {
    settings := JSON.Parse(settingsJson)
    IniFile := A_WorkingDir . "\settings.ini"

    for key, val in settings {
        for coreKey in CORE_SETTINGS {
            if (key == coreKey) {
                IniWrite(val, IniFile, "AutoMail", key)
                break
            }
        }
    }
    ; MsgBox("Saved settings.",, "T0.5")
}

SendSettings() {
    settingsFile := A_WorkingDir . "\settings.ini"
    
    if (!FileExist(settingsFile)) {
        IniWrite("epicboy8486",  settingsFile, "AutoMail", "username")
        IniWrite("0", settingsFile, "AutoMail", "itemcount")
        Sleep(200)
    }

    SettingsJson := {}
    for key in CORE_SETTINGS {

        if key == "username" {
            SettingsJson.%key% := IniRead(settingsFile, "AutoMail", key, "epicboy8486")
        } else if key == "itemcount" {
            SettingsJson.%key% := IniRead(settingsFile, "AutoMail", key, "35")
        }
        ; SettingsJson.%key% := IniRead(settingsFile, "AutoMail", key, "")
        
    }
    MyWindow.PostWebMessageAsJson(JSON.stringify(SettingsJson))
}





PlayerStatus("Connected to discord!", "0x34495E", , false, , false)


