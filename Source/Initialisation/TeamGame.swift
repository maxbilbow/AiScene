//
//  TeamGame.swift
//  AiScene
//
//  Created by Max Bilbow on 28/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

import SceneKit

typealias Challenge = (SpriteAttributes, SpriteAttributes) -> RMXTeam.ChallengeOutcome
typealias WinLogic = (Any? ...) -> Bool

protocol RMXTeamGame  {
    var interface: RMXInterface { get }
    var players: Array<RMXSprite> { get }
    var teamPlayers: Array<RMXSprite> { get }
    var nonPlayers: Array<RMXSprite> { get }
    var nonTeamPlayers: Array<RMXSprite> { get }
    func getTeam(#id: String) -> RMXTeam?
    func getTeamRoster(forTeam team: RMXTeam?) -> Array<RMXSprite>
    var winningTeam: RMXTeam? { get }
    func addTeam(team: RMXTeam)
    var teams: Dictionary<String, RMXTeam> { get }
    func updateTeam(team: RMXTeam) -> RMXTeam?
}

protocol RMXTeamMember {
    var attributes: SpriteAttributes! { get }
}


extension RMSWorld : RMXTeamGame {
    

    
    var teamScores: [String] {
        var scores = Array<String>()
        for team in self._teams {
            scores.append(team.1.print)
        }
        return scores
    }
    
    var teams:Dictionary<String ,RMXTeam> {
        return self._teams
    }
    
    func addTeam(team: RMXTeam) {
        //team.addObserver(self, forKeyPath: "score", options: NSKeyValueObservingOptions.New, context: UnsafeMutablePointer<Void>())
        self._teams[team.id] = team
    }
    
    func removeTeam(teamID: String) -> RMXTeam? {
        //self._teams[teamID]?.removeObserver(self, forKeyPath: "score")
        return self._teams.removeValueForKey(teamID)
    }
    
    func updateTeam(team: RMXTeam) -> RMXTeam? {
        if self._teams[team.id] == nil {
            //team.addObserver(self, forKeyPath: "score", options: NSKeyValueObservingOptions.New, context: UnsafeMutablePointer<Void>())
        }
        RMLog("WARNING:  observer should be removed if switching teams - however this shouln't happend for unique team id", id: "")
        return self._teams.updateValue(team, forKey: team.id)
    }

    
    func getTeam(#id: String) -> RMXTeam? {
        return self._teams[id]
    }
    
    
    func getTeamRoster(forTeam team: RMXTeam?) -> Array<RMXSprite> {
        return self.children.filter({ (child: RMXSprite) -> Bool in
            return child.attributes.teamID == team?.id
        })
    }
    
    /// Team IDs must be > 0. I.e. payer is assigned to a team
    var teamPlayers: Array<RMXSprite> {
        return self.children.filter( { (child: RMXSprite) -> Bool in
            return child.attributes.teamID.toInt() ?? 1 > 0 && child.isPlayerOrAi
        })
    }
    
    var liveTeamPlayers: Array<RMXSprite> {
        return self.children.filter( { (child: RMXSprite) -> Bool in
            return child.attributes.teamID.toInt() ?? 1 > 0 && child.isPlayerOrAi && child.attributes.isAlive
        })
    }
    
    ///Players not assigend to a team (i.e. teamID == 0 )
    var nonTeamPlayers: Array<RMXSprite> {
        return self.children.filter( { (child: RMXSprite) -> Bool in
            return child.isPlayerOrAi //&& child.attributes.teamID == 0
        })
    }
    
    
    
    var players: Array<RMXSprite> {
        return self.children.filter( { (child: RMXSprite) -> Bool in
            return child.isPlayerOrAi
        })
    }
    
    var nonPlayers: Array<RMXSprite> {
        return self.children.filter({ (child: RMXSprite) -> Bool in
            return !child.isPlayerOrAi
        })
    }
    
    var winningTeam: RMXTeam? {
        var winningTeam: RMXTeam?
        for team in self.teams {
            if !team.1.isRetired {
                if winningTeam == nil {
                    winningTeam = team.1
                } else {
                    return nil
                }
            }
        }
        return winningTeam
    }
}



class SpriteAttributes : NSObject {
    var invincible = false
    var sprite: RMXSprite
    
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
    
    var health: Int = 100


    var points: Int = 0
    
    var kit: SCNMaterial? {
        return self.isTeamPlayer ? self.sprite.geometry?.firstMaterial : nil
    }
    
    var isTeamCaptain: Bool {
        return self.sprite.rmxID == self.team?.captain?.rmxID
    }
    
    init(_ sprite: RMXSprite){
        self.sprite = sprite
        super.init()
    }
    
