#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn VarUnset, Off
SetWorkingDir A_ScriptDir . "\.."
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

#Include "%A_ScriptDir%"
#include ..\lib\

#Include ComVar.ahk
#Include DiscordWebhook.ahk
#Include FormData.ahk
#Include Gdip_All.ahk
#include Gdip_ImageSearch.ahk
#include json.ahk
#Include OCR.ahk
#Include Promise.ahk
#Include roblox.ahk
#Include WebView2.ahk
#Include WebViewToo.ahk

#Include ..\images\
#include bitmaps.ahk
#include ..\scripts\

#Include gui.ahk
#Include timers.ahk


;@Ahk2Exe-AddResource Gui\index.html, Gui\index.html
;@Ahk2Exe-AddResource Gui\script.js, Gui\script.js
;@Ahk2Exe-AddResource Gui\style.css, Gui\style.css
;@Ahk2Exe-AddResource ..\Lib\32bit\WebView2Loader.dll, 32bit\WebView2Loader.dll
;@Ahk2Exe-AddResource ..\Lib\64bit\WebView2Loader.dll, 64bit\WebView2Loader.dll



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

ScrollUp(amount := 1) {
    BaseHeight := 1080

    ; Scale factor (based mostly on height, since scroll is vertical)
    Scale := WindowHeight / BaseHeight

    ; Positive amount scrolls UP
    AdjustedAmount := Round(amount * 120 * Scale)

    DllCall("user32.dll\mouse_event"
        , "UInt", 0x0800   ; MOUSEEVENTF_WHEEL
        , "UInt", 0
        , "UInt", 0
        , "UInt", AdjustedAmount
        , "UPtr", 0)
}


CheckSetting(section,key){
    if (IniRead(settingsFile, section, key) == 1){
        return true
    }
    return false
}


relativeMouseMove(relx, rely) {
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    moveX := windowX + Round(relx * windowWidth)
    moveY := windowY + Round(rely * windowHeight)
    MouseMove(moveX,moveY)
}




; Walk(studs, MoveKey1, MoveKey2:=0) {
; 	Send "{" MoveKey1  " down}" (MoveKey2 ? "{" MoveKey2  " down}" : "")
; 	Sleep studs
; 	Send "{" MoveKey1  " up}" (MoveKey2 ? "{" MoveKey2  " up}" : "")
; }

