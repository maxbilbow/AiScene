//
//  TeamGame.swift
//  AiScene
//
//  Created by Max Bilbow on 28/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation

import SceneKit

typealias Challenge = (SpriteAttributes, SpriteAttributes) -> Bool
typealias WinLogic = (Any? ...) -> Bool

protocol RMXTeamGame  {
    var players: Array<RMXSprite> { get }
    var teamPlayers: Array<RMXSprite> { get }
    var nonPlayers: Array<RMXSprite> { get }
    var nonTeamPlayers: Array<RMXSprite> { get }
    func getTeam(#id: Int) -> Array<RMXSprite>?
    func getTeam(#team: RMXTeam?) -> Array<RMXSprite>?
    var winningTeam: RMXTeam? { get }
    func addTeam(team: RMXTeam)
    var teams: [Int:RMXTeam] { get set }
}

protocol RMXTeamMember {
    var attributes: SpriteAttributes! { get }
}


extension RMSWorld : RMXTeamGame {
    
    func addTeam(team: RMXTeam) {
        self.teams[team.id] = team
    }
    
    func getTeam(#id: Int) -> Array<RMXSprite>? {
        return self.children.filter({ (child: RMXSprite) -> Bool in
            return child.attributes.teamID == id
        })
    }
    
    
    func getTeam(#team: RMXTeam?) -> Array<RMXSprite>? {
        return team != nil ? self.getTeam(id: team!.id) : nil
    }
    
    /// Team IDs must be > 0. I.e. payer is assigned to a team
    var teamPlayers: Array<RMXSprite> {
        return self.children.filter( { (child: RMXSprite) -> Bool in
            return child.attributes.teamID > 0 && child.isPlayer
        })
    }
    
    var liveTeamPlayers: Array<RMXSprite> {
        return self.children.filter( { (child: RMXSprite) -> Bool in
            return child.attributes.teamID > 0 && child.isPlayer && child.attributes.isAlive
        })
    }
    
    ///Players not assigend to a team (i.e. teamID == 0 )
    var nonTeamPlayers: Array<RMXSprite> {
        return self.children.filter( { (child: RMXSprite) -> Bool in
            return child.isPlayer //&& child.attributes.teamID == 0
        })
    }
    
    
    
    var players: Array<RMXSprite> {
        return self.children.filter( { (child: RMXSprite) -> Bool in
            return child.isPlayer
        })
    }
    
    var nonPlayers: Array<RMXSprite> {
        return self.children.filter({ (child: RMXSprite) -> Bool in
            return !child.isPlayer
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



class SpriteAttributes {
    var invincible = false
    var sprite: RMXSprite
    
    private var _teamID: Int = 0
    
    var teamID: Int {
        return _teamID
    }
    
    var team: RMXTeam? {
        return self.game?.teams[self.teamID]
    }
    
    var game: RMXTeamGame? {
        return self.sprite.world
    }
    
    var rmxID: Int {
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
    }
    
    func setTeam(#ID: Int){
        if self.teamID != ID {
            _teamID = ID
            self.team?.addPlayer(self.sprite)
        } else {
            _teamID = ID
        }
    }
    
    var isTeamPlayer: Bool {
        return self.teamID >= 0
    }
    
    
    
    private var _collisionBitMask: Int?
    private var _transparency: CGFloat?
    
    var isAlive = true
    func retire() {
        if !self.invincible {
            self.sprite.node.paused = true
//            _collisionBitMask = self.sprite.physicsBody?.collisionBitMask
//            self.sprite.physicsBody?.collisionBitMask = 0
//            _transparency = self.kit?.transparency
//            self.kit?.transparency = 0
//            _deathCount++
            self.isAlive = false
        }
        
    }
    
    private var _deathCount: Int = 0
    private var _killCount: Int = 0
    
    var deathCount: Int {
        return _deathCount
    }
    
    var killCount: Int {
        return _killCount
    }
    
    internal func kill() {
        _killCount++
    }
    internal func die() {
        _deathCount++
    }
    
    
    func deRetire() {
        self.sprite.node.paused = false
        self.isAlive = true
//        if _deathCount > 0 {
//            self.sprite.physicsBody?.collisionBitMask = _collisionBitMask ?? 0
//            self.kit?.transparency = _transparency ?? 0
//        }
    }
    
    func challenge(defender: SpriteAttributes, doOnWin didKill: Challenge){
        if defender.isTeamPlayer && didKill(self,defender) {
            _killCount++
            defender._deathCount++
//            defender.die()
        }
    }
    
    var score: ScoreCard {
        return (kills: _killCount, deaths: _deathCount, points: self.points, health: self.health)
    }
    
    var printScore: String {
        let score = self.score
        return "PLAYER SCORE: \(score.points), KILLS: \(score.kills), DEATHS: \(score.deaths), HEALTH: \(score.health)"
    }

}

typealias ScoreCard = (kills: Int, deaths: Int, points: Int, health: Int)
class RMXTeam {
    static var COUNT: Int = 0
    lazy var id: Int = ++COUNT //first time is 1
    var kit: SCNMaterial? {
        return self.captain?.kit
    }
    
    var startingHealth = 100
    
    var score: ScoreCard {
        var score: ScoreCard = (kills: 0, deaths: 0, points: 0, health: 0)
        if let team = game.getTeam(id: self.id) {
            for player in team {
                score.kills  += player.attributes.killCount
                score.deaths += player.attributes.deathCount
                score.points += player.attributes.points
                score.health += player.attributes.health
            }
        }
        return score
    }
    
    var game: RMXTeamGame
    
    var isRetired: Bool = false
    
    var players: Array<RMXSprite> {
        return self.game.getTeam(id: self.id)!
    }
    
    var captain: SpriteAttributes?
    
    init(gameWorld game: RMXTeamGame, captain: RMXSprite? = nil){
        self.game = game
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
        var players = self.players.count
        if player.attributes.teamID < 0 {
            return false
        }
        
        if player.attributes.teamID != self.id {
            player.attributes.setTeam(ID: self.id)
            return players < self.players.count//come back with the right id
        }
        
        if let captain = self.captain {
            RMXTeam.setColor(self.kit, receiver: player.attributes)
        } else {
            self.captain = player.attributes
            RMXTeam.setColor(RMXTeam.color(self.id), receiver: player.attributes)
            self.update()
        }
        if player.attributes.health < self.startingHealth {
            player.attributes.health = self.startingHealth
        }
        return players < self.players.count
        
    }
    
    private static func color(id: Int) -> RMColor {
        switch id {
        case 0:
            return RMColor.blackColor()
        case 1:
            return RMColor.redColor()
        case 2:
            return RMColor.brownColor()
        case 3:
            return RMColor.greenColor()
        case 4:
            return RMColor.blueColor()
        default:
            return RMXArt.randomNSColor()
        }
    }
    
    func retire() {
        RMXTeam.isGameWon(self.game)
        self.isRetired = true
    }
    
    class func updateTeam(team: RMXTeam?) {
        if let players = team?.players {
            for player in players {
                RMXTeam.setColor(team?.kit, receiver: player.attributes)
            }
        }
    }
    
    private class func retireIf(defender: SpriteAttributes) -> Bool {
        return defender.isTeamCaptain && defender.team!.players.count <= 1
    }
    
    
    
    class func convert(defender: SpriteAttributes, toTeam team: RMXTeam?, willRetireIf: (SpriteAttributes) -> Bool = RMXTeam.retireIf) {
        if defender.isTeamPlayer {
            if willRetireIf(defender) {
                defender.team?.retire()
            } else if let team = team {
                team.addPlayer(defender.sprite)
            }
        }
    }
    
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
    class func challenge(attacker: SpriteAttributes, defender: SpriteAttributes, doOnWin: Challenge = RMXTeam.challengeWon) {
        if attacker.teamID == defender.teamID || defender.teamID <= 0 { return }
        if doOnWin(attacker,defender) {
            defender.retire()
        }
//        NSLog(attacker.points.toData())
    }
    
    private class func doAfterChallengeWon(attacker: SpriteAttributes, defender: SpriteAttributes) -> Void {
        self.convert(defender, toTeam: attacker.team)
    }
    
    
    class func challengeWon(attacker: SpriteAttributes, defender: SpriteAttributes) -> Bool {
        let health = defender.health
        defender.health /= 2
        attacker.points += health - defender.health
        if defender.health < 20 {
            self.convert(defender, toTeam: attacker.team)
            defender.die()
            attacker.kill()
            attacker.points += defender.points
            return true
        }
        return false
    }
    
    class func isGameWon(game: RMXTeamGame?) -> Bool {
        return game?.winningTeam != nil
    }
    
    var printScore: String {
        return "TEAM-\(self.id) SCORE: \(self.score.points), KILLS: \(self.score.kills), DEATHS: \(self.score.deaths), PLAYERS: \(self.players.count)"
    }
    
}