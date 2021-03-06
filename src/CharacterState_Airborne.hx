class CharacterState_Airborne extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "airborne";

        addTransition("airDodge", function() { return me.input.lButton.justPressed; });
        addTransition("idle", function() { return me.y < 0.0; });
    }

    override public function enter() {
        super.enter();

        if (me.statePrevious == "jumpSquat") {
            me.handleGroundedJump();
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
