//
//  SpriteAttributes.swift
//  AiScene
//
//  Created by Max Bilbow on 12/06/2015.
//  Copyright © 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

@available(OSX 10.10, *)
class SpriteAttributes : NSObject {
    var invincible = false
    var sprite: RMXSprite!
        
    var health: Float {
        return Float(self.values[KeyValue.Health]!)!
    }
    
    var values: Dictionary<String,String> = [
        KeyValue.name   : "",
        KeyValue.Health : "100",
        KeyValue.Points : "0",
        KeyValue.Kills  : "0",
        KeyValue.Deaths : "0"
    ]
    
    var keys: [String] {
        return self.values.keys.array
    }
    
    private var _teamID: String = ""
    
    var teamID: String {
        return _teamID
    }
    
    var team: RMXTeam? {
        return self.game?.teams[self.teamID]
    }
    
    var game: RMXTeamGame? {
        return self.sprite.world
    }
    
    var rmxID: Int? {
        return sprite.rmxID
    }
    

    
    func setHealth(health: Float? = nil) {
        self.willChangeValueForKey("health")
        self.values[KeyValue.Health] = String(health ?? self.team?.startingHealth ?? 100)
        self.didChangeValueForKey("health")
    }
    
    
    func reduceHealth(byDividingBy factor: Float) -> Bool {
        if factor > 1 {
            self.willChangeValueForKey("health")
            self.values[KeyValue.Health] = String(self.health / factor)
            self.didChangeValueForKey("health")
            return true
        }
        return false
    }
    
    func reduceHealth(byMultiplyingBy factor: Float) -> Bool {
        if factor < 1 {
            self.willChangeValueForKey("health")
            self.values[KeyValue.Health] = String(self.health * factor)
            self.didChangeValueForKey("health")
            return true
        }
        return false
    }
    
    func reduceHealth(bySubtracting amount: Float) -> Bool{
        if amount > 0 {
            self.willChangeValueForKey("health")
            self.values[KeyValue.Health] = String(self.health - amount)
            self.didChangeValueForKey("health")
            return true
        }
        return false
    }
    

    var points: Int {
        return Int(self.values[KeyValue.Points]!)!
    }
    
    func givePoints(points: Int) -> Bool {
        if points > 0 {
            self.willChangeValueForKey("points")
            self.team?.willChangeValueForKey("points")
            self.values[KeyValue.Points] = String(self.points + points)
            self.team?.score.points += points
            self.didChangeValueForKey("points")
            self.team?.didChangeValueForKey("points")
            return true
        }
        return false
    }
    
    func setPoints(points: Int) {
        if points != self.points {
            self.willChangeValueForKey("points")
            self.values[KeyValue.Points] = String(points)
            self.didChangeValueForKey("points")
        }
    }
    
    var kit: SCNMaterial? {
        return self.isTeamPlayer ? self.sprite.geometry?.firstMaterial : nil
    }
    
    var isTeamCaptain: Bool {
        return self.sprite.rmxID == self.team?.captain?.rmxID
    }
    
    convenience init?(sprite: RMXSprite, coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        self.sprite = sprite
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        for value in aDecoder.dictionaryWithValuesForKeys(self.keys) {
            self.values[value.0] = String(value.1)
        }
    }
    
    init(sprite: RMXSprite){
        self.sprite = sprite //as! RMXSprite // = [ KeyValue.Sprite.rawValue : sprite ]
        super.init()
    }

    
    ///Call this, not the team.addPlayer: function (I think)
    func setTeamID(ID: String) {
        if self.teamID != ID {
            self.willChangeValueForKey("teamID")
            var newID = ID
            if Int(ID) ?? 1 > 0 {
                if self.world.teams[ID] == nil { //create a team in one doesn't exist
                    let newTeam = RMXTeam(gameWorld: self.world, captain: self.sprite, withID: ID)
                    newID = newTeam.id
                    self.world.addTeam(newTeam)
                }
            }
            _teamID = newID
            self.didChangeValueForKey("teamID")
            
            //            return true
        }
        //        return false
        
    }
    
    var world: RMSWorld {
        return self.sprite.world
    }
    
    var isTeamPlayer: Bool {
        return Int(self.teamID) ?? 1 >= 0
    }
    
    
    
    private var _collisionBitMask: Int?
    private var _transparency: CGFloat?
    
    var isAlive: Bool {
        return !(!self._isAlive && self.isTeamPlayer)
    }
    
    var canBeKilled: Bool {
        return !self.invincible && self.isAlive
    }
    private var _isAlive = true
    
    ///could cause animation failure if deRetire() does not fire
    func retire() {
        if self.canBeKilled { // && self.isAlive {
            self.willChangeValueForKey("isAlive")
            
            self._isAlive = false
            //            self.sprite.node.paused = true
            self.sprite.node.opacity = 0.1
            //
            self.sprite.releaseItem()
            self.sprite.node.removeCollisionActions()
            
            self.sprite.tracker.abort()
//            self.registerDeath()
            //            self.sprite.timer.addTimer(interval: 5, target: self, selector: "deRetire", repeats: false)
            self.sprite.node.runAction(SCNAction.fadeOpacityTo(1, duration: 5), completionHandler: { () -> Void in
                self.deRetire()
            })
            self.didChangeValueForKey("isAlive")
            
        }
        
    }
    
    func deRetire() {
        //        if !self._isAlive {
        self.willChangeValueForKey("isAlive")
        self._isAlive = true
        //            self.sprite.node.paused = false
        self.sprite.node.opacity = 1
        self.didChangeValueForKey("isAlive")
        //        }
        
    }
    
//    private var _deathCount: Int = 0
//    private var _killCount: Int = 0
    
    var deathCount: Int {
        return Int(self.values[KeyValue.Deaths]!)!
    }
    
    var killCount: Int {
        return Int(self.values[KeyValue.Kills]!)!
    }
    
    func registerKill() {
        self.team?.willChangeValueForKey("kills")
        self.values[KeyValue.Kills] = String(self.killCount + 1)
        self.team?.score.kills++
        self.team?.didChangeValueForKey("kills")
    }
    
    func registerDeath() {
        self.team?.willChangeValueForKey("deaths")
        self.values[KeyValue.Deaths] = String(self.deathCount + 1)
        self.team?.score.deaths++
        self.team?.didChangeValueForKey("deaths")
    }
    
    
    var score: ScoreCard {
        return (kills: self.killCount, deaths: self.deathCount, points: self.points)
    }
    
    var printScore: String {
        let score = self.score
        return "\(self.sprite.name)'s Score: \(score.points), Kills: \(score.kills), Deaths: \(score.deaths), Health: \(self.health)"
    }
    
}

extension SpriteAttributes : NSCoding {
    func encodeWithCoder(aCoder: NSCoder) {
        
    }
}
