class InterpolatedPosition {
    public var x(get, set): Float;
    function get_x(): Float { return interpolation * (xNew - xOld) + xOld; }
    function set_x(value): Float {
        xOld = xNew;
        xNew = value;
        return xOld;
    };

    public var y(get, set): Float;
    function get_y(): Float { return interpolation * (yNew - yOld) + yOld; }
    function set_y(value): Float {
        yOld = yNew;
        yNew = value;
        return yOld;
    };

    public var interpolation = 0.0;

    var xOld = 0.0;
    var xNew = 0.0;
    var yOld = 0.0;
    var yNew = 0.0;

    public function new() {}
}
