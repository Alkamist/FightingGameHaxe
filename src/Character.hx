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

    var xAxisActiveFrames = 0;
    var yAxisActiveFrames = 0;

    public function new() {}

    public function update(input: ControllerState): Void {
        statePrevious = state;
        wasFacingRight = isFacingRight;

        var xAxis = input.xAxis;
        var yAxis = input.yAxis;
        var shouldJump = input.xButton.justPressed || input.yButton.justPressed;
        var xAxisIsForward = xAxis.isActive && (xAxis.value > 0.0 && isFacingRight || xAxis.value < 0.0 && !isFacingRight);
        var xAxisIsBackward = xAxis.isActive && !xAxisIsForward;
        var xAxisSmashed = xAxis.magnitude > 0.8 && xAxisActiveFrames < 2;

        // Move based on velocity.
        xPrevious = x;
        yPrevious = y;
        x += xVelocity;
        y += yVelocity;

        if (state == idle) {
            applyGroundFriction(false);

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
            applyGroundFriction(true);

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
            applyGroundFriction(true);

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

        stateFrame++;

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

    function handleWalkMovement(input: ControllerState): Void {
        var xAxis = input.xAxis;

        var targetVelocity = walkMaxVelocity * xAxis.value;

        if (Math.abs(xVelocity) > Math.abs(targetVelocity)) {
            applyGroundFriction(true);
        }
        else {
            var acceleration = (targetVelocity - xVelocity) * (1.0 / (2.0 * walkMaxVelocity)) * (walkStartVelocity + walkAcceleration);
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
                applyGroundFriction(false);
            }
            else {
                var targetVelocity = xAxis.value * dashMaxVelocity;
                var acceleration = xAxis.value * dashAxisAcceleration;

                xVelocity += acceleration;

                var holdingLeftAndMovingLeftTooFast = targetVelocity < 0.0 && xVelocity < targetVelocity;
                var holdingRightAndMovingRightTooFast = targetVelocity > 0.0 && xVelocity > targetVelocity;

                if (holdingLeftAndMovingLeftTooFast || holdingRightAndMovingRightTooFast) {
                    applyGroundFriction(false);

                    var holdingLeftAndCanGainSpeed = targetVelocity < 0.0 && xVelocity > targetVelocity;
                    var holdingRightAndCanGainSpeed = targetVelocity > 0.0 && xVelocity < targetVelocity;

                    if (holdingLeftAndCanGainSpeed || holdingRightAndCanGainSpeed) {
                        xVelocity = targetVelocity;
                    }
                }
                else {
                    xVelocity += acceleration;

                    holdingLeftAndMovingLeftTooFast = targetVelocity < 0.0 && xVelocity < targetVelocity;
                    holdingRightAndMovingRightTooFast = targetVelocity > 0.0 && xVelocity > targetVelocity;

                    if (holdingLeftAndMovingLeftTooFast || holdingRightAndMovingRightTooFast) {
                        xVelocity = targetVelocity;
                    }
                }
            }
        }
    }

    function handleHorizontalAirMovement(input: ControllerState): Void {
        var xAxis : AnalogAxis = input.xAxis;

        var maxVelocity = xAxis.isActive ? xAxis.value * airMaxVelocity : 0.0;

        var isHoldingLeftAndMovingLeftTooFast = maxVelocity < 0.0 && xVelocity < maxVelocity;
        var isHoldingRightAndMovingRightTooFast = maxVelocity > 0.0 && xVelocity > maxVelocity;
        var isHoldingLeftAndCanGainSpeed = maxVelocity < 0.0 && xVelocity > maxVelocity;
        var isHoldingRightAndCanGainSpeed = maxVelocity > 0.0 && xVelocity < maxVelocity;

        if (isHoldingLeftAndMovingLeftTooFast || isHoldingRightAndMovingRightTooFast) {
            if (xVelocity > 0.0) {
                xVelocity -= airFriction;
                if (xVelocity < 0.0) {
                    xVelocity = 0.0;
                }
            } else {
                xVelocity += airFriction;
                if (xVelocity > 0.0) {
                    xVelocity = 0.0;
                }
            }
        } else if (isHoldingLeftAndCanGainSpeed || isHoldingRightAndCanGainSpeed) {
            xVelocity += (airAxisAcceleration * xAxis.value) + (xAxis.sign * airBaseAcceleration);
        }

        if (!xAxis.isActive) {
            if (xVelocity > 0.0) {
                xVelocity -= airFriction;
                if (xVelocity < 0.0) {
                    xVelocity = 0.0;
                }
            } else {
                xVelocity += airFriction;
                if (xVelocity > 0.0) {
                    xVelocity = 0.0;
                }
            }
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
        var yAxisSmashed = yAxis.magnitude > 0.6 && yAxisActiveFrames < 2;

        if (yVelocity <= 0.0 && yAxis.value < 0.0 && yAxisSmashed) {
            yVelocity = -fastFallVelocity;
        }
    }

    function handleGravity(): Void {
        yVelocity -= Math.min(gravity, fallVelocity + yVelocity);
    }

    function applyGroundFriction(applyDouble: Bool) {
        if (xVelocity > 0.0) {
            if (applyDouble && xVelocity > walkMaxVelocity) {
                xVelocity -= groundFriction * 2.0;
            }
            else {
                xVelocity -= groundFriction;
            }
            if (xVelocity < 0.0) {
                xVelocity = 0.0;
            }
        } else {
            if (applyDouble && xVelocity < -walkMaxVelocity) {
                xVelocity += groundFriction * 2.0;
            } else {
                xVelocity += groundFriction;
            }
            if (xVelocity > 0.0) {
                xVelocity = 0.0;
            }
        }
    }

    function sign(value: Float): Float {
        if (value >= 0.0) return 1.0;
        else return -1.0;
    }
}
