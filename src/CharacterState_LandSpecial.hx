class CharacterState_LandSpecial extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "landSpecial";

        addTransition("idle", function() { return me.stateFrame >= 8; });
    }

    override public function enter() {
        super.enter();

        me.yVelocity = 0.0;
        me.airJumpsLeft = me.airJumps;
    }

    override public function update() {
        super.update();

        var frictionMultiplier = me.stateFrame < 3 ? 2.0 : 1.0;
        me.xVelocity = me.applyFriction(me.xVelocity, me.groundFriction * frictionMultiplier);
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
