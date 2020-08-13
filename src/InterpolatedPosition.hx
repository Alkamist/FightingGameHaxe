class InterpolatedPosition {
    public var x(get, set) : Float;
    function get_x() { return interpolation * (_xNew - _xOld) + _xOld; }
    function set_x(value) {
        _xOld = _xNew;
        _xNew = value;
        return _xOld;
    };

    public var y(get, set) : Float;
    function get_y() { return interpolation * (_yNew - _yOld) + _yOld; }
    function set_y(value) {
        _yOld = _yNew;
        _yNew = value;
        return _yOld;
    };

    public var interpolation : Float = 0.0;

    var _xOld : Float = 0.0;
    var _xNew : Float = 0.0;
    var _yOld : Float = 0.0;
    var _yNew : Float = 0.0;

    public function new() {}
}
