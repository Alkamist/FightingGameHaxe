class CharacterState_Run extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "run";

        addTransition("jumpSquat", function() { return me.shouldJump; });
        addTransition("runBrake", function() { return !me.xAxis.isActive; });
        addTransition("runTurn", function() { return me.xAxisIsBackward; });
    }

    override public function enter() {
        super.enter();
    }

    override public function update() {
        super.update();

        var runAcceleration = ((me.dashMaxVelocity * me.xAxis.value) - me.xVelocity) * (1.0 / (2.5 * me.dashMaxVelocity)) * (me.dashAxisAcceleration + (me.dashBaseAcceleration / me.xAxis.magnitude));
        me.xVelocity += runAcceleration;

        me.moveWithVelocity();
    }

    override public function exit() {
        super.exit();
    }
}
