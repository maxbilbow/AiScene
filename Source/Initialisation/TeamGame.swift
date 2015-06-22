//
//  TeamGame.swift
//  AiScene
//
//  Created by Max Bilbow on 28/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import RMXKit
import SceneKit

@available(OSX 10.10, *)
typealias Challenge = (SpriteAttributes, SpriteAttributes) -> RMXTeam.ChallengeOutcome

typealias WinLogic = (Any? ...) -> Bool

@available(OSX 10.10, *)
protocol RMXTeamGame  {
    var interface: RMXInterface { get }
    var players: Array<RMXSprite> { get }
    var teamPlayers: Array<RMXSprite> { get }
    var nonPlayers: Array<RMXSprite> { get }
    var nonTeamPlayers: Array<RMXSprite> { get }
    func getTeam(id id: String) -> RMXTeam?
    func getTeamRoster(forTeam team: RMXTeam?) -> Array<RMXSprite>
    var winningTeam: RMXTeam? { get }
    func addTeam(team: RMXTeam)
    var teams: Dictionary<String, RMXTeam> { get }
    func updateTeam(team: RMXTeam) -> RMXTeam?
    var activeSprite: RMXSprite { get }
    var gameOverMessage: ((AnyObject?) -> [String]?)? { get set }
}

@available(OSX 10.10, *)
protocol RMXTeamMember {
    var attributes: SpriteAttributes! { get }
}

@available(OSX 10.10, *)
extension RMXScene : RMXTeamGame {
    
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

    
    func getTeam(id id: String) -> RMXTeam? {
        return self._teams[id]
    }
    
    
    func getTeamRoster(forTeam team: RMXTeam?) -> Array<RMXSprite> {
        return self.sprites.filter({ (child: RMXSprite) -> Bool in
            return child.attributes.teamID == team?.id
        })
    }
    
    /// Team IDs must be > 0. I.e. payer is assigned to a team
    var teamPlayers: Array<RMXSprite> {
        return self.sprites.filter( { (child: RMXSprite) -> Bool in
            return Int(child.attributes.teamID) ?? 1 > 0 && child.isPlayerOrAi
        })
    }
    
    var liveTeamPlayers: Array<RMXSprite> {
        return self.sprites.filter( { (child: RMXSprite) -> Bool in
            return Int(child.attributes.teamID) ?? 1 > 0 && child.isPlayerOrAi && child.attributes.isAlive
        })
    }
    
    ///Players not assigend to a team (i.e. teamID == 0 )
    var nonTeamPlayers: Array<RMXSprite> {
        return self.sprites.filter( { (child: RMXSprite) -> Bool in
            return child.isPlayerOrAi //&& child.attributes.teamID == 0
        })
    }
    
    
    
    var players: Array<RMXSprite> {
        return self.sprites.filter( { (child: RMXSprite) -> Bool in
            return child.isPlayerOrAi
        })
    }
    
