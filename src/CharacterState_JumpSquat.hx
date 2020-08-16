class CharacterState_JumpSquat extends CharacterState {
    override public function new(character: Character) {
        super(character);
        name = "jumpSquat";
    }

    override public function enter() { super.enter(); }

    override public function update() {
        super.update();

        me.xVelocity = me.applyFriction(me.xVelocity, me.groundFriction);
        me.moveWithVelocity();

        if (me.stateFrame >= me.jumpSquatFrames) {
            // Handle changing horizontal velocity when jumping off of the ground based on stick x axis.
            me.xVelocity = (me.xVelocity * me.jumpVelocityDampening) + (me.xAxis.value * me.jumpStartHorizontalVelocity);
            if (Math.abs(me.xVelocity) > me.jumpMaxHorizontalVelocity) {
                me.xVelocity = me.sign(me.xVelocity) * me.jumpMaxHorizontalVelocity;
            }

            // Handle short hopping and full hopping.
            if (me.jumpIsActive) {
                me.yVelocity = me.fullHopVelocity;
            }
            else {
                me.yVelocity = me.shortHopVelocity;
            }

            me.state = "airborne";
        }
    }

    override public function exit () { super.exit(); }
}
