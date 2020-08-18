class CharacterState_RunBrake extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "runBrake";

        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("turn", function() { return me.xAxisIsBackward && me.stateFrame >= me.runBrakeFrames; });
        addTransition("runTurn", function() { return me.xAxisIsBackward && me.stateFrame < me.runBrakeFrames; });
        addTransition("idle", function() { return !me.xAxis.isActive && me.stateFrame >= me.runBrakeFrames; });
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
