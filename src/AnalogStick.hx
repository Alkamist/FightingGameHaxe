class AnalogStick {
    public var xAxis = new AnalogAxis();
    public var yAxis = new AnalogAxis();

    public var magnitude(get, set): Float;
        function get_magnitude() {
            return Math.sqrt(Math.pow(xAxis.value, 2.0) + Math.pow(yAxis.value, 2.0));
        }
        function set_magnitude(value: Float) {
            var currentMagnitude = get_magnitude();
            if (currentMagnitude == 0.0) {
                return 0.0;
            }
            else {
                var newMagnitude = Math.min(Math.max(value, -1.0), 1.0);
                var scaleFactor = newMagnitude / currentMagnitude;
                xAxis.value *= scaleFactor;
                yAxis.value *= scaleFactor;
                return newMagnitude;
            }
        }

    public var angle(get, never): Float;
        function get_angle() {
            if (xAxis.value != 0 || yAxis.value != 0) {
                return Math.atan2(yAxis.value, xAxis.value);
            }
            else {
                return 0.0;
            }
        }

    public function new() {}

    public function update() {
        xAxis.update();
        yAxis.update();
    }
}