    ///Call this, not the team.addPlayer: function (I think)
    func setTeamID(ID: String) {
        if self.teamID != ID {
            self.willChangeValueForKey("teamID")
            var newID = ID
            if ID.toInt() ?? 1 > 0 {
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
        return self.teamID.toInt() ?? 1 >= 0
    }
    
    
    
    private var _collisionBitMask: Int?
    private var _transparency: CGFloat?
    
    var isAlive: Bool {
        if self.teamID.toInt() ?? 1 < 0 {
            return true
        } else {
            return self._isAlive
        }
    }
    
    private var _isAlive = true
    func retire() {
        if !self.invincible { // && self.isAlive {
            self.willChangeValueForKey("isAlive")

            self._isAlive = false
            self.sprite.node.opacity = 0.1
            //
            self.sprite.releaseItem()
            self.sprite.node.removeCollisionActions()
            self.sprite.followers.removeAll(keepCapacity: true)
            self.sprite.tracker.abort()
            self.die()
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
            self.sprite.node.opacity = 1
            self.didChangeValueForKey("isAlive")
//        }
        
    }
    
    private var _deathCount: Int = 0
    private var _killCount: Int = 0
    
    var deathCount: Int {
        return _deathCount
    }
    
    var killCount: Int {
        return _killCount
    }
    
    private func kill() {
        _killCount++
    }
    private func die() {
        _deathCount++
    }
    
    
    var score: ScoreCard {
        return (kills: self.killCount, deaths: self.deathCount, points: self.points, health: self.health)
    }
    
    var printScore: String {
        let score = self.score
        return "PLAYER SCORE: \(score.points), KILLS: \(score.kills), DEATHS: \(score.deaths), HEALTH: \(score.health)"
    }

}

typealias ScoreCard = (kills: Int, deaths: Int, points: Int, health: Int)
class RMXTeam : NSObject, RMXObject {
    var name: String? {
        return self.id
    }
    var rmxID: Int?
    var uniqueID: String? {
        return self.id
    }
    static var COUNT: Int = 0
    lazy var id: String = "\(++COUNT)" //first team is 1
    var kit: SCNMaterial? {
        return self.captain?.kit
    }
    
    var startingHealth = 100
    
    var score: ScoreCard {
        var score: ScoreCard = (kills: 0, deaths: 0, points: 0, health: 0)
        let team = self.players
        for player in team {
            score.kills  += player.attributes.killCount
            score.deaths += player.attributes.deathCount
            score.points += player.attributes.points
            score.health += player.attributes.health
        }
        return score
    }
    
    var game: RMXTeamGame
    
    var isRetired: Bool = false
    
    var players: Array<RMXSprite> {
        return self.game.getTeamRoster(forTeam: self)
    }
    
    var captain: SpriteAttributes?
    
    init(gameWorld game: RMXTeamGame, captain: RMXSprite? = nil, var withID: AnyObject? = nil){
        self.game = game
        
        super.init()
        if let id: AnyObject = withID {
            var newID: String = ""
            while game.teams["\(id)"] != nil {
                newID = "\(id)-\(++RMXTeam.COUNT)"
            }
            self.id = newID
        }
        
        game.addTeam(self)
        if let captain = captain {
            self.addPlayer(captain)
        }
        

    }
    
    ///call this if there is a new captain and/or the kit has changed
    func update() {
        RMXTeam.updateTeam(self)
    }
    
    func addPlayer(player: RMXSprite) -> Bool{
//    NSLog("name: \(player.name), team: \(player.attributes.teamID)")
        
        if player.attributes.teamID.toInt() ?? 1 < 0 { ///Actually this might be OK (capture the flag for example)
            RMLog("Warning: \(player.name!), with teamID: \(player.attributes.teamID), was not assigned a new team?")
            return false
        }
        var players = self.players.count
        if player.attributes.teamID != self.id { //will we get a new player?
            player.attributes.setTeamID(self.id)
            if let captain = self.captain { //do we have a captain?
                RMXTeam.setColor(self.kit, receiver: player.attributes)
            } else { //otherwise assign new player as captain and update team
                self.captain = player.attributes
                RMXTeam.setColor(RMXTeam.color(self.id), receiver: player.attributes)
                self.update()
            }
            if player.attributes.health < self.startingHealth {
                player.attributes.willChangeValueForKey("health")
                player.attributes.health = self.startingHealth
                player.attributes.didChangeValueForKey("health")
            }
            return true
        } else {
            return false
        }
//        return true //players < self.players?.count ?? 0

    }
    
    private static func color(id: String) -> RMColor {
        switch id {
        case "0":
            return RMColor.blackColor()
        case "1":
            return RMColor.redColor()
        case "2":
            return RMColor.brownColor()
        case "3":
            return RMColor.greenColor()
        case "4":
            return RMColor.blueColor()
        default:
            return RMXArt.randomNSColor()
        }
    }
    
    func retire() {
        if RMXTeam.isGameWon(self.game) {
            self.isRetired = true
            self.game.interface.pauseGame(self)
        }
    }
    
    class func updateTeam(team: RMXTeam?) {
        if let players = team?.players {
            for player in players {
                RMXTeam.setColor(team?.kit, receiver: player.attributes)
            }
        }
    }
    
//    private class func retireIf(defender: SpriteAttributes) -> Bool {
//        return defender.isTeamCaptain && defender.team!.players.count <= 1
//    }
    
    
    
    private class func setColor(color: RMColor, receiver: SpriteAttributes) {
        if let receiver = receiver.kit {
            receiver.diffuse.contents = color
            receiver.specular.contents = color
            receiver.ambient.contents = color
//            receiver.emission.contents = nil
        }
    }
    
    class func setColor(sender: SCNMaterial?, receiver: SpriteAttributes) {
        if let from = sender {
            if let to = receiver.kit {
                to.diffuse.contents = from.diffuse.contents
                to.specular.contents = from.specular.contents
                to.ambient.contents = from.ambient.contents
                to.emission.contents = from.emission.contents
            }
        }
    }
    
    /// doOnWin returns true if defender is totally defeated
    class func challenge(attacker: SpriteAttributes, defender: SpriteAttributes?, doOnWin: Challenge?) {
        if let defender = defender {
            if attacker.teamID == defender.teamID || defender.teamID.toInt() ?? 1 <= 0 { return }
            if defender.isAlive  {
                switch doOnWin?(attacker,defender) ?? challengeWon(attacker, defender: defender) {
                case .DefenderWasKilled:
                    attacker.team?.addPlayer(defender.sprite)
                    defender.retire()
                    break
                default:
                    break
                }
            }
        }
//        NSLog(attacker.points.toData())
    }
    
//    private class func doAfterChallengeWon(attacker: SpriteAttributes, defender: SpriteAttributes) -> Void {
//        self.convert(defender, toTeam: attacker.team)
//    }
    
    enum ChallengeOutcome { case DefenderWasKilled, DefenderAlreadyDead, DefenderWasNotKilled}
    class func challengeWon(attacker: SpriteAttributes, defender: SpriteAttributes) -> ChallengeOutcome {
        if !defender.isAlive { return .DefenderAlreadyDead }
        attacker.willChangeValueForKey("points")
        defender.willChangeValueForKey("health")
        var health = defender.health
        defender.health -= 20
        attacker.points += health - defender.health
        if defender.health <= 0 {
//            self.convert(defender, toTeam: attacker.team)
            defender.die()
            attacker.kill()
            attacker.points += defender.points
            attacker.didChangeValueForKey("points")
            defender.didChangeValueForKey("health")
            return .DefenderWasKilled
        }
        attacker.didChangeValueForKey("points")
        defender.didChangeValueForKey("health")
        return .DefenderWasNotKilled
    }
    
    class func isGameWon(game: RMXTeamGame?) -> Bool {
        return game?.winningTeam != nil
    }
    
    var print: String {
        return "TEAM-\(self.id) SCORE: \(self.score.points), KILLS: \(self.score.kills), DEATHS: \(self.score.deaths), PLAYERS: \(self.players.count)"
    }
    
    class func indirectChallenge(attacker: SpriteAttributes, defender: SpriteAttributes) -> ChallengeOutcome {
        if !defender.isAlive { return .DefenderAlreadyDead }
        attacker.willChangeValueForKey("points")
        defender.willChangeValueForKey("health")
        var health = defender.health
        if defender.health > 0 { defender.health -= 10 }
        attacker.points += health - defender.health
        if defender.health <= 0 {
            defender.die()
            attacker.kill()
            attacker.points += defender.points
            attacker.didChangeValueForKey("points")
            defender.didChangeValueForKey("health")
            return .DefenderWasKilled
        }
        attacker.didChangeValueForKey("points")
        defender.didChangeValueForKey("health")
        return .DefenderWasNotKilled
    }
    
    
    class func throwChallenge(challenger: RMXSprite, projectile: RMXSprite)  {
        func _challenge(contact: SCNPhysicsContact) -> Void {
            if let defender = contact.getDefender(forChallenger: challenger).sprite {
                if defender.willCollide ?? false && defender.attributes.teamID != challenger.attributes.teamID {
                    RMXTeam.challenge(challenger.attributes, defender: defender.attributes, doOnWin: self.indirectChallenge)
                    RMXTeam.challenge(challenger.attributes, defender: projectile.attributes, doOnWin: self.indirectChallenge)
//                    NSLog("I (\(challenger.name)) Smashed up, \(defender.name)")
                    challenger.world.interface.av.playSound(UserAction.THROW_ITEM.rawValue, info: defender)
                    projectile.tracker.abort()
                }
            }
        }
        projectile.node.addCollisionAction(named: "Attack", removeAfterTime: 2, action: _challenge)
        
    }
    
}
