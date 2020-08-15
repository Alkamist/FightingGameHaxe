import hxd.Window;
import hxd.Event;

class KeyboardController extends ControllerState {
    //var keyCodes: Map<String, String>;

    public function new(window: Window) {
        super();
        window.addEventTarget(onEvent);
    }

    override public function update(): Void {
        super.update();

        //if (Key.isDown(Key.))
    }

    function onEvent(event: Event) {
        switch(event.kind) {
            case EKeyDown: trace('DOWN keyCode: ${event.keyCode}, charCode: ${event.charCode}');
            case EKeyUp: trace('UP keyCode: ${event.keyCode}, charCode: ${event.charCode}');
            case _:
        }
    }
}
