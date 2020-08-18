import hxd.Pad;

class Gamepad extends ControllerState {
	public var heapsPad: Pad;
	public var heapsPadConfig = Pad.DEFAULT_CONFIG;

	public var axisScale = 1.6;
	public var xAxisCalibration = 0.0;
	public var yAxisCalibration = 0.0;
	public var cXAxisCalibration = 0.0;
	public var cYAxisCalibration = 0.0;

	public function new(heapsPad: Pad) {
		super();
		this.heapsPad = heapsPad;

		//calibrate();
	}

	//public function calibrate() {
	//	xAxisCalibration = safeAnalogValue(heapsPad.values[heapsPadConfig.analogX]);
	//	yAxisCalibration = safeAnalogValue(heapsPad.values[heapsPadConfig.analogY]);
	//	cXAxisCalibration = safeAnalogValue(heapsPad.values[heapsPadConfig.ranalogX]);
	//	cYAxisCalibration = safeAnalogValue(heapsPad.values[heapsPadConfig.ranalogY]);
	//}

	override function update() {
		super.update();

		xAxis.value = calibratedValue(heapsPad.values[heapsPadConfig.analogX], xAxisCalibration);
		yAxis.value = calibratedValue(heapsPad.values[heapsPadConfig.analogY], yAxisCalibration);
		cXAxis.value = calibratedValue(heapsPad.values[heapsPadConfig.ranalogX], cXAxisCalibration);
		cYAxis.value = calibratedValue(heapsPad.values[heapsPadConfig.ranalogY], cYAxisCalibration);

		aButton.isPressed = heapsPad.buttons[heapsPadConfig.A];
		bButton.isPressed = heapsPad.buttons[heapsPadConfig.B];
		xButton.isPressed = heapsPad.buttons[heapsPadConfig.X];
		yButton.isPressed = heapsPad.buttons[heapsPadConfig.Y];
		zButton.isPressed = heapsPad.buttons[heapsPadConfig.RB];
		lButton.isPressed = heapsPad.buttons[heapsPadConfig.LB];
		rButton.isPressed = heapsPad.buttons[heapsPadConfig.ranalogClick];

		startButton.isPressed = heapsPad.buttons[heapsPadConfig.start];

		dLeftButton.isPressed = heapsPad.buttons[heapsPadConfig.dpadLeft];
		dRightButton.isPressed = heapsPad.buttons[heapsPadConfig.dpadRight];
		dDownButton.isPressed = heapsPad.buttons[heapsPadConfig.dpadDown];
		dUpButton.isPressed = heapsPad.buttons[heapsPadConfig.dpadUp];

		xAxis.value = Math.min(Math.max(xAxis.value * axisScale, -1.0), 1.0);
		yAxis.value = Math.min(Math.max(yAxis.value * axisScale, -1.0), 1.0);

		convertToMeleeValues();
	}

	function calibratedValue(value: Float, calibration: Float) {
		//var centeredValue = safeAnalogValue(value) - calibration;
		//if (centeredValue >= 0.0) {
		//	centeredValue *= Math.abs(1.0 - calibration);
		//}
		//else {
		//	centeredValue *= Math.abs(-1.0 - calibration);
		//}
		//return centeredValue;
		return value;
	}

	function safeAnalogValue(value: Float) {
		if (Math.isNaN(value)) return 0.0;
		return value;
	}
}
