class AnalogAxis {
    public var value : Float = 0.0;
    public var valuePrevious : Float = 0.0;
    public var deadZone : Float = 0.2875;
    public var activeFrames(default, null) : Int = 0;

    public var magnitude(get, never) : Float;
    function get_magnitude() {
        if (value < 0.0) return -value;
        return value;
    }

    public var sign(get, never) : Float;
    function get_sign() {
        if (value < 0.0) return -1.0;
        return 1.0;
    }

    public var normalizedValue : Float;
    function get_normalizedValue() {
        if (value > 0.0) return 1.0;
        if (value < 0.0) return -1.0;
        return value;
    }

    public var isActive(get, never) : Bool;
    function get_isActive() return magnitude >= deadZone;

    public var wasActive(default, null) : Bool = false;

    public var justActivated(get, never) : Bool;
    function get_justActivated() return isActive && !wasActive;

    public var justDeactivated(get, never) : Bool;
    function get_justDeactivated() return wasActive && !isActive;

    public var justCrossedCenter(get, never) : Bool;
    function get_justCrossedCenter() {
        return (value < 0.0 && valuePrevious >= 0.0)
            || (value > 0.0 && valuePrevious <= 0.0);
    }

    public function new() {}

    public function update() {
        valuePrevious = value;
        wasActive = isActive;
        if (isActive) {
            activeFrames++;
        }
        else {
            activeFrames = 0;
        }
    }
}