class CharacterStateMachine {
    public var character: Character;

    public var state(get, set): String;
        function get_state() { return realState.name; }
        function set_state(newStateName: String) {
            realState.exit();
            stateFrame = 0;
            realStatePrevious = realState;
            realState = realStates[newStateName];
            realState.enter();
            return newStateName;
        }

    public var statePrevious(get, never): String;
        function get_statePrevious() { return realStatePrevious.name; }

    public var stateFrame = 0;

    var realStates = new Map<String, CharacterState>();
    var realState: CharacterState;
    var realStatePrevious: CharacterState;

    public function new(character: Character) {
        this.character = character;

        addState(CharacterState_Idle);
        addState(CharacterState_Turn);
        addState(CharacterState_Walk);
        addState(CharacterState_Dash);
        addState(CharacterState_JumpSquat);
        addState(CharacterState_Airborne);

        realState = realStates["idle"];
        realStatePrevious = realStates["idle"];
    }

    public function update() {
        // Handle transitions.
        for (stateName in realState.transitionOrder) {
            var transitionCondition = realState.transitions[stateName]();
            if (transitionCondition) {
                state = stateName;
                break;
            }
        }

        realState.update();

        stateFrame++;
    }

    function addState(stateType: Class<CharacterState>) {
        var newState = Type.createInstance(stateType, [character]);
        realStates[newState.name] = newState;
    }
}
