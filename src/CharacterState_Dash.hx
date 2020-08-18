class CharacterState_Dash extends CharacterState {
    var resetVelocity = false;

    override public function new(character: Character) {
        super(character);

        name = "dash";

        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("dash", function() { return me.xAxisIsForward && me.stateFrame >= me.dashMaximumFrames; });
        addTransition("run", function() { return me.xAxisIsForward && me.stateFrame >= me.dashMinimumFrames && me.stateFrame < me.dashMaximumFrames; });
        addTransition("idle", function() { return !me.xAxis.isActive && me.stateFrame >= me.dashMaximumFrames; });
        addTransition("turn", function() { return me.xAxisIsBackward; });
    }

    override public function enter() {
        super.enter();

        if (me.statePrevious == "turn") {
            me.isFacingRight = !me.isFacingRight;
        }
        if (me.statePrevious == "dash") {
            resetVelocity = true;
        }
    }

    override public function update() {
        super.update();

        if (me.stateFrame == 1) {
            if (resetVelocity) {
                me.xVelocity = 0.0;
                resetVelocity = false;
            }

            me.xVelocity += me.dashStartVelocity * me.facingDirection;
            if (Math.abs(me.xVelocity) > me.dashMaxVelocity) {
                me.xVelocity = me.dashMaxVelocity * me.facingDirection;
            }
        }
        if (me.stateFrame >= 1) {
            if (!me.xAxis.isActive) {
                me.xVelocity = me.applyFriction(me.xVelocity, me.groundFriction);
            }
            else {
                me.xVelocity = me.applyAcceleration(me.xVelocity,
                                                    me.xAxis,
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
