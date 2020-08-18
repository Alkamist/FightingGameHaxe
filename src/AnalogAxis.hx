class AnalogAxis {
    public var value = 0.0;
        //function set_value(input: Float) {
        //    var clampedValue = Math.min(Math.max(input, -1.0), 1.0);
        //}

    public var valuePrevious(default, null) = 0.0;
    public var deadZone = 0.2875;

    public var magnitude(get, never): Float;
        function get_magnitude() {
            if (value < 0.0) return -value;
            else return value;
        }

    public var sign(get, never): Float;
        function get_sign() {
            if (value < 0.0) return -1.0;
            else return 1.0;
        }

    public var direction(get, never): Float;
        function get_direction() {
            if (value > 0.0) return 1.0;
            else if (value < 0.0) return -1.0;
            else return 0.0;
        }

    public var isActive(get, never): Bool;
        function get_isActive() { return magnitude >= deadZone; }

    public var wasActive(default, null) = false;

    public var justActivated(get, never): Bool;
        function get_justActivated() {
            return justCrossedCenter || (isActive && !wasActive);
        }

    public var justDeactivated(get, never): Bool;
        function get_justDeactivated() { return wasActive && !isActive; }

    public var justCrossedCenter(get, never): Bool;
        function get_justCrossedCenter() {
            return (value < 0.0 && valuePrevious >= 0.0)
                || (value > 0.0 && valuePrevious <= 0.0);
        }

    public var activeFrames = 0;

    public function new() {}

    var highStateWasFirst = true;
    public function setValueFromStates(lowState: Bool, highState: Bool) {
        if (highState && !lowState)
            highStateWasFirst = true;
        else if (lowState && !highState)
            highStateWasFirst = false;

        var lowAndHigh = lowState && highState;
        var onlyLow = lowState && !highState;
        var onlyHigh = highState && !lowState;
        if (onlyLow || (lowAndHigh && highStateWasFirst)) {
            value = -1.0;
        }
        else if (onlyHigh || (lowAndHigh && !highStateWasFirst)) {
            value = 1.0;
        }
        else {
            value = 0.0;
        }
        return value;
    }

    public function update() {
        if (justActivated) {
            activeFrames = 0;
        }
        else if (isActive) {
            activeFrames++;
        }
        else {
            activeFrames = 0;
        }

        valuePrevious = value;
        wasActive = isActive;
    }
}
