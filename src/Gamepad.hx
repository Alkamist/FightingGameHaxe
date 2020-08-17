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

		// vJoy analog axes seem to return NaN for some reason.
		//if (StringTools.contains(heapsPad.name.toLowerCase(), "vjoy")) {
		//	heapsPadConfig.A = 0;
		//	heapsPadConfig.B = 1;
		//	heapsPadConfig.X = 2;
		//	heapsPadConfig.Y = 3;
		//	heapsPadConfig.RB = 4;
		//	heapsPadConfig.start = 7;
		//	heapsPadConfig.dpadLeft = 10;
		//	heapsPadConfig.dpadRight = 11;
		//	heapsPadConfig.dpadDown = 9;
		//	heapsPadConfig.dpadUp = 8;
		//}

		calibrate();
	}

	public function calibrate() {
		xAxisCalibration = safeAnalogValue(heapsPad.values[heapsPadConfig.analogX]);
		yAxisCalibration = safeAnalogValue(heapsPad.values[heapsPadConfig.analogY]);
		cXAxisCalibration = safeAnalogValue(heapsPad.values[heapsPadConfig.ranalogX]);
		cYAxisCalibration = safeAnalogValue(heapsPad.values[heapsPadConfig.ranalogY]);
	}

	override function update() {
		super.update();

		xAxis.value = convertAxisValue(heapsPad.values[heapsPadConfig.analogX], xAxisCalibration);
		yAxis.value = convertAxisValue(heapsPad.values[heapsPadConfig.analogY], yAxisCalibration);
		cXAxis.value = convertAxisValue(heapsPad.values[heapsPadConfig.ranalogX], cXAxisCalibration);
		cYAxis.value = convertAxisValue(heapsPad.values[heapsPadConfig.ranalogY], cYAxisCalibration);

		aButton.isPressed = heapsPad.buttons[heapsPadConfig.A];
		bButton.isPressed = heapsPad.buttons[heapsPadConfig.B];
		xButton.isPressed = heapsPad.buttons[heapsPadConfig.X];
		yButton.isPressed = heapsPad.buttons[heapsPadConfig.Y];
		zButton.isPressed = heapsPad.buttons[heapsPadConfig.RB];

		startButton.isPressed = heapsPad.buttons[heapsPadConfig.start];

		dLeftButton.isPressed = heapsPad.buttons[heapsPadConfig.dpadLeft];
		dRightButton.isPressed = heapsPad.buttons[heapsPadConfig.dpadRight];
		dDownButton.isPressed = heapsPad.buttons[heapsPadConfig.dpadDown];
		dUpButton.isPressed = heapsPad.buttons[heapsPadConfig.dpadUp];

		clampStickMagnitudes(1.0);
	}

	function convertAxisValue(value: Float, calibration: Float) {
		var calibratedValue = safeAnalogValue(value) - calibration;
		var scaledValue = calibratedValue * axisScale;
		//var calibratedValue = scaledValue - calibration;
		//if (scaledValue >= 0.0) {
		//	calibratedValue *= Math.abs(1.0 - calibration);
		//}
		//else {
		//	calibratedValue *= Math.abs(-1.0 - calibration);
		//}
		return scaledValue;
	}

	function safeAnalogValue(value: Float) {
		if (Math.isNaN(value)) return 0.0;
		return value;
	}
}
