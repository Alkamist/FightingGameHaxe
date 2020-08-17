class CharacterState {
    public var name: String;
    public var transitions: Map<String, () -> Bool> = [];
    public var transitionOrder: Array<String> = [];

    var me: Character;
    var input: ControllerState;

    public function new(character: Character) {
        me = character;
        input = character.input;
    }

    public function enter() {}
    public function update() {}
    public function exit() {}

    public function addTransition(toState: String, conditionFn: () -> Bool) {
        transitionOrder.push(toState);
        transitions[toState] = conditionFn;
    }
}
