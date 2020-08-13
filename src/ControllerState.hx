class ControllerState {
    public var xAxis : AnalogAxis = new AnalogAxis();
    public var yAxis : AnalogAxis = new AnalogAxis();
    public var cXAxis : AnalogAxis = new AnalogAxis();
    public var cYAxis : AnalogAxis = new AnalogAxis();
    public var aButton : Button = new Button();
    public var bButton : Button = new Button();
    public var xButton : Button = new Button();
    public var yButton : Button = new Button();
    public var zButton : Button = new Button();
    public var lButton : Button = new Button();
    public var rButton : Button = new Button();
    public var startButton : Button = new Button();
    public var dLeftButton : Button = new Button();
    public var dRightButton : Button = new Button();
    public var dDownButton : Button = new Button();
    public var dUpButton : Button = new Button();
    //public var lAnalog : AnalogSlider;
    //public var rAnalog : AnalogSlider;

    public function new() {}

    public function update() {
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
