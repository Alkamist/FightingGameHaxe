import hxd.Pad.PadConfig;

class ControllerReader extends ControllerState {
	public var isConnected : Bool = false;

	var pad : hxd.Pad;
	var padConfig : hxd.PadConfig = hxd.Pad.DEFAULT_CONFIG;

	public function new() {
		super();
		hxd.Pad.wait(onPad);
	}

	override function update() {
		super.update();

		if (isConnected) {
			xAxis.value = pad.values[padConfig.analogX];
			yAxis.value = pad.values[padConfig.analogY];
			cXAxis.value = pad.values[padConfig.ranalogX];
			cYAxis.value = pad.values[padConfig.ranalogY];

			aButton.isPressed = pad.buttons[padConfig.A];
			bButton.isPressed = pad.buttons[padConfig.B];
			xButton.isPressed = pad.buttons[padConfig.X];
			yButton.isPressed = pad.buttons[padConfig.Y];
			zButton.isPressed = pad.buttons[padConfig.RB];

			startButton.isPressed = pad.buttons[padConfig.start];

			dLeftButton.isPressed = pad.buttons[padConfig.dpadLeft];
			dRightButton.isPressed = pad.buttons[padConfig.dpadRight];
			dDownButton.isPressed = pad.buttons[padConfig.dpadDown];
			dUpButton.isPressed = pad.buttons[padConfig.dpadUp];
		}
	}

	function onPad(p : hxd.Pad) {
		if(p.connected) {
			pad = p;
			isConnected = true;

			p.onDisconnect = function() {
				if(!p.connected) {
					isConnected = false;
				}
			}
		}
	}
}
