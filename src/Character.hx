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
    public var extraJumpVelocityMultiplier = 1.2;
    public var extraJumpHorizontalAxisMultiplier = 0.9;
    public var extraJumps = 1;
    public var gravity = 0.23;

    public var dashBackFrameWindow = 2;
    public var dashMinimumFrames = 21;
    public var slowDashBackFrames = 5;
    public var turnFrames = 11;

    public var x = 0.0;
    public var y = 0.0;
    public var xVelocity = 0.0;
    public var yVelocity = 0.0;
    public var xPrevious(default, null) = 0.0;
    public var yPrevious(default, null) = 0.0;
    public var extraJumpsLeft = 1;
    public var isFacingRight = true;
    public var wasFacingRight(default, null) = true;

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

    // Helper variables.
    public var xAxisActiveFrames = 0;
    public var yAxisActiveFrames = 0;
    public var xAxis: AnalogAxis;
    public var yAxis: AnalogAxis;
    public var shouldJump: Bool;
    public var jumpIsActive: Bool;
    public var xAxisIsForward: Bool;
    public var xAxisIsBackward: Bool;
    public var xAxisSmashed: Bool;
    public var yAxisSmashed: Bool;

    public function new() {
        stateMachine = new CharacterStateMachine(this);
    }

    public function update(controllerState: ControllerState): Void {
        wasFacingRight = isFacingRight;
        xPrevious = x;
        yPrevious = y;

        input.update();
        applyControllerState(controllerState);

        xAxis = input.xAxis;
        yAxis = input.yAxis;
        shouldJump = input.xButton.justPressed || input.yButton.justPressed;
        jumpIsActive = input.xButton.isPressed || input.yButton.isPressed;
        xAxisIsForward = xAxis.isActive && (xAxis.value > 0.0 && isFacingRight || xAxis.value < 0.0 && !isFacingRight);
        xAxisIsBackward = xAxis.isActive && !xAxisIsForward;
        xAxisSmashed = xAxis.magnitude > 0.8 && xAxisActiveFrames < 2;
        yAxisSmashed = yAxis.magnitude > 0.6 && yAxisActiveFrames < 2;

        stateMachine.update();

        if (xAxis.justActivated) {
            xAxisActiveFrames = 0;
        }
        else if (xAxis.isActive) {
            xAxisActiveFrames++;
        }
        else {
            xAxisActiveFrames = 0;
        }

        if (yAxis.justActivated) {
            yAxisActiveFrames = 0;
        }
        else if (yAxis.isActive) {
            yAxisActiveFrames++;
        }
        else {
            yAxisActiveFrames = 0;
        }
    }

    public function moveWithVelocity(): Void {
        x += xVelocity;
        y += yVelocity;
    }

    public function handleHorizontalAirMovement(): Void {
        if (!xAxis.isActive) {
            xVelocity = applyFriction(xVelocity, airFriction);
        }
        else {
            xVelocity = applyAcceleration(xVelocity,
                                          xAxis.value,
                                          airBaseAcceleration,
                                          airAxisAcceleration,
                                          airMaxVelocity,
                                          airFriction);
        }
    }

    public function handleFastFall(): Void {
        if (yVelocity <= 0.0 && yAxis.value < 0.0 && yAxisSmashed) {
            yVelocity = -fastFallVelocity;
        }
    }

    public function handleGravity(): Void {
        yVelocity -= Math.min(gravity, fallVelocity + yVelocity);
    }

    public function applyFriction(velocity: Float, friction: Float): Float {
        return velocity - sign(velocity) * Math.min(Math.abs(velocity), friction);
    }

    public function applyAcceleration(velocity: Float,
                                      axisValue: Float,
                                      baseAcceleration: Float,
                                      axisAcceleration: Float,
                                      maxVelocity: Float,
                                      friction: Float): Float {
        var baseVelocity = velocity;

        if (Math.abs(baseVelocity) > maxVelocity) {
            baseVelocity = applyFriction(baseVelocity, friction);
        }

        var additionalVelocity = sign(axisValue) * baseAcceleration + axisValue * axisAcceleration;

        if (axisValue > 0.0) {
            additionalVelocity = Math.min(additionalVelocity, maxVelocity - baseVelocity);
            additionalVelocity = Math.max(0.0, additionalVelocity);
        }
        else if (axisValue < 0.0) {
            additionalVelocity = Math.max(additionalVelocity, -maxVelocity - baseVelocity);
            additionalVelocity = Math.min(0.0, additionalVelocity);
        }
        else {
            additionalVelocity = 0.0;
        }

        return baseVelocity + additionalVelocity;
    }

    public function sign(value: Float): Float {
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
    }
}
