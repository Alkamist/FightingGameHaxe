class FixedTimestep {
    public var physicsFps : Float = 60.0;
    public var physicsFraction : Float = 0.0;
    public var physicsDelta(get, never) : Float; inline function get_physicsDelta() return 1.0 / physicsFps;
    public var displayFps : Float = 144.0;
    public var displayDelta : Float = 0.0;

    var accumulator : Float = 0.0;
    var elapsedTime : Float = 0.0;

    public function new() {}

    public function update(delta : Float, updateFunction) {
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
