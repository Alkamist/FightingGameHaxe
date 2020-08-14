class ControllerState {
    public var leftStick = new AnalogStick();
    public var cStick = new AnalogStick();
    public var xAxis: AnalogAxis;
    public var yAxis: AnalogAxis;
    public var cXAxis: AnalogAxis;
    public var cYAxis: AnalogAxis;
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

    public function new() {
        xAxis = leftStick.xAxis;
        yAxis = leftStick.yAxis;
        cXAxis = cStick.xAxis;
        cYAxis = cStick.yAxis;
    }

    public function update(): Void {
        leftStick.update();
        cStick.update();
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
