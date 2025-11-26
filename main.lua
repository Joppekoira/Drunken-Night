-- Asetetaan näytön asetukset, kuten piilotetaan statusbar ja
-- määritetään tekstuurifiltterit pikseligrafiikalle sopiviksi.
display.setStatusBar( display.HiddenStatusBar )
display.setDefault("magTextureFilter", "nearest")
display.setDefault("minTextureFilter", "nearest")




local loadsave = require("scripts.loadsave")
local userdata = loadsave.load("userdata.json")

if not userdata then
    userdata = require("data.defaultSettings")
    loadsave.save("userdata.json")
end
-- Siirrytään heti pelin menu näkymään.
local composer = require( "composer" )
-- Käytetään automaattista muistinhallintaa scenejen välillä.
composer.recycleOnSceneChange = true
composer.gotoScene( "scenes.menu", { effect = "fade", time = 500 } )