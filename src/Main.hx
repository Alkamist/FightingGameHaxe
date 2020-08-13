class Main extends hxd.App {
    var controllers : Array<ControllerReader> = [];

    static inline var numberOfPlayers : Int = 1;
    var cameraZoom : Float = 6.0;
    var cameraX : Int = 0;
    var cameraY : Int = 0;

    var fixedTimestep : FixedTimestep = new FixedTimestep();
    var players : Array<Character> = [];
    var playerSprites : Array<h2d.Bitmap> = [];
    var playerSpritePositions : Array<InterpolatedPosition> = [];

    override function init() {
        hxd.Res.initEmbed();

        cameraY = 500;

        for (i in 0...numberOfPlayers) {
            controllers.push(new ControllerReader());
        }

        var tile = hxd.Res.ppL.toTile().center();

        for (i in 0...numberOfPlayers) {
            players.push(new Character());
            var bitmap = new h2d.Bitmap(tile, s2d);
            bitmap.setScale(4.0);
            playerSprites.push(bitmap);
            playerSpritePositions.push(new InterpolatedPosition());
        }
    }

    override function update(dt : Float) {
        // Do one step of game physics if possible.
        fixedTimestep.update(dt, physicsUpdate);

        // Update sprite visual positions.
        for (i in 0...numberOfPlayers) {
            playerSpritePositions[i].interpolation = fixedTimestep.physicsFraction;
            playerSprites[i].x = playerSpritePositions[i].x;
            playerSprites[i].y = playerSpritePositions[i].y;
        }
    }

    function physicsUpdate() {
        for (i in 0...numberOfPlayers) {
            controllers[i].update();

            var player = players[i];
            player.update(controllers[i]);

            if (player.y < 0.0) {
                player.y = 0.0;
                player.land();
            }

            playerSpritePositions[i].x = player.x * cameraZoom + cameraX;
            playerSpritePositions[i].y = -player.y * cameraZoom - 24 + cameraY;
            if (player.justTurned) {
                playerSprites[i].tile.flipX();
            }
        }
    }

    static function main() {
        new Main();
    }
}
