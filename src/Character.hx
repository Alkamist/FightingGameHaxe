enum CharacterState {
    airborne;
    idle;
    turn;
    walk;
    dash;
    jumpSquat;
}

class Character {
    public var width = 8.0;
    public var height = 16.0;

    public var groundFriction = 0.08;
    public var dashStartVelocity = 1.9;
    public var dashMaxVelocity = 2.2;
    public var dashBaseAcceleration = 0.02;
    public var dashAxisAcceleration = 0.1;

    public var walkStartVelocity = 0.16;
    public var walkMaxVelocity = 1.6;
    public var walkBaseAcceleration = 0.2;
    public var walkAxisAcceleration = 0.0;

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

    public var state(get, set): CharacterState;
    function get_state(): CharacterState { return m_state; }
    function set_state(value: CharacterState) {
        stateFrame = 0;
        return m_state = value;
    }
    var m_state = airborne;

    public var statePrevious(default, null): CharacterState = airborne;
    public var stateFrame(default, null) = 0;
    public var extraJumpsLeft = 1;
    public var isFacingRight(default, null) = true;
    public var wasFacingRight(default, null) = true;

    public var justTurned(get, never): Bool;
    function get_justTurned(): Bool { return isFacingRight != wasFacingRight; }

    public function new() {}

    public function update(input: ControllerState): Void {
        statePrevious = state;
        wasFacingRight = isFacingRight;

        var xAxis = input.xAxis;
        var shouldJump = input.xButton.justPressed || input.yButton.justPressed;
        var xAxisIsForward = xAxis.isActive && (xAxis.value > 0.0 && isFacingRight || xAxis.value < 0.0 && !isFacingRight);
        var xAxisIsBackward = xAxis.isActive && !xAxisIsForward;
        var xAxisSmashed = xAxis.magnitude > 0.8 && xAxis.activeFrames < 2;

        // Move based on velocity.
        xPrevious = x;
        yPrevious = y;
        x += xVelocity;
        y += yVelocity;

        if (state == idle) {
            xVelocity = applyFriction(xVelocity, groundFriction);

            if (shouldJump) {
                state = jumpSquat;
            }
            else if (xAxisIsForward) {
                if (xAxisSmashed) {
                    state = dash;
                }
                else {
                    state = walk;
                }
            }
            else if (xAxisIsBackward) {
                state = turn;
            }
        }

        else if (state == turn) {
            xVelocity = applyFriction(xVelocity, groundFriction);

            if (shouldJump) {
                state = jumpSquat;
            }
            else if (xAxisIsBackward) {
                //if (xAxisSmashed && (stateFrame < dashBackFrameWindow)
                //                  || stateFrame == slowDashBackFrames) {

                if (xAxisSmashed) {
                    isFacingRight = !isFacingRight;
                    state = dash;
                }
                else if (stateFrame == slowDashBackFrames) {
                //if (stateFrame == slowDashBackFrames) {
                    isFacingRight = !isFacingRight;
                }
            }
            else if (xAxisIsForward && stateFrame >= turnFrames) {
                state = walk;
            }
            else if (stateFrame >= turnFrames) {
                state = idle;
            }
        }

        else if (state == walk) {
            handleWalkMovement(input);

            if (shouldJump) {
                state = jumpSquat;
            }
            else if (xAxisIsForward) {
                if (xAxisSmashed) {
                    state = dash;
                }
                else {
                    state = walk;
                }
            }
            else {
                state = idle;
            }
        }

        else if (state == dash) {
            handleDashMovement(input);

            if (shouldJump) {
                state = jumpSquat;
            }
            else if (xAxisIsBackward) {
                state = turn;
            }
            else if (!xAxis.isActive && stateFrame >= dashMinimumFrames) {
                state = idle;
            }
        }

        else if (state == jumpSquat) {
            xVelocity = applyFriction(xVelocity, groundFriction);

            if (stateFrame >= jumpSquatFrames) {
                handleGroundedJump(input);
                state = airborne;
            }
        }

        else if (state == airborne) {
            handleExtraJumps(input);
            handleHorizontalAirMovement(input);
            handleFastFall(input);
            handleGravity();

            if (y < 0.0) {
                y = 0.0;
                yVelocity = 0.0;
                state = idle;
                extraJumpsLeft = extraJumps;
            }
        }

        //trace(state);

        stateFrame++;
    }

