class Button {
    public var isPressed = false;
    public var wasPressed(default, null) = false;

    public var justPressed(get, never): Bool;
    function get_justPressed(): Bool { return isPressed && !wasPressed; }

    public var justReleased(get, never): Bool;
    function get_justReleased(): Bool { return wasPressed && !isPressed; }

    public function new() {}

    public function update(): Void {
        wasPressed = isPressed;
    }
}
