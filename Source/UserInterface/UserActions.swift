//
//  UserActions.swift
//  AiScene
//
//  Created by Max Bilbow on 31/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

enum UserAction {
    //Movement
    case MOVE_FORWARD, MOVE_BACKWARD, MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN, ROLL_LEFT, ROLL_RIGHT, JUMP, ROTATE
    
    //Interactions
    case GRAB_ITEM, THROW_ITEM, BOOM
    
    //Environmentals
    case TOGGLE_GRAVITY, TOGGLE_AI, RESET
    
    //Interface options
    case LOCK_CURSOR, NEXT_CAMERA, PREV_CAMERA, PAUSE_GAME, KEYBOARD_LAYOUT, SHOW_SCORE
    
    //Misc: generically used for testing
    case GET_INFO
    case ZOOM_IN
    case ZOOM_OUT
    case INCREASE
    case DECREASE
    
    //Non-ASCKI commands
    case MOVE_CURSOR_PASSIVE
    case LEFT_CLICK
    case RIGHT_CLICK
    
}