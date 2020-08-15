class Main extends hxd.App {
    var gamepadManager = new GamepadManager();
    var playerGamepadIDs: Array<Int> = [];
    var neutralControllerState = new ControllerState();

    static inline var numberOfPlayers = 1;

    var fixedTimestep = new FixedTimestep();
    var players: Array<Character> = [];
    var playerModels: Array<h3d.scene.Object> = [];
    var playerPositions: Array<InterpolatedPosition> = [];

    override function init() {
        var cache = new h3d.prim.ModelCache();

        for (i in 0...numberOfPlayers) {
            playerGamepadIDs.push(-1);
            players.push(new Character());
            playerPositions.push(new InterpolatedPosition());

            var foxModel = cache.loadModel(hxd.Res.fox);
            s3d.addChild(foxModel);
            playerModels.push(foxModel);
        }

        cache.dispose();

        s3d.camera.target.set(0.0, 0.0, 25.0);
        s3d.camera.pos.set(-200.0, 0.0, 50.0);
    }

    override function update(dt: Float) {
        // Do one step of game physics if possible.
        fixedTimestep.update(dt, physicsUpdate);

        // Update sprite visual positions.
        for (i in 0...numberOfPlayers) {
            playerPositions[i].interpolation = fixedTimestep.physicsFraction;
            playerModels[i].y = playerPositions[i].x;
            playerModels[i].z = playerPositions[i].y;
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

            playerPositions[i].x = player.x;
            playerPositions[i].y = player.y;
            if (player.justTurned) {
                playerModels[i].setDirection(new h3d.Vector(player.isFacingRight ? 1.0 : -1.0, 0.0, 0.0));
            }
        }
    }

    static function main() {
        hxd.Res.initEmbed();
        new Main();
    }
}
