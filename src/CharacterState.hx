class CharacterState {
    public var name: String;

    var me: Character;
    var input: ControllerState;

    public function new(character: Character) {
        me = character;
        input = character.input;
    }

    public function enter() {}
    public function update() {}
    public function exit() {}
}
