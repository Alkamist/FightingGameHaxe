class CharacterState_Walk extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "walk";

        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("dash", function() { return me.xAxisIsForward && me.xAxisSmashed; });
        addTransition("idle", function() { return !me.xAxisIsForward; });
    }

    override public function enter() {
        super.enter();
    }

    override public function update() {
        super.update();

        // Handle walk movement.
        var targetVelocity = me.walkMaxVelocity * me.xAxis.value;
        if (Math.abs(me.xVelocity) > Math.abs(targetVelocity)) {
            me.xVelocity = me.applyFriction(me.xVelocity, me.groundFriction);
        }
        else {
            var acceleration = (targetVelocity - me.xVelocity) * (1.0 / (2.0 * me.walkMaxVelocity)) * (me.walkStartVelocity + me.walkAcceleration);
            me.xVelocity += acceleration;

            var goingLeftTooFast = targetVelocity < 0.0 && me.xVelocity < targetVelocity;
            var goingRightTooFast = targetVelocity > 0.0 && me.xVelocity > targetVelocity;

            if (goingLeftTooFast || goingRightTooFast) {
                me.xVelocity = targetVelocity;
            }
        }
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