Walk_Studs(studs, MoveKey1, MoveKey2:=0) {
    if IniRead(settingsFile, "Settings", "MoveSpeed", 16) == "" {
        IniWrite("16", settingsFile, "Settings", "MoveSpeed")
    }
	currentWalkSpeed := Integer(IniRead(settingsFile, "Settings", "MoveSpeed", 16))
	sleepTime := (studs / currentWalkSpeed) * 1000
	Send "{" MoveKey1  " down}" (MoveKey2 ? "{" MoveKey2  " down}" : "")
	HyperSleep sleepTime
	Send "{" MoveKey1  " up}" (MoveKey2 ? "{" MoveKey2  " up}" : "")
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



CheckDisconnnect(){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos()
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) = 1 || GetRobloxHWND() == 0)  {
        PlayerStatus("Starting Grow A Garden 2", "0x00a838", ,false, ,false)    
        Gdip_DisposeImage(pBMScreen)
        CloseRoblox()

        if (CheckSetting("FallSeeds", "FallSeeds")) {
            PlaceID := 126987765280963 ; Fall Server
        } else {
            PlaceID := 97598239454123 ; Normal Game
        }

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
                ; Sleep(25000) ; Game Loading Time here dynamiically would be perfect to check loading time.
                DetectLoadingScreen()
                DetectGameLoaded()
                MouseMove windowX + windowWidth * 0.5, windowY + windowHeight * 0.5
                Sleep(500)
                Click
                Click
                Sleep(2750)
                PlayerStatus("Game Succesfully loaded", "0x00a838", ,false)
                Click("Down")
                Sleep(1000)
                Click("Down")
                ; Sleep(1000)
                CloseChat()
                Close_Leaderboard()
                Sleep(1500)
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

DetectLoadingScreen(){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    bitmaps["LoadingScreen"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAYAAADgzO9IAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAChSURBVBhXAZYAaf8A4+fn/+fp6v/j5eb/6uzs/9TV1f9TVFT/AMHDxv+mqq//xsnN/8LCw/9ZWlr/Dw8P/wB+hYz/kpac/7a4uv9XWFj/FRgV/w4cD/8Aen+H/5GUmf9dX1//FhgW/woVCv8nVij/AHV6gf9PUFL/FBQU/wwXDf8lUib/QpJD/wBKTVD/GBsa/wsUC/8kUCX/PotA/06uUP92wlGMoIR+ygAAAABJRU5ErkJggg==")
    loop 30 {
        pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
        if (Gdip_ImageSearch(pBMScreen, bitmaps["LoadingScreen"], , , , , , 25) = 1) {
            Gdip_DisposeImage(pBMScreen)
            return true
        } 
        Gdip_DisposeImage(pBMScreen)
        Sleep(1000)
    }
    Gdip_DisposeImage(pBMScreen)
    return false
    

}


DetectGameLoaded(){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    bitmaps["GameLoaded"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAFCAYAAABirU3bAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABTSURBVBhXJcixEYAgDAXQ3AWogKOG0NI5AhOxgZ2xsoEJnPV7avGaR2oMlPlzMIPeOL3HJYLVGkitxZ4S5rbh7v2PEQI0Z0wRkDqHESO0FKxa8QBauCEX8vIlqQAAAABJRU5ErkJggg==")

    loop 30 {
        pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
        if !(Gdip_ImageSearch(pBMScreen, bitmaps["GameLoaded"], , , , , , 25) = 1) {
            Gdip_DisposeImage(pBMScreen)
            return true
        } 
        Gdip_DisposeImage(pBMScreen)
        Sleep(500)
    }

    Gdip_DisposeImage(pBMScreen)
    return false
    
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



ChangeCamera(type){
    Send("{" EscKey "}")
    HyperSleep(1000)
    Open_Setting_Menu()
    HyperSleep(500)
    loop 10 {
        Send("{Up}")
        Sleep(50)
    }
    Sleep(150)
    
    Scroll_Until_CameraMode()

    HyperSleep(333)
    Send("{Right}")
    HyperSleep(333)
    Send("{Right}")
    HyperSleep(333)
    checkCamera(type)
    Send("{" EscKey "}")
    HyperSleep(1000)
}

Open_Setting_Menu(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["SettingIcon"] , &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY + 30
        MouseMove(x, y)
        Sleep(300)
        Click
    }
    Gdip_DisposeImage(pBMScreen)
}



Scroll_Until_CameraMode(){
    
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    loop {
        pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)
        if (Gdip_ImageSearch(pBMScreen, bitmaps["Camera Mode"] , , , , , , 25) = 1) {
            Gdip_DisposeImage(pBMScreen)
            return 1
        } else {
            Send("{Down}")
            Sleep(50)
            Gdip_DisposeImage(pBMScreen)
        }

        if A_Index == 25 {
            PlayerStatus("CRITICAL ERROR!!! Please dm me this error!", "0xffe100",,true,,true)
        }
    }
    
}



checkCamera(Camera_mode){  
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    loop 8 {
        pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)
        if (Gdip_ImageSearch(pBMScreen, bitmaps[Camera_mode] , , , , , , 25) = 1) {
            Gdip_DisposeImage(pBMScreen)
            return 1
        } else {
            Send("{Right}")
            Sleep(1000)
            Gdip_DisposeImage(pBMScreen)
        }
    }

}




ZoomAlign(){
    relativeMouseMove(0.5,0.5)
    Sleep(200)
    Click
    Loop 40 {
        Send("{WheelUp}")
        Sleep 20
    }

    Sleep(500)
    Loop 6 {
        Send("{WheelDown}")
        Sleep 50
    }
    Sleep(100)
    Click
    Sleep(250)
}

CameraCorrection(){
    Send("{o down}")
    Sleep(500)
    Send("{o up}")
    Disconnect()
    CloseClutter()
    Clickbutton_Tabs("Garden")
    Sleep(125)
    Click 5
    Sleep(125)
    Clickbutton_Tabs("Seeds")
    Sleep(125)
    Click 5
    Sleep(125)
    Clickbutton_Tabs("Garden")
    Sleep(1000)
    Walk_Studs(12, AKey, SKey)
    ZoomAlign()
    Sleep(250)
    PlayerStatus("Finished Aligning!","0x2260e6",,false,,false)
}

SpamClick(amount){
    loop amount {
        Click
        Sleep 20
    }
}

Close_Robux_Button(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX + windowWidth * 0.25
    capY := windowY 
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" windowWidth * 0.5 "|" windowHeight)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Robux"], &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + capX
        y := Cords[2] + capY 
        MouseMove(x, y)
        Sleep(300)
        Click
        Gdip_DisposeImage(pBMScreen)
        return 1
    }
    Gdip_DisposeImage(pBMScreen)
    return 0
}


