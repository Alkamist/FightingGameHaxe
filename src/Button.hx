class Button {
    public var isPressed : Bool = false;
    public var wasPressed(default, null) : Bool = false;

    public var justPressed(get, never) : Bool;
    function get_justPressed() return isPressed && !wasPressed;

    public var justReleased(get, never) : Bool;
    function get_justReleased() return wasPressed && !isPressed;

    public function new() {}

    public function update() {
        wasPressed = isPressed;
    }
}
