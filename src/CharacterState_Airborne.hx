class CharacterState_Airborne extends CharacterState {
    override public function new(character: Character) {
        super(character);
        name = "airborne";
    }

    override public function enter() {
        super.enter();
    }

    override public function update() {
        super.update();

        // Handle extra jumps.
        if (me.shouldJump && me.extraJumpsLeft > 0) {
            me.xVelocity = me.xAxis.value * me.extraJumpHorizontalAxisMultiplier;
            me.yVelocity = me.fullHopVelocity * me.extraJumpVelocityMultiplier;
            me.extraJumpsLeft -= 1;
        }

        me.handleHorizontalAirMovement();
        me.handleFastFall();
        me.handleGravity();
        me.moveWithVelocity();

        if (me.y < 0.0) {
            me.y = 0.0;
            me.yVelocity = 0.0;
            me.state = "idle";
            me.extraJumpsLeft = me.extraJumps;
        }
    }

    override public function exit () { super.exit(); }
}