RedX_Shop_Button(clickit := 1){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX + windowWidth * 0.6
    capY := windowY + windowHeight * 0.1
    capW := windowWidth * 0.2
    capH := windowHeight * 0.3
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    ; Gdip_SaveBitmapToFile(pBMScreen, "ss.png")
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Xbutton"], &OutputList, , , , , 25) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["Xbutton2"], &OutputList, , , , , 25) = 1) {
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



Clickbutton_Tabs(button, clickit := 1){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)    
    
    capX := windowX + (windowWidth * 0.25)
    capY := windowY + 30
    capW := windowWidth * 0.5
    capH := 100
    varation := 20
    
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    ; Gdip_SaveBitmapToFile(pBMScreen, "ss.png")
    if (Gdip_ImageSearch(pBMScreen, bitmaps[button], &OutputList, , , , , varation) = 1) {
        if (clickit == 1){
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + windowX + (windowWidth * 0.25)
            y := Cords[2] + windowY + 30
            MouseMove(x, y)
            Sleep(300)
            Click
        }
        Gdip_DisposeImage(pBMScreen)
        return 1
    }
    Gdip_DisposeImage(pBMScreen)
    return 0
}





CheckStock(index, list){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    captureWidth := 150
    captureHeight := Integer(windowHeight * 0.5) + 100

    captureX := Integer(windowX + (windowWidth * 0.4))
    captureY := Integer(windowY + (windowHeight * 0.25))

    pBMScreen := Gdip_BitmapFromScreen(captureX "|" captureY "|" captureWidth "|" captureHeight)
    ; Gdip_SaveBitmapToFile(pBMScreen,"ss.png")
    If !(Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock"], &OutputList, , , , , 3,,3) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock2"], &OutputList , , , , , 3,,3) = 1) {
        Gdip_DisposeImage(pBMScreen)
        return 0
    }

    loop {
        pBMScreen := Gdip_BitmapFromScreen(captureX "|" captureY "|" captureWidth "|" captureHeight)
        If (Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock"], &OutputList, , , , , 3,,3) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock2"], &OutputList , , , , , 3,,3) = 1) {
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + captureX - 5
            y := Cords[2] + captureY 
            MouseMove(x, y)
            SpamClick(15)
            Gdip_DisposeImage(pBMScreen)
            ; Sleep(150)
        } else {
            Gdip_DisposeImage(pBMScreen)
            PlayerStatus("Bought " list[index] "s!", "0x22e6a8",,false)
            return 1
        }

        if (A_index == 50) {
            Gdip_DisposeImage(pBMScreen)
            return 0
        }
    }

}






buyShop(itemList, itemType){
    ; It makes sure shop is ready to be looped through.
    pos := 0.85
    relativeMouseMove(0.4,pos)
    Loop itemList.length * 3 {
        Send("{WheelUp}")
        Sleep 20
    }
    Sleep(250)
    Click
    Sleep(250)
    Loop 12 {
        Send("{WheelUp}")
        Sleep 20
    }
    relativeMouseMove(0.5,0.4)
    Sleep(250)

    ; Ready for buying loop!

    for (item in itemlist){
        if A_Index == 1 {
            pos := 0.4
        } else {
            pos := 0.7
        }

        relativeMouseMove(0.4,pos)
        Click
        Sleep(250)
        if (CheckSetting(itemType, StrReplace(item, " ", ""))){
            CheckStock(A_Index, itemlist)
        } else {
            Sleep(100)
        }


    }
    CloseShop()
}





