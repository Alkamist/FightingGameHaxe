class CharacterState_Turn extends CharacterState {
    override public function new(character: Character) {
        super(character);
        name = "turn";
    }

    override public function enter() {
        super.enter();
        if (me.statePrevious == "dash") {
            me.xVelocity -= me.sign(me.xVelocity) * 1.61;
        }
    }

    override public function update() {
        super.update();

        // Not quite right.
        if (me.stateFrame > 1) {
            me.xVelocity = me.applyFriction(me.xVelocity, me.groundFriction * 2.0);
        }

        me.moveWithVelocity();

        if (me.shouldJump) {
            me.state = "jumpSquat";
        }
        else if (me.xAxisIsBackward) {
            if (me.xAxisSmashed) {
                me.isFacingRight = !me.isFacingRight;
                me.state = "dash";
            }
            else if (me.stateFrame == me.slowDashBackFrames) {
                me.isFacingRight = !me.isFacingRight;
            }
        }
        else if (me.xAxisIsForward && me.stateFrame >= me.turnFrames) {
            me.state = "walk";
        }
        else if (me.stateFrame >= me.turnFrames) {
            me.state = "idle";
        }
    }

    override public function exit () { super.exit(); }
}
