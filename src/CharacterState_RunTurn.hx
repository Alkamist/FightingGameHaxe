class CharacterState_RunTurn extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "runTurn";

        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("run", function() { return me.xAxisIsForward && me.stateFrame >= me.runTurnFrames; });
        addTransition("turn", function() { return me.xAxisIsBackward && me.stateFrame >= me.runTurnFrames; });
        addTransition("idle", function() { return !me.xAxis.isActive && me.stateFrame >= me.runTurnFrames; });
    }

    override public function enter() {
        super.enter();
    }

    override public function update() {
        super.update();

        // Maybe character dependent?
        if (me.xAxisIsBackward && me.stateFrame == 20) {
            me.isFacingRight = me.xAxis.value >= 0.0;
        }
        me.handleDashMovement();
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