DetectShop(shop){
    loop 15 {
        Sleep(500)
        if (RedX_Shop_Button(0) == 1){
            Sleep(2500)
            PlayerStatus("Detected " shop " shop opened", "0x22e6a8",,false,,false)
            return 1
        }
    }
    PlayerStatus("Failed to open " shop " shop", "0x22e6a8",,false,,true)
    return 0
}


CloseShop(){
    loop 15 {
        Sleep(500)
        if (RedX_Shop_Button() == 1){
            Sleep(1000)
            PlayerStatus("Closed shop!", "0x22e6a8",,false,,false)
            return 1
        }
    }
    PlayerStatus("Failed to close shop.", "0xFF0000",,false,,true)
    return 0

}


CloseClutter(){
    RedX_Shop_Button()
    Sleep(200)
    Close_Robux_Button()
    Sleep(100)
}

getItems(item){
    global remoteObject


    static fileContent := ""
    if !fileContent {
        try {
            request := ComObject("WinHttp.WinHttpRequest.5.1")
            request.Open("GET", "https://raw.githubusercontent.com/epicisgood/GAG-2-Updater/refs/heads/main/items.json", false)
            request.Send()
            request.WaitForResponse()

            if (request.Status != 200 || request.ResponseText = "") {
                PlayerStatus("Failed to fetch items (status " request.Status ")", "0xFF0000",,true,,false)
                return []
            }

            fileContent := JSON.parse(request.ResponseText)
            if !IsObject(fileContent) {
                PlayerStatus("Unable to parse JSON.", "0xFF0000",,true,,false)
                PlayerStatus(JSON.stringify(fileContent), "0xFF0000",,true,,false)
                fileContent := ""
                return []
            }

            global MyWindow
            global remoteObject
            MyWindow.ExecuteScriptAsync("document.querySelector('#random-message').textContent = '" fileContent["message"] "'")
            remoteObject := JSON.stringify(fileContent)
        } catch as e {
            PlayerStatus("This is a very rare error! " e.Message, "0xFF0000",,true,,false)
        }
    }

    if Type(fileContent) != "Map" {
        PlayerStatus("Type: " Type(fileContent), "0xFF0000",,,,false)
        PlayerStatus("Please contact _epic. for this error. " fileContent, "0xFF0000",,true,,false)
        fileContent := ""
        return []
    }
    
    ; Error: This value of type "String" has no property named "__Item". Bug should be fixed hopefully....
    names := []
    for itemObj in fileContent[item] {
        names.Push(itemObj["name"])
    }
    return names
    ; jsonData := fileContent
    ; return jsonData[item]
}

initShops(){
    static Shopinit := true
    static crateinit := true
    if (Shopinit == true){
        if (If_Minute(0) || If_Minute(5)) {
            global LastShopTime := nowUnix()
            BuySeeds()
            BuyGears()
            BuyCrates()
            Shopinit := false
        }
    } 


}

BuySeeds(){
    if CheckSetting("FallSeeds", "FallSeeds") {
        ItemType := "FallSeeds"
    } else {
        ItemType := "Seeds"
    }
    
    seedItems := getItems(ItemType)
    if !(CheckSetting(ItemType, ItemType)){
        return
    }
    loop 3 {
        if (Disconnect()){
            Sleep(1500)
            CameraCorrection()
        }
        PlayerStatus("Going to buy " ItemType "!", "0x22e6a8",,false,,false)
        relativeMouseMove(0.5, 0.5)
        Sleep(500)
        Clickbutton_Tabs("Seeds")
        Sleep(1000)
        Send("{" Ekey "}")
        if !DetectShop("seed"){
            CameraCorrection()
            continue
        }
        buyShop(seedItems, ItemType)
        CloseClutter()
        return 1
    }
    PlayerStatus("Failed to buy seeds 3 times, CLOSING ROBLOX!", "0x001a12")
    CloseRoblox()
    Sleep(1000)
    Disconnect()
    CameraCorrection()
}

F4::{
    BuyCrates()
}

