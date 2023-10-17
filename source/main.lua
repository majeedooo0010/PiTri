--CoreLibs
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/timer"
local pd  <const> = playdate
local gfx <const> = playdate.graphics

--Libraries
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/LDtk"

--Game
import "scripts/gamescene"
import "scripts/player"


GameScene()
pd.display.setRefreshRate(50)


function playdate.update()
	gfx.sprite.update()
	pd.timer.updateTimers()

	pd.drawFPS(0,0)
end