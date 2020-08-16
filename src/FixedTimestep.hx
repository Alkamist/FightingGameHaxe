class FixedTimestep {
    public var physicsFps = 60.0;
    public var physicsFraction = 0.0;
    public var physicsDelta(get, never): Float;
        function get_physicsDelta() { return 1.0 / physicsFps; }

    public var displayFps = 144.0;
    public var displayDelta = 0.0;

    var accumulator = 0.0;
    var elapsedTime = 0.0;

    public function new() {}

    public function update(delta: Float, updateFunction: () -> Void) {
        displayDelta = delta;
        elapsedTime += delta;
        accumulator += delta;
        while (accumulator >= physicsDelta) {
            updateFunction();
            accumulator -= physicsDelta;
        }
        physicsFraction = accumulator / physicsDelta;
    }
}
