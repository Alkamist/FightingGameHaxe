class CharacterState_LandSpecial extends CharacterState {
    override public function new(character: Character) {
        super(character);

        name = "landSpecial";

        addTransition("jumpSquat", function() { return me.shouldJump && me.stateFrame >= 9; });
        addTransition("dash", function() { return me.xAxisIsForward && me.xAxisSmashed && me.stateFrame >= 9; });
        addTransition("walk", function() { return me.xAxisIsForward && !me.xAxisSmashed && me.stateFrame >= 9; });
        addTransition("turn", function() { return me.xAxisIsBackward && me.stateFrame >= 9; });
        addTransition("idle", function() { return !me.xAxis.isActive && me.stateFrame >= 9; });
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
