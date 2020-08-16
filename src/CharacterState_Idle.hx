class CharacterState_Idle extends CharacterState {
    override public function new(character: Character) {
        super(character);
        name = "idle";
    }

    override public function enter() { super.enter(); }

    override public function update() {
        super.update();

        me.xVelocity = me.applyFriction(me.xVelocity, me.groundFriction);
        me.moveWithVelocity();

        if (me.shouldJump) {
            me.state = "jumpSquat";
        }
        else if (me.xAxisIsForward) {
            if (me.xAxisSmashed) {
                me.state = "dash";
            }
            else {
                me.state = "walk";
            }
        }
        else if (me.xAxisIsBackward) {
            me.state = "turn";
        }
    }

    override public function exit () { super.exit(); }
}
