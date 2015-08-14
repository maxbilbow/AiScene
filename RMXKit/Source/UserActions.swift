//
//  UserActions.swift
//  AiScene
//
//  Created by Max Bilbow on 31/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

public protocol SoundMaker : Hashable { }
public enum UserAction : String, CustomStringConvertible {
    //Movement
    case MOVE = "Move Around"
    case MOVE_FORWARD = "Move Forward"
    case MOVE_BACKWARD = "Move Backward"
    case MOVE_LEFT = "Move Left"
    case MOVE_RIGHT = "Move Right"
    case MOVE_UP  = "Move Up"
    case MOVE_DOWN = "Move Down"
    case ROLL_LEFT = "Roll Left"
    case ROLL_RIGHT = "Roll Right"
    case JUMP = "Jump"
    case ROTATE = "Rotate"
    case LOOK_AROUND = "Look Around"
    case STOP_MOVEMENT = "Stop Moving"
    
    //Interactions
    case GRAB_ITEM = "Grab Item"
    case THROW_ITEM = "Throw Item"
    case THROW_OR_GRAB_TRACKED = "Throw Item tracked/ Grab Item"
    case THROW_OR_GRAB_UNTRACKED = "Throw Item untracked / Grab Item"
    case BOOM = "explode"
    
    //Environmentals
    case TOGGLE_GRAVITY = "Toggle Gravity"
    case TOGGLE_AI = "Toggle AI"
    case RESET = "Reset"
    case RESET_CAMERA = "Reset Camera"
    
    //Interface options
    case LOCK_CURSOR = "Lock Cursor to view"
    case NEXT_CAMERA = "Next Camera"
    case PREV_CAMERA = "Previous Camera"
    case PAUSE_GAME = "Pause Game"
    case UNPAUSE_GAME = "Unpause Game"
    case KEYBOARD_LAYOUT = "Cycle Keyboard Layouts"
    case SHOW_SCORES = "Show Scores"
    case HIDE_SCORES = "Hide Scores"
    case TOGGLE_SCORES = "Show/Hide Scores"
    
    //Misc: generically used for testing
    case GET_INFO = "get info"
    case ZOOM_IN = "Zoom In"
    case ZOOM_OUT = "Zoom Out"
    case ZoomInAnOut = "Zoom In/Zoom Out"
    case INCREASE = "Increase"
    case DECREASE = "Decrease"
    case NEW_GAME = "New Game"
    case DEBUG_NEXT = "Next Debugging Set"
    case DEBUG_PREVIOUS = "Previous Debugging Set"

    case NULL = "NULL"
    
   public var description: String {
        return self.rawValue
    }

    
}

