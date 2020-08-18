class CharacterState_RunTurn extends CharacterState {
    var hasFullyTurned = false;
    var wasInitiallyFacingRight = true;
    var hasChangedDirection = false;
    var internalFrameCounter = 0;

    override public function new(character: Character) {
        super(character);

        name = "runTurn";

        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("run", function() { return me.xAxisIsForward && internalFrameCounter >= 20; });
        addTransition("turn", function() { return me.xAxisIsBackward && internalFrameCounter >= 20; });
        addTransition("idle", function() { return !me.xAxis.isActive && internalFrameCounter >= 20; });
    }

    override public function enter() {
        super.enter();

        internalFrameCounter = 0;
        wasInitiallyFacingRight = me.isFacingRight;
        hasChangedDirection = false;
        hasFullyTurned = false;
    }

    override public function update() {
        super.update();

        if ((wasInitiallyFacingRight && me.xVelocity <= 0.0 || !wasInitiallyFacingRight && me.xVelocity >= 0.0)) {
            hasFullyTurned = true;
        }

        if (!hasChangedDirection && hasFullyTurned) {
            me.isFacingRight = !me.isFacingRight;
            hasChangedDirection = true;
        }

        if (!me.xAxis.isActive
        || (!hasFullyTurned && me.xAxisIsForward)
        || (hasFullyTurned && me.xAxisIsBackward)) {
            me.xVelocity = me.applyFriction(me.xVelocity, me.groundFriction);
        }
        else {
            me.xVelocity = me.applyAcceleration(me.xVelocity,
                                                me.xAxis,
                                                me.dashBaseAcceleration,
                                                me.dashAxisAcceleration,
                                                me.dashMaxVelocity,
                                                me.groundFriction);
        }

        me.moveWithVelocity();

        if (hasFullyTurned || (internalFrameCounter < 9 && !hasFullyTurned)) {
            internalFrameCounter++;
        }
    }

    override public function exit() {
        super.exit();
    }
}
