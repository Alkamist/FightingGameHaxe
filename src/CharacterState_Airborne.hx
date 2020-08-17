class CharacterState_Airborne extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "airborne";

        addTransition("idle", function() { return me.y < 0.0; });
    }

    override public function enter() {
        super.enter();

        if (me.statePrevious == "jumpSquat") {
            // Handle changing horizontal velocity when jumping off of the ground based on stick x axis.
            me.xVelocity = (me.xVelocity * me.jumpVelocityDampening) + (me.xAxis.value * me.jumpStartHorizontalVelocity);
            if (Math.abs(me.xVelocity) > me.jumpMaxHorizontalVelocity) {
                me.xVelocity = me.sign(me.xVelocity) * me.jumpMaxHorizontalVelocity;
            }

            // Handle short hopping and full hopping.
            if (me.jumpIsActive) {
                me.yVelocity = me.fullHopVelocity;
            }
            else {
                me.yVelocity = me.shortHopVelocity;
            }
        }
    }

    override public function update() {
        super.update();

        if (me.stateFrame >= 1) {
            me.handleAirJumps();
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
