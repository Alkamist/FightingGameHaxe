class AnalogAxis {
    public var value(default, set) = 0.0;
    function set_value(input: Float): Float {
        return value = Math.min(Math.max(input, -1.0), 1.0);
    }

    public var valuePrevious(default, null) = 0.0;
    public var deadZone = 0.2875;

    public var magnitude(get, never): Float;
    function get_magnitude(): Float {
        if (value < 0.0) return -value;
        else return value;
    }

    public var sign(get, never): Float;
    function get_sign(): Float {
        if (value < 0.0) return -1.0;
        else return 1.0;
    }

    public var normalizedValue: Float;
    function get_normalizedValue(): Float {
        if (value > 0.0) return 1.0;
        if (value < 0.0) return -1.0;
        else return value;
    }

    public var isActive(get, never): Bool;
    function get_isActive(): Bool { return magnitude >= deadZone; }

    public var wasActive(default, null) = false;

    public var justActivated(get, never): Bool;
    function get_justActivated(): Bool {
        return justCrossedCenter || (isActive && !wasActive);
    }

    public var justDeactivated(get, never): Bool;
    function get_justDeactivated(): Bool { return wasActive && !isActive; }

    public var justCrossedCenter(get, never): Bool;
    function get_justCrossedCenter(): Bool {
        return (value < 0.0 && valuePrevious >= 0.0)
            || (value > 0.0 && valuePrevious <= 0.0);
    }

    public function new() {}

    public function update(): Void {
        valuePrevious = value;
        wasActive = isActive;
    }
}