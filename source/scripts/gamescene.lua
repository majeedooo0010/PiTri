local gfx  <const> = playdate.graphics
local ldtk <const> = LDtk

ldtk.load("levels/world.ldtk", false)

TAGS     ={
           Player=1
           }
Z_INDEXES={
           Player=100
           }

class('GameScene').extends()

function GameScene:init()
    self:gotolevel("Level_0")
    self.spawnx=12*16
    self.spawny=5*16

    self.player = Player(self.spawnx,self.spawny)
end

function GameScene:gotolevel(level_name)
    gfx.sprite.removeAll()

    for layer_name, layer in pairs(ldtk.get_layers(level_name)) do
        if layer.tiles then
            local TileMap = ldtk.create_tilemap(level_name, layer_name)

            local LayerSprite = gfx.sprite.new()
            LayerSprite:setTilemap(TileMap)
            LayerSprite:setCenter(0,0)
            LayerSprite:moveTo(0,0)
            LayerSprite:setZIndex(layer.zIndex)
            LayerSprite:add()

            local EmptyTiles = ldtk.get_empty_tileIDs(level_name, "Solid", layer_name)
            if EmptyTiles then
                gfx.sprite.addWallSprites(TileMap,EmptyTiles)
            end
        end
    end
end