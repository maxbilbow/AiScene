//
//  UserActions.swift
//  AiScene
//
//  Created by Max Bilbow on 31/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

public enum UserAction : RMInputKeyValue {
    //Movement
    case MOVE, MOVE_FORWARD, MOVE_BACKWARD, MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN, ROLL_LEFT, ROLL_RIGHT, JUMP, ROTATE, LOOK, STOP_MOVEMENT
    
    //Interactions
    case GRAB_ITEM, THROW_ITEM, BOOM
    
    //Environmentals
    case TOGGLE_GRAVITY, TOGGLE_AI, RESET, RESET_CAMERA
    
    //Interface options
    case LOCK_CURSOR, NEXT_CAMERA, PREV_CAMERA, PAUSE_GAME, UNPAUSE_GAME, KEYBOARD_LAYOUT, SHOW_SCORES, HIDE_SCORES, TOGGLE_SCORES
    
    //Misc: generically used for testing
    case GET_INFO
    case ZOOM_IN
    case ZOOM_OUT
    case INCREASE
    case DECREASE
    case NEW_GAME
    case DEBUG_NEXT, DEBUG_PREVIOUS
    
    
}


