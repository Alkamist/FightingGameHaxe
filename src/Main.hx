import hxd.res.Font;
import h3d.Vector;
import h3d.scene.Object;
import h3d.prim.ModelCache;

import h2d.Font;
import h2d.Text;

import hxd.Res;

class Main extends hxd.App {
    var gamepadManager = new GamepadManager();
    var playerGamepadIDs: Array<Int> = [];
    var neutralControllerState = new ControllerState();

    static inline var numberOfPlayers = 1;

    var fixedTimestep = new FixedTimestep();
    var players: Array<Character> = [];
    var playerModels: Array<Object> = [];
    var playerPositions: Array<InterpolatedPosition> = [];

    var textFont: Font;
    var stateText: Text;
    var stateFrameText: Text;
    var velocityText: Text;

    var isPaused = false;

    override function init() {
        var cache = new ModelCache();

        for (i in 0...numberOfPlayers) {
            playerGamepadIDs.push(-1);
            players.push(new Character());
            playerPositions.push(new InterpolatedPosition());

            var foxModel = cache.loadModel(Res.fox);
            s3d.addChild(foxModel);
            playerModels.push(foxModel);
        }

        cache.dispose();

        s3d.camera.target.set(0.0, 0.0, 25.0);
        s3d.camera.pos.set(-200.0, 0.0, 50.0);

        textFont = hxd.res.DefaultFont.get();

        stateText = new Text(textFont, s2d);
        stateText.textAlign = Center;
        stateText.scale(2.0);
        stateText.x = s2d.width * 0.5;
        stateText.y = s2d.height * 0.3;

        stateFrameText = new Text(textFont, s2d);
        stateFrameText.textAlign = Center;
        stateFrameText.scale(2.0);
        stateFrameText.x = s2d.width * 0.75;
        stateFrameText.y = s2d.height * 0.3;

        velocityText = new Text(textFont, s2d);
        velocityText.textAlign = Center;
        velocityText.scale(2.0);
        velocityText.x = s2d.width * 0.25;
        velocityText.y = s2d.height * 0.3;
    }

    override function update(dt: Float) {
        // Do one step of game physics if possible.
        fixedTimestep.update(dt, physicsUpdate);

        // Update sprite visual positions.
        for (i in 0...numberOfPlayers) {
            if (isPaused) {
                playerPositions[i].interpolation = 0.0;
            }
            else {
                playerPositions[i].interpolation = fixedTimestep.physicsFraction;
            }
            playerModels[i].y = playerPositions[i].x;
            playerModels[i].z = playerPositions[i].y;
        }
    }

    function physicsUpdate() {
        gamepadManager.update();
        for (gamepadID => gamepad in gamepadManager.gamepads) {
            if (gamepad.dUpButton.justPressed) {
                var isVJoy = StringTools.contains(gamepad.heapsPad.name.toLowerCase(), "vjoy");
                if (!isVJoy) {
                    playerGamepadIDs[0] = gamepadID;
                }
            }
        }

        var frameAdvance = false;
        var player0Controller = gamepadManager.gamepads[playerGamepadIDs[0]];
        if (player0Controller != null) {
            if (player0Controller.startButton.justPressed) {
                isPaused = !isPaused;
            }
            if (isPaused && player0Controller.zButton.justPressed) {
                frameAdvance = true;
            }
        }

        if (!isPaused || frameAdvance) {
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
                stateText.text = player.state.getName();
                stateFrameText.text = Std.string(player.stateFrame);
                velocityText.text = floatToStringPrecision(player.xVelocity, 2) + ", " + floatToStringPrecision(player.yVelocity, 2);

                playerPositions[i].x = player.x;
                playerPositions[i].y = player.y;
                if (player.justTurned) {
                    playerModels[i].setDirection(new Vector(player.isFacingRight ? 1.0 : -1.0, 0.0, 0.0));
                }
            }
        }
    }

    static function main() {
        Res.initEmbed();
        new Main();
    }

    static function floatToStringPrecision(n: Float, prec: Int) {
        n = Math.round(n * Math.pow(10, prec));
        var str = ''+n;
        var len = str.length;
        if(len <= prec) {
            while(len < prec) {
                str = '0'+str;
                len++;
            }
            return '0.'+str;
        }
        else {
            return str.substr(0, str.length-prec) + '.'+str.substr(str.length-prec);
        }
    }
}
