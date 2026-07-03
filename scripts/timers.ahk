nowUnix() {
    return DateDiff(A_NowUTC, "19700101000000", "Seconds")
}

If_Minute(minuteinput){
    if (Mod(A_Min, 10) = minuteinput){
        return true
    }
    return false
}


ConvertSeconds(hours,minutes,seconds){
    return (hours * 3600) + (minutes * 60) + seconds
}


LastShopTime := nowUnix()


; The highest object will be the last item in loop.
global Shops := {
    Crates: {
        name: "Crates",
        lastTime: LastShopTime,
        duration: ConvertSeconds(0, 5, 0),
        buy: (self) => BuyCrates()
    },
    Gears: {
        name: "Gears",
        lastTime: LastShopTime,
        duration: ConvertSeconds(0, 5, 0),
        buy: (self) => BuyGears()
    },
    Seeds: {
        name: "Seeds",
        lastTime: LastShopTime,
        duration: ConvertSeconds(0, 5, 0),
        buy: (self) => BuySeeds()
    }

}




RewardInterupt() {
    global Shops

    currentTime := nowUnix()

    ShopBought := 0

    for _, shop in Shops.OwnProps() {
        ; MsgBox(_)
        if (currentTime - shop.lastTime >= shop.duration - 10) {
            if (ShopBought == 0){
                CameraCorrection()
            }
            shop.lastTime := currentTime
            shop.buy()
            ShopBought++
        }
    }

    if (ShopBought > 0) {
        Sleep(200)
        Clickbutton_Tabs("Garden")
        Sleep(1000)
        Walk_Studs(15, WKey, Dkey)
        return 1
    }

    return 0
    
}


