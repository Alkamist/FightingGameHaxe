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
            // I'm unsure where the 1.73 here comes from but it is necessary for now.
            me.xVelocity -= me.sign(me.xVelocity) * 1.73;
        }
    }

    override public function update() {
        super.update();

        // Not quite right. Turn friction in melee applies on the first frame while walking,
        // but not during the one frame of turn seen while dash dancing. Need to implement that.
        if (me.stateFrame > 1) {
            me.xVelocity = me.applyFriction(me.xVelocity, me.groundFriction * 2.0);
        }
        if (me.xAxisIsBackward && me.stateFrame == me.slowDashBackFrames) {
            me.isFacingRight = me.xAxis.value >= 0.0;
        }
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
