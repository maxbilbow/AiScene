//
//  RMGameKit.swift
//  AiScene
//
//  Created by Max Bilbow on 01/06/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GameKit

@available(OSX 10.10, *)
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
    
    func gameWon(player: RMXNode) {
        let foo = GKPlayer()
        foo.playerID
        
    }
    
}