class CharacterState_Dash extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "dash";

        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("turn", function() { return me.xAxisIsBackward; });
        addTransition("idle", function() { return !me.xAxis.isActive && me.stateFrame >= me.dashMinimumFrames; });
    }

    override public function enter() {
        super.enter();

        if (me.statePrevious == "turn") {
            me.isFacingRight = !me.isFacingRight;
        }
    }

    override public function update() {
        super.update();

        // Handle dash movement.
        if (me.stateFrame == 1) {
            me.xVelocity += me.dashStartVelocity * me.xAxis.sign;
            if (Math.abs(me.xVelocity) > me.dashMaxVelocity) {
                me.xVelocity = me.dashMaxVelocity * me.xAxis.sign;
            }
        }
        if (me.stateFrame >= 1) {
            if (!me.xAxis.isActive) {
                me.xVelocity = me.applyFriction(me.xVelocity, me.groundFriction);
            }
            else {
                me.xVelocity = me.applyAcceleration(me.xVelocity,
                                                    me.xAxis.value,
                                                    me.dashBaseAcceleration,
                                                    me.dashAxisAcceleration,
                                                    me.dashMaxVelocity,
                                                    me.groundFriction);
            }
        }
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