    var nonPlayers: Array<RMXSprite> {
        return self.sprites.filter({ (child: RMXSprite) -> Bool in
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


typealias ScoreCard = (kills: Int, deaths: Int, points: Int)
typealias TeamStats = (score: ScoreCard, players: Int, livePlayers: Int)
@available(OSX 10.10, *)
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
    
    var startingHealth: Float = 100
    
    var score: ScoreCard = (0,0,0)
    
    var stats: TeamStats {
        let players = self.players
        let livePlayers = players.filter { (player) -> Bool in
            return player.attributes.isAlive
        }
        return (self.score, players.count, livePlayers.count)
    }
    
    var kills: Int {
        return self.score.kills
    }
    
    var deaths: Int {
        return self.score.deaths
    }
    
    var points: Int {
        return self.score.points
    }
    
    var game: RMXTeamGame
    
    var isRetired: Bool = false
    
    var players: Array<RMXSprite> {
        return self.game.getTeamRoster(forTeam: self)
    }
    
    var captain: SpriteAttributes?
    
    init(gameWorld game: RMXTeamGame, captain: RMXSprite? = nil, withID: AnyObject? = nil){
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
        
        if Int(player.attributes.teamID) ?? 1 < 0 { ///Actually this might be OK (capture the flag for example)
            RMLog("Warning: \(player.name!), with teamID: \(player.attributes.teamID), was not assigned a new team?")
            return false
        }
        if player.attributes.teamID != self.id { //will we get a new player?
            if player.attributes.isTeamCaptain {
                player.attributes.team?.captain = nil
            }
            player.attributes.setTeamID(self.id)
            if self.captain != nil { //do we have a captain?
                RMXTeam.setColor(self.kit, receiver: player.attributes)
            } else { //otherwise assign new player as captain and update team
                self.captain = player.attributes
                RMXTeam.setColor(RMXTeam.color(self.id), receiver: player.attributes)
                self.update()
            }
            if player.attributes.health < self.startingHealth {
                player.attributes.willChangeValueForKey("health")
                player.attributes.setHealth()
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
            return RMX.randomColor()
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
            if attacker.teamID == defender.teamID || Int(defender.teamID) ?? 1 <= 0 { return }
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
        let health = defender.health
        defender.reduceHealth(bySubtracting: 20)
        attacker.givePoints(Int(health - defender.health))
        if defender.health <= 0 {
//            self.convert(defender, toTeam: attacker.team)
            defender.registerDeath()
            attacker.registerKill()
            attacker.givePoints(defender.points)
            return .DefenderWasKilled
        }
        return .DefenderWasNotKilled
    }
    
    
    var print: String {
        return "TEAM-\(self.id) Points: \(self.score.points), Kills: \(self.score.kills), Deaths: \(self.score.deaths)"
    }
    
    override var description: String {
        let stats = self.stats
        return "TEAM-\(self.id) Points: \(self.score.points), Kills: \(self.score.kills), Deaths: \(self.score.deaths), Players: \(stats.livePlayers) out of \(stats.players) remaining"
    }
    
    class func indirectChallenge(attacker: SpriteAttributes, defender: SpriteAttributes) -> ChallengeOutcome {
        if !defender.isAlive { return .DefenderAlreadyDead }
        self.willChangeValueForKey("score")
        let health = defender.health
        if defender.health > 0 { defender.reduceHealth(bySubtracting: 10) }
        attacker.givePoints(Int(health - defender.health))
        if defender.health <= 0 {
            defender.registerDeath()
            attacker.registerKill()
            attacker.givePoints(defender.points)
            return .DefenderWasKilled
        }
        self.didChangeValueForKey("score")
        return .DefenderWasNotKilled
    }
    
    
    class func throwChallenge(challenger: RMXSprite, projectile: RMXSprite)  {
        func _challenge(contact: SCNPhysicsContact) -> Void {
            if let defender = contact.getDefender(forChallenger: challenger).rmxNode {
                if defender.willCollide ?? false && defender.attributes.teamID != challenger.attributes.teamID {
                    challenger.attributes.team?.willChangeValueForKey("score")
                    RMXTeam.challenge(challenger.attributes, defender: defender.attributes, doOnWin: self.indirectChallenge)
                    RMXTeam.challenge(challenger.attributes, defender: projectile.attributes, doOnWin: self.indirectChallenge)
                    challenger.attributes.team?.didChangeValueForKey("score")
//                    NSLog("I (\(challenger.name)) Smashed up, \(defender.name)")
                    challenger.scene.interface.av.playSound(UserAction.THROW_ITEM.rawValue, info: defender)
                    projectile.tracker.abort()
                }
            }
        }
        projectile.addCollisionAction(named: "Attack", removeAfterTime: 2, action: _challenge)
        
    }
    
    class func gameOverMessage(winner teamID: String, player: RMXSprite) -> [String] {
        let msg = teamID == player.attributes.teamID ? "Well done, \(player.name!)" : "You lose! :("
        return [ "The winning team is team \(teamID)! \(msg)" , "Your score: \(player.attributes.printScore)" ]
    }
    
    class func isGameWon(game: AnyObject?) -> [String]? {
        if let teamID = (game as? RMXTeamGame)?.winningTeam?.id {
            //            self.isRetired = true
            if let player = (game as? RMXTeamGame)?.activeSprite {
                return self.gameOverMessage(winner: teamID, player: player)
            }
        }
        return nil
    }

    
}
