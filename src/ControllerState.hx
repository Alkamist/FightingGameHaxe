class ControllerState {
    public var xAxis = new AnalogAxis();
    public var yAxis = new AnalogAxis();
    public var cXAxis = new AnalogAxis();
    public var cYAxis = new AnalogAxis();
    public var aButton = new Button();
    public var bButton = new Button();
    public var xButton = new Button();
    public var yButton = new Button();
    public var zButton = new Button();
    public var lButton = new Button();
    public var rButton = new Button();
    public var startButton = new Button();
    public var dLeftButton = new Button();
    public var dRightButton = new Button();
    public var dDownButton = new Button();
    public var dUpButton = new Button();
    //public var lAnalog : AnalogSlider;
    //public var rAnalog : AnalogSlider;

    public function new() {}

    public function update(): Void {
        xAxis.update();
        yAxis.update();
        cXAxis.update();
        cYAxis.update();
        aButton.update();
        bButton.update();
        xButton.update();
        yButton.update();
        zButton.update();
        lButton.update();
        rButton.update();
        startButton.update();
        dLeftButton.update();
        dRightButton.update();
        dDownButton.update();
        dUpButton.update();
        //lAnalog.update();
        //rAnalog.update();
    }
}
