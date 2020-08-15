class Main extends hxd.App {
    var gamepadManager = new GamepadManager();
    var playerGamepadIDs: Array<Int> = [];
    var neutralControllerState = new ControllerState();

    static inline var numberOfPlayers = 1;
    var cameraZoom = 6.0;
    var cameraX = 0;
    var cameraY = 500;

    var fixedTimestep = new FixedTimestep();
    var players: Array<Character> = [];
    var playerSprites: Array<h2d.Bitmap> = [];
    var playerSpritePositions: Array<InterpolatedPosition> = [];

    override function init() {
        hxd.Res.initEmbed();

        var tile = hxd.Res.ppL.toTile().center();
        for (i in 0...numberOfPlayers) {
            playerGamepadIDs.push(-1);
            players.push(new Character());
            var bitmap = new h2d.Bitmap(tile, s2d);
            bitmap.setScale(4.0);
            playerSprites.push(bitmap);
            playerSpritePositions.push(new InterpolatedPosition());
        }
    }

    override function update(dt: Float) {
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
        gamepadManager.update();
        for (gamepadID => gamepad in gamepadManager.gamepads) {
            if (gamepad.startButton.justPressed) {
                var isVJoy = StringTools.contains(gamepad.heapsPad.name.toLowerCase(), "vjoy");
                if (!isVJoy) {
                    playerGamepadIDs[0] = gamepadID;
                }
            }
        }

        for (i in 0...numberOfPlayers) {
            var player = players[i];
            var playerControllerState: ControllerState;
            var playerGamepadID = playerGamepadIDs[i];

            if (playerGamepadID != -1) {
                playerControllerState = gamepadManager.gamepads[playerGamepadID];
            }
            else {
                playerControllerState = neutralControllerState;
            }

            player.update(playerControllerState);

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
