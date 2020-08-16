import hxd.Window;

class KeyboardController extends ControllerState {
    public var keyboardTracker: KeyboardTracker;

    public var keyBinds = [
        "left" => "a",
        "right" => "d",
        "down" => "s",
        "up" => "w",
        "xMod" => "leftAlt",
        "yMod" => "space",
        "tilt" => "capsLock",
        "cLeft" => "l",
        "cRight" => "'",
        "cDown" => "/",
        "cUp" => "p",
        "shortHop" => "[",
        "fullHop" => "\\",
        "a" => "rightWindows",
        "b" => "rightAlt",
        "bUp" => "backspace",
        "bSide" => "enter",
        "z" => "=",
        "shield" => "]",
        "toggleLightShield" => "space",
        "airDodge" => ";",
        "start" => "5",
        "dLeft" => "v",
        "dRight" => "n",
        "dDown" => "b",
        "dUp" => "g",
        "chargeSmash" => "space",
        "invertXAxis" => "rightShift",
    ];

    public var actionStates = new Map<String, Button>();

    public function new(window: Window) {
        super();
        keyboardTracker = new KeyboardTracker(window);
        for (actionName in keyBinds.keys()) {
            actionStates[actionName] = new Button();
        }
    }

    override public function update() {
        super.update();

        // Update keyboard keys.
        keyboardTracker.update();

        // Update action states based on key binds.
        for (actionName => button in actionStates) {
            button.update();
            var keyBind = keyBinds[actionName];
            button.isPressed = keyboardTracker.keys[keyBind].isPressed;
        }

        xAxis.setValueFromStates(actionStates["left"].isPressed, actionStates["right"].isPressed);
        yAxis.setValueFromStates(actionStates["down"].isPressed, actionStates["up"].isPressed);
        cXAxis.setValueFromStates(actionStates["cLeft"].isPressed, actionStates["cRight"].isPressed);
        cYAxis.setValueFromStates(actionStates["cDown"].isPressed, actionStates["cUp"].isPressed);

        //xAxis.value *= 0.3;

        aButton.isPressed = actionStates["a"].isPressed;
        bButton.isPressed = actionStates["b"].isPressed;
        xButton.isPressed = actionStates["fullHop"].isPressed;
        yButton.isPressed = actionStates["shortHop"].isPressed;
        zButton.isPressed = actionStates["z"].isPressed;
        lButton.isPressed = actionStates["airDodge"].isPressed;
        rButton.isPressed = actionStates["shield"].isPressed;
        startButton.isPressed = actionStates["start"].isPressed;
        dLeftButton.isPressed = actionStates["dLeft"].isPressed;
        dRightButton.isPressed = actionStates["dRight"].isPressed;
        dDownButton.isPressed = actionStates["dDown"].isPressed;
        dUpButton.isPressed = actionStates["dUp"].isPressed;
    }
}
