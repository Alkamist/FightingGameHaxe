class CharacterState_AirDodge extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "airDodge";

        addTransition("idle", function() { return me.y < 0.0; });
    }

    override public function enter() {
        super.enter();

        if (me.xAxis.isActive || me.yAxis.isActive) {
            var stickAngle = me.input.leftStick.angle;
            me.xVelocity = 3.1 * Math.cos(stickAngle);
            me.yVelocity = 3.1 * Math.sin(stickAngle);
        }
        else {
            me.xVelocity = 0.0;
            me.yVelocity = 0.0;
        }
    }

    override public function update() {
        super.update();

        if (me.stateFrame < 30) {
            me.xVelocity *= 0.9;
            me.yVelocity *= 0.9;
        }
        else {
            me.handleHorizontalAirMovement();
            me.handleFastFall();
            me.handleGravity();
        }
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
