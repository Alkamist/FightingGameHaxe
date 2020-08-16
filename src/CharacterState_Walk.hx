class CharacterState_Walk extends CharacterState {
    override public function new(character: Character) {
        super(character);
        name = "walk";
    }

    override public function enter() { super.enter(); }

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

        if (me.shouldJump) {
            me.state = "jumpSquat";
        }
        else if (me.xAxisIsForward) {
            if (me.xAxisSmashed) {
                me.state = "dash";
            }
        }
        else {
            me.state = "idle";
        }
    }

    override public function exit () { super.exit(); }
}
