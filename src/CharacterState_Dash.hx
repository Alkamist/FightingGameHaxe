class CharacterState_Dash extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "dash";

        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("turn", function() { return me.xAxisIsBackward; });
        addTransition("idle", function() { return !me.xAxis.isActive && me.stateFrame >= me.dashMinimumFrames; });
    }

    override public function enter() {
        super.enter();

        if (me.statePrevious == "turn") {
            me.isFacingRight = !me.isFacingRight;
        }
    }

    override public function update() {
        super.update();

        // Handle dash movement.
        me.handleDashMovement();
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
