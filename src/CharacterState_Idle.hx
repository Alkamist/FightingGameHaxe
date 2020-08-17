class CharacterState_Idle extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "idle";

        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("dash", function() { return me.xAxisIsForward && me.xAxisSmashed; });
        addTransition("walk", function() { return me.xAxisIsForward && !me.xAxisSmashed; });
        addTransition("turn", function() { return me.xAxisIsBackward; });
    }

    override public function enter() {
        super.enter();
    }

    override public function update() {
        super.update();

        me.xVelocity = me.applyFriction(me.xVelocity, me.groundFriction);
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