    function handleWalkMovement(input: ControllerState): Void {
        var xAxis = input.xAxis;

        var targetVelocity = walkMaxVelocity * xAxis.value;

        if (Math.abs(xVelocity) > Math.abs(targetVelocity)) {
            xVelocity = applyFriction(xVelocity, groundFriction);
        }
        else {
            var acceleration = (targetVelocity - xVelocity) * (1.0 / (2.0 * walkMaxVelocity)) * (walkStartVelocity + walkBaseAcceleration);
            xVelocity += acceleration;

            var goingLeftTooFast = targetVelocity < 0.0 && xVelocity < targetVelocity;
            var goingRightTooFast = targetVelocity > 0.0 && xVelocity > targetVelocity;

            if (goingLeftTooFast || goingRightTooFast) {
                xVelocity = targetVelocity;
            }
        }
    }

    function handleDashMovement(input: ControllerState): Void {
        var xAxis = input.xAxis;

        if (stateFrame == 1) {
            xVelocity += dashStartVelocity * xAxis.sign;
            if (Math.abs(xVelocity) > dashMaxVelocity) {
                xVelocity = dashMaxVelocity * xAxis.sign;
            }
        }
        if (stateFrame >= 1) {
            if (!xAxis.isActive) {
                xVelocity = applyFriction(xVelocity, groundFriction);
            }
            else {
                var targetVelocity = xAxis.value * dashMaxVelocity;
                var acceleration = xAxis.value * dashAxisAcceleration;

                xVelocity += acceleration;

                var holdingLeftWhileMovingLeft = targetVelocity < 0.0 && xVelocity < targetVelocity;
                var holdingRightWhileMovingRight = targetVelocity > 0.0 && xVelocity > targetVelocity;

                if (holdingLeftWhileMovingLeft || holdingRightWhileMovingRight) {
                    xVelocity = applyFriction(xVelocity, groundFriction);

                    var holdingRightWhileGoingLeft = targetVelocity > 0.0 && xVelocity < targetVelocity;
                    var holdingLeftWhileGoingRight = targetVelocity < 0.0 && xVelocity > targetVelocity;

                    if (holdingRightWhileGoingLeft || holdingLeftWhileGoingRight) {
                        xVelocity = targetVelocity;
                    }
                }
                else {
                    xVelocity += acceleration;

                    holdingLeftWhileMovingLeft = targetVelocity < 0.0 && xVelocity < targetVelocity;
                    holdingRightWhileMovingRight = targetVelocity > 0.0 && xVelocity > targetVelocity;

                    if (holdingLeftWhileMovingLeft || holdingRightWhileMovingRight) {
                        xVelocity = targetVelocity;
                    }
                }
            }
        }
    }

    function handleHorizontalAirMovement(input: ControllerState): Void {
        var xAxis : AnalogAxis = input.xAxis;

        if (xAxis.isActive) {
            xVelocity = applyAcceleration(xVelocity,
                                          xAxis.value,
                                          airBaseAcceleration,
                                          airAxisAcceleration,
                                          airMaxVelocity,
                                          airFriction);
        }
        else {
            xVelocity = applyFriction(xVelocity, airFriction);
        }
    }

    function handleGroundedJump(input: ControllerState): Void {
        var xAxis = input.xAxis;
        var jumpIsActive = input.xButton.isPressed || input.yButton.isPressed;

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

    function handleExtraJumps(input: ControllerState): Void {
        var xAxis = input.xAxis;
        var shouldJump = input.xButton.justPressed || input.yButton.justPressed;

        if (shouldJump && extraJumpsLeft > 0) {
            xVelocity = xAxis.value * extraJumpHorizontalAxisMultiplier;
            yVelocity = fullHopVelocity * extraJumpVelocityMultiplier;
            extraJumpsLeft -= 1;
        }
    }

    function handleFastFall(input: ControllerState): Void {
        var yAxis = input.yAxis;
        var yAxisSmashed = yAxis.magnitude > 0.6 && yAxis.activeFrames < 2;

        if (yVelocity <= 0.0 && yAxis.value < 0.0 && yAxisSmashed) {
            yVelocity = -fastFallVelocity;
        }
    }

    function handleGravity(): Void {
        yVelocity -= Math.min(gravity, fallVelocity + yVelocity);
    }

    function applyFriction(velocity: Float, friction: Float): Float {
        return velocity - sign(velocity) * Math.min(Math.abs(velocity), friction);
    }

    function applyAcceleration(velocity: Float,
                               axisValue: Float,
                               baseAcceleration: Float,
                               axisAcceleration: Float,
                               maxVelocity: Float,
                               friction: Float): Float {

        var baseVelocity = velocity;

        if (Math.abs(baseVelocity) > maxVelocity) {
            baseVelocity = applyFriction(baseVelocity, friction);
        }

        var base = sign(axisValue) * baseAcceleration;
        var axisAddition = axisValue * axisAcceleration;
        var additionalVelocity = base + axisAddition;

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

    function sign(value: Float): Float {
        if (value >= 0.0) return 1.0;
        else return -1.0;
    }
}
