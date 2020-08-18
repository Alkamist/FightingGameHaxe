class Character {
    public var groundFriction = 0.08;

    public var dashStartVelocity = 1.9;
    public var dashMaxVelocity = 2.2;
    public var dashBaseAcceleration = 0.02;
    public var dashAxisAcceleration = 0.1;

    public var walkStartVelocity = 0.16;
    public var walkMaxVelocity = 1.6;
    public var walkAcceleration = 0.2;

    public var airFriction = 0.02;
    public var airBaseAcceleration = 0.02;
    public var airAxisAcceleration = 0.06;
    public var airMaxVelocity = 0.83;

    public var jumpSquatFrames = 3;
    public var jumpVelocityDampening = 0.83;
    public var jumpMaxHorizontalVelocity = 1.7;
    public var jumpStartHorizontalVelocity = 0.72;
    public var shortHopVelocity = 2.1;
    public var fullHopVelocity = 3.68;
    public var fallVelocity = 2.8;
    public var fastFallVelocity = 3.4;
    public var airJumpVelocityMultiplier = 1.2;
    public var airJumpHorizontalAxisMultiplier = 0.9;
    public var airJumps = 1;
    public var gravity = 0.23;

    //public var dashBackFrameWindow = 2;
    public var dashMinimumFrames = 11;
    public var dashMaximumFrames = 21;
    public var slowDashBackFrames = 5;
    public var turnFrames = 11;
    public var runTurnFrames = 30;
    public var runBrakeFrames = 18;

    public var x = 0.0;
    public var y = 0.0;
    public var xVelocity = 0.0;
    public var yVelocity = 0.0;
    public var xPrevious(default, null) = 0.0;
    public var yPrevious(default, null) = 0.0;
    public var airJumpsLeft = 1;
    public var isFacingRight = true;
    public var wasFacingRight(default, null) = true;
    public var facingDirection(get, never): Float;
        function get_facingDirection() {
            if (isFacingRight) return 1.0;
            else return -1.0;
        }

    public var justTurned(get, never): Bool;
        function get_justTurned() { return isFacingRight != wasFacingRight; }

    public var state(get, set): String;
        function get_state() { return stateMachine.state; }
        function set_state(newState: String) { return stateMachine.state = newState; }

    public var statePrevious(get, never): String;
        function get_statePrevious() { return stateMachine.statePrevious; }

    public var stateFrame(get, never): Int;
        function get_stateFrame() { return stateMachine.stateFrame; }

    public var input = new ControllerState();
    public var stateMachine: CharacterStateMachine;

    public var xAxis: AnalogAxis;
    public var yAxis: AnalogAxis;

    public var shouldJump(get, never): Bool;
        function get_shouldJump() { return input.xButton.justPressed || input.yButton.justPressed; }
    public var jumpIsActive(get, never): Bool;
        function get_jumpIsActive() { return input.xButton.isPressed || input.yButton.isPressed; }
    public var xAxisIsForward(get, never): Bool;
        function get_xAxisIsForward() { return xAxis.isActive && (xAxis.value > 0.0 && isFacingRight || xAxis.value < 0.0 && !isFacingRight); }
    public var xAxisIsBackward(get, never): Bool;
        function get_xAxisIsBackward() { return xAxis.isActive && !xAxisIsForward; }
    public var xAxisSmashed(get, never): Bool;
        function get_xAxisSmashed() { return xAxis.magnitude >= 0.8 && xAxis.activeFrames < 2; }
    public var yAxisSmashed(get, never): Bool;
        function get_yAxisSmashed() { return yAxis.magnitude >= 0.6625 && yAxis.activeFrames < 2; }

    public function new() {
        stateMachine = new CharacterStateMachine(this);
        xAxis = input.xAxis;
        yAxis = input.yAxis;
    }

    public function update(controllerState: ControllerState) {
        wasFacingRight = isFacingRight;
        xPrevious = x;
        yPrevious = y;

        input.update();
        applyControllerState(controllerState);

        stateMachine.update();

        // Extremely basic ground collision logic for now.
        if (y < 0.0) {
            y = 0.0;
            yVelocity = 0.0;
            land();
        }
    }

    public function moveWithVelocity() {
        x += xVelocity;
        y += yVelocity;
    }

    public function handleWalkMovement() {
        var targetVelocity = walkMaxVelocity * xAxis.value;

        if (Math.abs(xVelocity) > Math.abs(targetVelocity)) {
            xVelocity = applyFriction(xVelocity, groundFriction * 2.0);
        }
        else if (xAxis.isActive && stateFrame >= 1) {
            //var accelerationFactor = 0.125;
            //var biasWeight = 1.833333;
            //var biasFactor = (accelerationFactor * biasWeight);
            //var stickFactor = (2.0 * accelerationFactor * xAxis.magnitude) * (1.0 - biasWeight);
            //var acceleration = (targetVelocity - xVelocity) * (biasFactor + stickFactor);

            // This isn't quite right but close-ish, not sure what the real acceleration calculation is.
            var acceleration = (targetVelocity - xVelocity) * 0.25 * xAxis.magnitude;

            xVelocity += acceleration;

            var goingLeftTooFast = targetVelocity < 0.0 && xVelocity < targetVelocity;
            var goingRightTooFast = targetVelocity > 0.0 && xVelocity > targetVelocity;

            if (goingLeftTooFast || goingRightTooFast) {
                xVelocity = targetVelocity;
            }
        }
    }

    public function handleHorizontalAirMovement() {
        if (!xAxis.isActive) {
            xVelocity = applyFriction(xVelocity, airFriction);
        }
        else {
            xVelocity = applyAcceleration(xVelocity,
                                          xAxis,
                                          airBaseAcceleration,
                                          airAxisAcceleration,
                                          airMaxVelocity,
                                          airFriction);
        }
    }

    public function handleFastFall() {
        if (yVelocity <= 0.0 && yAxis.value < 0.0 && yAxisSmashed) {
            yVelocity = -fastFallVelocity;
        }
    }

    public function handleGravity() {
        yVelocity -= Math.max(Math.min(gravity, fallVelocity + yVelocity), 0.0);
    }

    public function handleGroundedJump() {
        // Handle changing horizontal velocity when jumping off of the ground based on stick x axis.
        xVelocity = (xVelocity * jumpVelocityDampening) + (xAxis.value * jumpStartHorizontalVelocity);
        if (Math.abs(xVelocity) > jumpMaxHorizontalVelocity) {
            xVelocity = sign(xVelocity) * jumpMaxHorizontalVelocity;
        }

        // Handle short hopping and full hopping.
        if (jumpIsActive) {
            yVelocity = fullHopVelocity;
        }
        else {
            yVelocity = shortHopVelocity;
        }
    }

    public function handleAirJumps() {
        if (shouldJump && airJumpsLeft > 0) {
            xVelocity = xAxis.value * airJumpHorizontalAxisMultiplier;
            yVelocity = fullHopVelocity * airJumpVelocityMultiplier;
            airJumpsLeft -= 1;
        }
    }

    public function land() {
        if (state == "airborne") {
            state = "land";
        }
        if (state == "airDodge") {
            state = "landSpecial";
        }
    }

    public function applyFriction(velocity: Float, friction: Float) {
        return velocity - sign(velocity) * Math.min(Math.abs(velocity), friction);
    }

    public function applyAcceleration(velocity: Float,
                                      axis: AnalogAxis,
                                      baseAcceleration: Float,
                                      axisAcceleration: Float,
                                      maxVelocity: Float,
                                      friction: Float) {
        var newVelocity = velocity;

        if (Math.abs(velocity) > maxVelocity) {
            newVelocity = applyFriction(velocity, friction);
        }

        var acceleration = axis.direction * baseAcceleration + axis.value * axisAcceleration;

        if (axis.value > 0.0) {
            acceleration = Math.min(acceleration, maxVelocity - newVelocity);
            acceleration = Math.max(0.0, acceleration);
            newVelocity += acceleration;
        }
        else if (axis.value < 0.0) {
            acceleration = Math.max(acceleration, -maxVelocity - newVelocity);
            acceleration = Math.min(0.0, acceleration);
            newVelocity += acceleration;
        }

        return newVelocity;
    }

    public function sign(value: Float) {
        if (value >= 0.0) return 1.0;
        else return -1.0;
    }

    function applyControllerState(controllerState: ControllerState) {
        input.xAxis.value = controllerState.xAxis.value;
        input.yAxis.value = controllerState.yAxis.value;
        input.cXAxis.value = controllerState.cXAxis.value;
        input.cYAxis.value = controllerState.cYAxis.value;
        input.aButton.isPressed = controllerState.aButton.isPressed;
        input.bButton.isPressed = controllerState.bButton.isPressed;
        input.xButton.isPressed = controllerState.xButton.isPressed;
        input.yButton.isPressed = controllerState.yButton.isPressed;
        input.zButton.isPressed = controllerState.zButton.isPressed;
        input.lButton.isPressed = controllerState.lButton.isPressed;
        input.rButton.isPressed = controllerState.rButton.isPressed;
        input.startButton.isPressed = controllerState.startButton.isPressed;
        input.dLeftButton.isPressed = controllerState.dLeftButton.isPressed;
        input.dRightButton.isPressed = controllerState.dRightButton.isPressed;
        input.dDownButton.isPressed = controllerState.dDownButton.isPressed;
        input.dUpButton.isPressed = controllerState.dUpButton.isPressed;
        input.clampStickMagnitudes(1.0);
    }
}
