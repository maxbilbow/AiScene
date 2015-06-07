//
//  RMGameKit.swift
//  AiScene
//
//  Created by Max Bilbow on 01/06/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GameKit

class RMXGameManager {
    
    var savedGame: GKSavedGame
    var score: GKScore
    var localPlayer: GKLocalPlayer
    
    init(savedGame: GKSavedGame? = nil) {
        self.savedGame = savedGame ?? GKSavedGame()
        self.localPlayer = GKLocalPlayer()
        self.score = GKScore()
//        self.score = savedGame
        RMLog("\(self.localPlayer.alias)")
        
    }
    
    func gameWon(player: RMXSprite) {
        let foo = GKPlayer()
        foo.playerID
        
    }
    
}