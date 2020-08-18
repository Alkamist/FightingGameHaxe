import h3d.scene.Object;
import h3d.Vector;
import h3d.prim.ModelCache;

import h2d.Font;
import h2d.Text;

import hxd.Res;

class Main extends hxd.App {
    var player = new Character();
    var playerModel: Object;
    var playerPosition = new InterpolatedPosition();

    var keyboardController: KeyboardController;
    var gamepadManager: GamepadManager;
    var currentController: ControllerState;

    var fixedTimestep = new FixedTimestep();

    var textFont: Font;
    var stateText: Text;
    var stateFrameText: Text;
    var velocityText: Text;
    var stickText: Text;

    var isPaused = false;

    override function init() {
        var cache = new ModelCache();
        var foxModel = cache.loadModel(Res.fox);
        s3d.addChild(foxModel);
        playerModel = foxModel;
        cache.dispose();

        //s3d.lightSystem.ambientLight.set(1.0, 1.0, 1.0);
        s3d.lightSystem.ambientLight.set(1.0, 1.0, 1.0);

        s3d.camera.target.set(0.0, 0.0, 25.0);
        s3d.camera.pos.set(-200.0, 0.0, 60.0);

        textFont = hxd.res.DefaultFont.get();

        stateText = new Text(textFont, s2d);
        stateText.textAlign = Center;
        stateText.scale(2.0);
        stateText.x = s2d.width * 0.5;
        stateText.y = s2d.height * 0.3;

        stateFrameText = new Text(textFont, s2d);
        stateFrameText.textAlign = Center;
        stateFrameText.scale(2.0);
        stateFrameText.x = stateText.x + 200;
        stateFrameText.y = stateText.y;

        velocityText = new Text(textFont, s2d);
        velocityText.textAlign = Center;
        velocityText.scale(2.0);
        velocityText.x = stateText.x - 200;
        velocityText.y = stateText.y;

        stickText = new Text(textFont, s2d);
        stickText.textAlign = Center;
        stickText.scale(2.0);
        stickText.x = velocityText.x;
        stickText.y = velocityText.y - 50;

        keyboardController = new KeyboardController(hxd.Window.getInstance());
        gamepadManager = new GamepadManager();
        currentController = keyboardController;
    }

    override function update(dt: Float) {
        // Do one step of game physics if possible.
        fixedTimestep.update(dt, physicsUpdate);

        // Update the visual position of the player model.
        if (isPaused) {
            playerPosition.interpolation = 1.0;
        }
        else {
            playerPosition.interpolation = fixedTimestep.physicsFraction;
        }
        playerModel.y = playerPosition.x;
        playerModel.z = playerPosition.y;
    }

    function physicsUpdate() {
        keyboardController.update();
        gamepadManager.update();

        for (gamepad in gamepadManager.gamepads) {
            if (gamepad.dUpButton.justPressed) {
                currentController = gamepad;
            }
        }

        var frameAdvance = false;

        if (currentController.startButton.justPressed) {
            isPaused = !isPaused;
        }
        if (isPaused && currentController.zButton.justPressed) {
            frameAdvance = true;
        }

        stickText.text = floatToStringPrecision(currentController.xAxis.value, 4) + ", " + floatToStringPrecision(currentController.yAxis.value, 4);

        if (!isPaused || frameAdvance) {
            player.update(currentController);
            stateText.text = player.state;
            stateFrameText.text = Std.string(player.stateFrame);
            velocityText.text = floatToStringPrecision(player.xVelocity, 5) + ", " + floatToStringPrecision(player.yVelocity, 5);

            playerPosition.x = player.x;
            playerPosition.y = player.y;
            if (player.justTurned) {
                playerModel.setDirection(new Vector(player.isFacingRight ? 1.0 : -1.0, 0.0, 0.0));
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
