# AiCubo

v0.6.x now works for both iOS and OSX
v0.4.2 (stable) is available for download: https://github.com/maxbilbow/RMSGameEngine/releases/tag/v0.4.2

TODO:
• Port OpenGLES back to OpenGL using preprocessing flags and moden OpenGL calls
• Add a user interface for toggling options
• Create a user interface for inputing custom behaviours
• Create simplified scipt processor for users to enter behavior scripts

Slowly building physics fromt the ground up.

• Started in C/C++ at uni (2007)

• Re-coded in C++ (Vesion: OpenGL 2.0)

• Translated into Objective-C for use on iOS (Version: RattleGL 3.3 https://www.youtube.com/watch?v=Wz75gmL7uVQ)

• Translated into Swift for better performance alround (Version 4.1)

Controls:
```Swift

///Key down, Key up options
    static let ON_KEY_DOWN: (on:RMFloat,off:RMFloat) = (1,0)
    static let ON_KEY_UP: (on:RMFloat,off:RMFloat) = (0,1)
    static let MOVE_SPEED: (on:RMFloat,off:RMFloat) = (RMXInterface.moveSpeed * 2, 0)
    static let LOOK_SPEED: (on:RMFloat,off:RMFloat) = (RMXInterface.lookSpeed * 10, 0)
    
    ///Key settings
    lazy var keys: [ RMKey ] = [
        RMKey(self, action: "information", characters: "i", isRepeating: false,speed: ON_KEY_DOWN),
        RMKey(self, action: "forward", characters: "w", speed: MOVE_SPEED),
        RMKey(self, action: "back", characters: "s", speed: MOVE_SPEED),
        RMKey(self, action: "left", characters: "a", speed: MOVE_SPEED),
        RMKey(self, action: "right", characters: "d", speed: MOVE_SPEED),
        RMKey(self, action: "up", characters: "e", speed: MOVE_SPEED),
        RMKey(self, action: "down", characters: "q", speed: MOVE_SPEED),
        RMKey(self, action: "rollLeft", characters: "z", speed: LOOK_SPEED),
        RMKey(self, action: "rollRight", characters: "x", speed: LOOK_SPEED),
        RMKey(self, action: "jump", characters: " "),
        RMKey(self, action: "toggleGravity", characters: "g", isRepeating: false,speed: ON_KEY_UP),
        RMKey(self, action: "toggleAllGravity", characters: "G", isRepeating: false,speed: ON_KEY_UP),
        RMKey(self, action: "reset", characters: "R", isRepeating: false,speed: ON_KEY_UP),
        RMKey(self, action: "look", characters: "mouseMoved", isRepeating: false,speed: (0.01,0)),
        RMKey(self, action: "lockMouse", characters: "m", isRepeating: false, speed: ON_KEY_UP),//,
        RMKey(self, action: "grab", characters: "Mouse 1", isRepeating: false, speed: ON_KEY_UP),
        RMKey(self, action: "throw", characters: "Mouse 2", isRepeating: false,  speed: (0,20)),
        
        RMKey(self, action: "increase", characters: "=", isRepeating: false, speed: ON_KEY_DOWN),
        RMKey(self, action: "decrease", characters: "-", isRepeating: false, speed: ON_KEY_DOWN), //generically used for testing
        RMKey(self, action: "nextCamera", characters: ".", isRepeating: false, speed: ON_KEY_DOWN),
        RMKey(self, action: "previousCamera", characters: ",", isRepeating: false, speed: ON_KEY_DOWN)
    ]

   
    
  ```
