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

    public function new() {}

    public function update() {
        xAxis.update();
        yAxis.update();
    }
}