BuyGears(){
    if CheckSetting("FallGears", "FallGears") {
        ItemType := "FallGears"
    } else {
        ItemType := "Gears"
    }

    gearItems := getItems(ItemType)
    if !(CheckSetting(ItemType, ItemType)){
        return
    }
    loop 3 {
        PlayerStatus("Going to buy " ItemType "!", "0x22e6a8",,false,,false)
        if (Disconnect()){
            Sleep(1500)
            CameraCorrection()
        }
        ActivateRoblox()
        Clickbutton_Tabs("Seeds")
        ; Sleep(500)
        ; CheckWearWolf()
        ; Sleep(500)
        Sleep(1000)
        Walk_Studs(15, Dkey)
        Walk_Studs(55, Skey)
        Sleep(1000)
        Send("{" Ekey "}")
        if !DetectShop("gear"){
            CameraCorrection()
            continue
        }
        buyShop(gearItems, ItemType)
        CloseClutter()
        return 1
    }
    
    CloseClutter()
    Sleep(1500)
    PlayerStatus("Failed to open gear shop 3 times.", "0x001a12")
    CloseRoblox()
    Sleep(1000)
    Disconnect()
    CameraCorrection()
}


BuyCrates(){
    if CheckSetting("FallCrates", "FallCrates") {
        ItemType := "FallCrates"
    } else {
        ItemType := "Crates"
    }

    if !(CheckSetting(ItemType, ItemType)){
        return
    }
    crateitems := getItems(ItemType)
    loop 3 {
        if (Disconnect()){
            Sleep(1500)
            CameraCorrection()
        }
        PlayerStatus("Going to buy " ItemType "!", "0x22e6a8",,false,,false)
        ActivateRoblox()
        Clickbutton_Tabs("Seeds")
        Sleep(1000)
        Walk_Studs(15, Dkey)
        Walk_Studs(55, Skey)
        Sleep(1000)
        ; Sleep(500)
        ; CheckWearWolf()
        ; Sleep(500)
        Send("{" Ekey "}")
        if !DetectShop("crate"){
            CameraCorrection()
            continue
        }
        buyShop(crateitems, ItemType)
        CloseClutter()
        return 1
    }
}





Disconnect(){
    loop 3 {
        if (CheckDisconnnect()){
            return 1
        }
    }
}

MainLoop() {
    if (GetRobloxHWND()){
        ResizeRoblox()
    }
    
    if (Disconnect()){
        Sleep(1500)
        return
    }
    try {
        global MyWindow
        MyWindow.Destroy()
    } catch {
        Sleep(10)
    }
    CloseChat()
    Close_Leaderboard()
    CameraCorrection()
    BuySeeds()
    BuyGears()
    BuyCrates()
    loop {
        initShops()
        if (Disconnect()){
            Sleep(1500)
            CameraCorrection()
        }
        
        if ((If_Minute(0) || If_Minute(5)) && A_Sec > 10) {
            RewardInterupt()
        }

        ShowToolTip()
        Sleep(1000)
    }
    
    
    
}


ShowToolTip(){
    global Shops
    if !IsSet(Shops) || !IsObject(Shops) {
        PlayerStatus("Ping _epic. with error. Type: " Type(Shops) ", IsSet: "  IsSet(shop), "0xFF0000",,true,,false)
        PlayerStatus(JSON.stringify(Shops),"0xFF0000",,true,,false)
        return 
    }

    currentTime := nowUnix()
    tooltipText := ""

    ; Error: This Value of type "String" has no property named "__Item".
    for _, shop in Shops.OwnProps() {
        enabled := IniRead(settingsFile, shop.name, shop.name) + 0
        if (!enabled)
            continue

        remaining := Max(0, shop.duration - (currentTime - shop.lastTime))
        tooltipText .= shop.name ": " (remaining // 60) ":" Format("{:02}", Mod(remaining, 60)) "`n"
    }

    ToolTip(tooltipText, 100, 100)
}



F2::
{
    ; ActivateRoblox()
    ; ResizeRoblox()
    ; hwnd := GetRobloxHWND()
    ; GetRobloxClientPos(hwnd)
    ; pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    ; Gdip_SaveBitmapToFile(pBMScreen,"ss.png")
    ; Gdip_DisposeImage(pBMScreen)
    PauseMacro()
}






SetTimer SetMacroReady, -500