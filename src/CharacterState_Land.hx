class CharacterState_Land extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "land";

        addTransition("idle", function() { return me.stateFrame >= 4; });
    }

    override public function enter() {
        super.enter();

        me.yVelocity = 0.0;
        me.airJumpsLeft = me.airJumps;
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
