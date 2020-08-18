class CharacterState_Dash extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "dash";

        addTransition("run", function() { return me.stateFrame >= me.dashMinimumFrames; });
        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("turn", function() { return me.xAxisIsBackward; });
    }

    override public function enter() {
        super.enter();

        if (me.statePrevious == "turn") {
            me.isFacingRight = !me.isFacingRight;
        }
    }

    override public function update() {
        super.update();

        if (me.stateFrame == 1) {
            me.xVelocity += me.dashStartVelocity * me.xAxis.direction;
            if (Math.abs(me.xVelocity) > me.dashMaxVelocity) {
                me.xVelocity = me.dashMaxVelocity * me.xAxis.direction;
            }
        }
        if (me.stateFrame >= 1) {
            me.handleDashMovement();
        }
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
