import hxd.Window;
import hxd.Event;

class KeyboardTracker {
    public var keys = new Map<String, Button>();
    var pendingKeyStates = new Map<String, Bool>();

    public function new(window: Window) {
        // Populate the inverted key name map.
        for (keyCode => keyName in keyCodeNames) {
            keyNameCodes[keyName] = keyCode;
            keys[keyName] = new Button();
            pendingKeyStates[keyName] = false;
        }

        window.addEventTarget(onEvent);
    }

    public function update() {
        // Update all keystates.
        for (keyName in keyCodeNames) {
            keys[keyName].update();
            keys[keyName].isPressed = pendingKeyStates[keyName];
        }
    }

    function onEvent(event: Event) {
        switch(event.kind) {
            case EKeyDown: {
                //trace('DOWN keyCode: ${event.keyCode}, charCode: ${event.charCode}');
                var keyName = keyCodeNames[event.keyCode];
                pendingKeyStates[keyName] = true;
            }
            case EKeyUp: {
                //trace('UP keyCode: ${event.keyCode}, charCode: ${event.charCode}');
                var keyName = keyCodeNames[event.keyCode];
                pendingKeyStates[keyName] = false;
            }
            case _:
        }
    }

    public var keyNameCodes = new Map<String, Int>();
    public var keyCodeNames: Map<Int, String> = [
        1 => "leftMouse",
        2 => "leftRight",
        3 => "controlBreak",
        4 => "middleMouse",
        5 => "mouseX1",
        6 => "mouseX2",
        8 => "backspace",
        9 => "tab",
        12 => "clear",
        13 => "enter",
        16 => "shift",
        17 => "control",
        18 => "alt",
        19 => "pause",
        20 => "capsLock",
        21 => "IMEKana",
        23 => "IMEJunja",
        24 => "IMEFinal",
        25 => "IMEHanja",
        27 => "escape",
        28 => "IMEConvert",
        29 => "IMENonConvert",
        30 => "IMEAccept",
        31 => "IMEModeChange",
        32 => "space",
        33 => "pageUp",
        34 => "pageDown",
        35 => "end",
        36 => "home",
        37 => "leftArrow",
        38 => "upArrow",
        39 => "rightArrow",
        40 => "downArrow",
        41 => "select",
        42 => "print",
        43 => "execute",
        44 => "printScreen",
        45 => "insert",
        46 => "delete",
        47 => "help",
        48 => "0",
        49 => "1",
        50 => "2",
        51 => "3",
        52 => "4",
        53 => "5",
        54 => "6",
        55 => "7",
        56 => "8",
        57 => "9",
        65 => "a",
        66 => "b",
        67 => "c",
        68 => "d",
        69 => "e",
        70 => "f",
        71 => "g",
        72 => "h",
        73 => "i",
        74 => "j",
        75 => "k",
        76 => "l",
        77 => "m",
        78 => "n",
        79 => "o",
        80 => "p",
        81 => "q",
        82 => "r",
        83 => "s",
        84 => "t",
        85 => "u",
        86 => "v",
        87 => "w",
        88 => "x",
        89 => "y",
        90 => "z",
        91 => "leftWindows",
        92 => "rightWindows",
        93 => "applications",
        95 => "sleep",
        96 => "numberPad0",
        97 => "numberPad1",
        98 => "numberPad2",
        99 => "numberPad3",
        100 => "numberPad4",
        101 => "numberPad5",
        102 => "numberPad6",
        103 => "numberPad7",
        104 => "numberPad8",
        105 => "numberPad9",
        106 => "numberPadMultiply",
        107 => "numberPadAdd",
        108 => "numberPadSeparator",
        109 => "numberPadSubtract",
        110 => "numberPadDecimal",
        111 => "numberPadDivide",
        112 => "F1",
        113 => "F2",
        114 => "F3",
        115 => "F4",
        116 => "F5",
        117 => "F6",
        118 => "F7",
        119 => "F8",
        120 => "F9",
        121 => "F10",
        122 => "F11",
        123 => "F12",
        124 => "F13",
        125 => "F14",
        126 => "F15",
        127 => "F16",
        128 => "F17",
        129 => "F18",
        130 => "F20",
        131 => "F21",
        132 => "F22",
        133 => "F23",
        134 => "F24",
        144 => "numLock",
        145 => "scrollLock",
        160 => "leftShift",
        161 => "rightShift",
        162 => "leftControl",
        163 => "rightControl",
        164 => "leftAlt",
        165 => "rightAlt",
        166 => "browserBack",
        167 => "browserForward",
        168 => "browserRefresh",
        169 => "browserStop",
        170 => "browserSearch",
        171 => "browserFavorites",
        172 => "browserHome",
        173 => "browserMute",
        174 => "volumeDown",
        175 => "volumeUp",
        176 => "mediaNextTrack",
        177 => "mediaPreviousTrack",
        178 => "mediaStop",
        179 => "mediaPlay",
        180 => "startMail",
        181 => "mediaSelect",
        182 => "launchApplication1",
        183 => "launchApplication2",
        186 => ";",
        187 => "=",
        188 => ",",
        189 => "-",
        190 => ".",
        191 => "/",
        192 => "`",
        219 => "[",
        220 => "\\",
        221 => "]",
        222 => "'",
        229 => "IMEProcess",
    ];
}
