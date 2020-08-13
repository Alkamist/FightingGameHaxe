enum CharacterState {
    airborne;
    idle;
    walk;
    dash;
    jumpSquat;
}

class Character {
    public var width : Float = 8.0;
    public var height : Float = 16.0;

    public var groundFriction : Float = 0.08;
    public var dashStartVelocity : Float = 1.9;
    public var dashMaxVelocity : Float = 2.2;
    public var dashBaseAcceleration : Float = 0.02;
    public var dashAxisAcceleration : Float = 0.1;

    public var walkStartVelocity : Float = 0.16;
    public var walkMaxVelocity : Float = 1.6;
    public var walkBaseAcceleration : Float = 0.2;
    public var walkAxisAcceleration : Float = 0.0;

    public var airFriction : Float = 0.02;
    public var airBaseAcceleration : Float = 0.02;
    public var airAxisAcceleration : Float = 0.06;
    public var airMaxVelocity : Float = 0.83;

    public var jumpSquatFrames : Float = 3;
    public var jumpVelocityDampening : Float = 0.83;
    public var jumpMaxHorizontalVelocity : Float = 1.7;
    public var jumpStartHorizontalVelocity : Float = 0.72;
    public var shortHopVelocity : Float = 2.1;
    public var fullHopVelocity : Float = 3.68;
    public var fallVelocity : Float = 2.8;
    public var fastFallVelocity : Float = 3.4;
    public var extraJumpVelocityMultiplier : Float = 1.2;
    public var extraJumpHorizontalAxisMultiplier : Float = 0.9;
    public var extraJumps : Int = 1;
    public var gravity : Float = 0.23;

    public var x : Float = 0.0;
    public var y : Float = 0.0;
    public var xVelocity : Float = 0.0;
    public var yVelocity : Float = 0.0;
    public var xPrevious(default, null) : Float = 0.0;
    public var yPrevious(default, null) : Float = 0.0;

    public var state : CharacterState = airborne;
    public var statePrevious(default, null) : CharacterState = airborne;
    public var stateFrame(default, null) : Int = 0;
    public var extraJumpsLeft : Int = 1;
    public var isFacingRight(default, null) : Bool = true;
    public var wasFacingRight(default, null) : Bool = true;
    public var justTurned(get, never) : Bool;
    function get_justTurned() return isFacingRight != wasFacingRight;

    public function new() {}

    public function land() {
        yVelocity = 0.0;
        state = idle;
        extraJumpsLeft = extraJumps;
        //update();
    }

    public function update(input : ControllerState) {
        statePrevious = state;
        wasFacingRight = isFacingRight;

        decideState(input);
        if (state != statePrevious) {
            stateFrame = 0;
        }
        processState(input);

        // Move based on velocity.
        xPrevious = x;
        yPrevious = y;
        x += xVelocity;
        y += yVelocity;

        stateFrame++;
    }

    function decideState(input : ControllerState) {
        var xAxis : AnalogAxis = input.xAxis;
        var shouldJump : Bool = input.xButton.justPressed || input.yButton.justPressed;
        var xAxisSmashed : Bool = xAxis.magnitude > 0.8 && xAxis.activeFrames < 3;

        if (state == idle) {
            if (shouldJump) {
                state = jumpSquat;
            }
            else if (xAxisSmashed) {
                state = dash;
            }
            else if (xAxis.isActive) {
                state = walk;
            }
        }
        else if (state == walk) {
            if (shouldJump) {
                state = jumpSquat;
            }
            else if (xAxisSmashed) {
                state = dash;
            }
            else {
                state = idle;
            }
        }
        else if (state == dash) {
            if (shouldJump) {
                state = jumpSquat;
            }
            //else if (xAxis.justCrossedCenter && !xAxisSmashed) {
            //    state = walk;
            //}
            else if (!xAxis.isActive) {
                state = idle;
            }
        }
        else if (state == jumpSquat) {
            if (stateFrame >= jumpSquatFrames) {
                state = airborne;
            }
        }
    }

