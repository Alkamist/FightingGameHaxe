class CharacterState_JumpSquat extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "jumpSquat";

        addTransition("airDodge", function() { return me.input.lButton.isPressed && me.stateFrame >= me.jumpSquatFrames; });
        addTransition("airborne", function() { return me.stateFrame >= me.jumpSquatFrames; });
    }

    override public function enter() {
        super.enter();
    }

    override public function update() {
        super.update();

        me.xVelocity = me.applyFriction(me.xVelocity, me.groundFriction * 2.0);
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
