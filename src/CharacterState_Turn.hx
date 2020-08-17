class CharacterState_Turn extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "turn";

        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("dash", function() { return me.xAxisIsBackward && me.xAxisSmashed; });
        addTransition("walk", function() { return me.xAxisIsForward && me.stateFrame >= me.turnFrames; });
        addTransition("idle", function() { return me.stateFrame >= me.turnFrames; });
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
        if (me.xAxisIsBackward && me.stateFrame == me.slowDashBackFrames) {
            me.isFacingRight = !me.isFacingRight;
        }
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