    function processState(input : ControllerState) {
        var xAxis : AnalogAxis = input.xAxis;

        if (state == idle) {
            xVelocity = applyFriction(xVelocity, groundFriction);
        }
        else if (state == walk) {
            if (xAxis.isActive) {
                isFacingRight = xAxis.value > 0.0;
            }
            handleWalkMovement(input);
        }
        else if (state == dash) {
            if (xAxis.isActive) {
                isFacingRight = xAxis.value > 0.0;
            }
            handleDashMovement(input);
        }
        else if (state == jumpSquat) {
            xVelocity = applyFriction(xVelocity, groundFriction);
        }
        else if (state == airborne) {
            handleGroundedJump(input);
            handleExtraJumps(input);
            handleHorizontalAirMovement(input);
            handleFastFall(input);
            handleGravity();
        }
    }

    function handleWalkMovement(input : ControllerState) {
        var xAxis : AnalogAxis = input.xAxis;

        if (Math.abs(xVelocity) < walkStartVelocity) {
            xVelocity = xAxis.sign * walkStartVelocity;
        }

        xVelocity = applyAcceleration(xVelocity,
                                      xAxis.value,
                                      walkBaseAcceleration,
                                      walkAxisAcceleration,
                                      walkMaxVelocity,
                                      groundFriction);
    }

    function handleDashMovement(input : ControllerState) {
        var xAxis : AnalogAxis = input.xAxis;

        if (Math.abs(xVelocity) < dashStartVelocity) {
            xVelocity = xAxis.sign * dashStartVelocity;
        }

        xVelocity = applyAcceleration(xVelocity,
                                      xAxis.value,
                                      dashBaseAcceleration,
                                      dashAxisAcceleration,
                                      dashMaxVelocity,
                                      groundFriction);
    }

    function handleHorizontalAirMovement(input : ControllerState) {
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

    function handleGroundedJump(input : ControllerState) {
        var xAxis : AnalogAxis = input.xAxis;
        var jumpIsActive : Bool = input.xButton.isPressed || input.yButton.isPressed;

        if (statePrevious == jumpSquat) {
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
    }

    function handleExtraJumps(input : ControllerState) {
        var xAxis : AnalogAxis = input.xAxis;
        var shouldJump : Bool = input.xButton.justPressed || input.yButton.justPressed;

        if (shouldJump && extraJumpsLeft > 0) {
            xVelocity = xAxis.value * extraJumpHorizontalAxisMultiplier;
            yVelocity = fullHopVelocity * extraJumpVelocityMultiplier;
            extraJumpsLeft -= 1;
        }
    }

    function handleFastFall(input : ControllerState) {
        var yAxis : AnalogAxis = input.yAxis;
        var yAxisSmashed : Bool = yAxis.magnitude > 0.6 && yAxis.activeFrames < 3;

        if (yVelocity <= 0.0 && yAxis.value < 0.0 && yAxisSmashed) {
            yVelocity = -fastFallVelocity;
        }
    }

    function handleGravity() {
        yVelocity -= Math.min(gravity, fallVelocity + yVelocity);
    }

    function applyFriction(velocity : Float, friction : Float) {
        return velocity - sign(velocity) * Math.min(Math.abs(velocity), friction);
    }

    function applyAcceleration(velocity : Float,
                               axisValue : Float,
                               baseAcceleration : Float,
                               axisAcceleration : Float,
                               maxVelocity : Float,
                               friction : Float) {

        var baseVelocity : Float = velocity;

        if (Math.abs(baseVelocity) > maxVelocity) {
            baseVelocity = applyFriction(baseVelocity, friction);
        }

        var base : Float = sign(axisValue) * baseAcceleration;
        var axisAddition : Float = axisValue * axisAcceleration;
        var additionalVelocity : Float = base + axisAddition;

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

    function sign(value : Float) {
        if (value >= 0.0) return 1.0;
        else return -1.0;
    }
}
