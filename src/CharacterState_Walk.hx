class CharacterState_Walk extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "walk";

        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("dash", function() { return me.xAxisIsForward && me.xAxisSmashed; });
        addTransition("idle", function() { return !me.xAxisIsForward; });
    }

    override public function enter() {
        super.enter();

        if (me.xAxis.isActive) {
            //var axisScale = me.xAxis.value / 0.5;
            //me.xVelocity += me.facingDirection * 0.11429 * axisScale;

            me.xVelocity += me.facingDirection * (0.1 + 0.2 * me.xAxis.value);
        }
    }

    override public function update() {
        super.update();

        // Handle walk movement.
        me.handleWalkMovement();
        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
