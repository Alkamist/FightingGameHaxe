class GamepadManager {
	public var gamepads: Array<Gamepad> = [];

	public function new() {
		hxd.Pad.wait(onGamepadActivate);
	}

	public function update(): Void {
		for (gamepad in gamepads) {
			gamepad.update();
		}
	}

	function onGamepadActivate(heapsPad: hxd.Pad): Void {
		if(heapsPad.connected) {
			var gamepad = new Gamepad(heapsPad);
			gamepads.push(gamepad);
			heapsPad.onDisconnect = function() {
				if(!heapsPad.connected) {
					gamepads.remove(gamepad);
				}
			}
		}
	}
}
