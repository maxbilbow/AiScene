//
//  AiCubo Basic.swift
//  AiScene
//
//  Created by Max Bilbow on 23/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit
import RMXKit


enum GameType { case TEST, EMPTY, SOCCER, POOL, DOMED, IN_GLOBE, TEAM_GAME, TEAM_GAME_2, WEAPONS }
@available(OSX 10.10, *)
class AiCubo {
   
   
    class func createEarth(inWorld world: RMXScene, addCameras: Bool = true, type shape: ShapeType = .FLOOR) {
        
        let earth: RMXNode = RMXNode(inWorld: world, shape: shape, type: .BACKGROUND, unique: true, color:  RMColor.lightGrayColor())
        
        world.physicsWorld.gravity = SCNVector3Make(0,y: -9.8 * 10,z: 0)
        
        
        earth.updateName("Earth")
        
        let earthPosition = SCNVector3Make(0,y: -earth.height / 2, z: 0)
        earth.setPosition(earthPosition)
        if #available(OSX 10.11, iOS 9.0, *) {
            earth.physicsBody?.affectedByGravity = false
        } else {
            earth.addBehaviour { (object) -> Void in
                earth.resetTransform()
            }
        }
        if addCameras {
            earth.addCameras()
            world.cameras += earth.cameras
        }

        
    }
 
    class func createLight(inWorld world: RMXScene, fixed: Bool = false, radius: RMFloat? = nil, addCameras: Bool = false){
        let worldRadius = radius ?? world.radius
        
//        world.physicsWorld
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeSpot
        
        lightNode.light?.castsShadow = true
        lightNode.light?.shadowRadius = 3
        lightNode.light?.spotInnerAngle = 45
        lightNode.light?.spotOuterAngle = 100
        lightNode.light?.shadowBias = 1
        #if OSX
//        lightNode.light?.shadowMapSize = CGSizeMake(10000, 10000)
        #elseif iOS
//            lightNode.light?.shadowMapSize = CGSizeMake(1000, 1000)
        #endif
//        lightNode.light?.shadowMode = .Deferred
//
        lightNode.light?.zFar = CGFloat(worldRadius * 2)
        lightNode.light?.zNear = 100
//        lightNode.light?
        let sunNode = RMXModels.getNode(shapeType: ShapeType.SPHERE, radius: 100)
        sunNode.geometry?.firstMaterial!.emission.contents = RMColor.whiteColor()
        sunNode.geometry?.firstMaterial!.emission.intensity = 1
        let sun: RMXNode = RMXNode(inWorld: world, geometryNode: sunNode, type: .ABSTRACT, shape: ShapeType.SUN, unique: true)
        sunNode.addChildNode(lightNode)
        sun.updateName("sun")
        sun.pivot.m43 = -worldRadius
        sun.eulerAngles.x = -25 * PI_OVER_180
//        lightNode.pivot.m43 = sun.radius * 2
        if !fixed {
            sun.runAction(SCNAction.repeatActionForever(SCNAction.rotateByAngle(CGFloat(1 * PI_OVER_180), aroundAxis: SCNVector3Make(1, y: 0, z: 0), duration: 1)))
        }
        if addCameras {
            RMXCamera.headcam(sun)
            world.cameras += sun.cameras
        }
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
//        ambientLightNode.light?.shadowMode = .Deferred
//        ambientLightNode.geometry?.firstMaterial!.emission.contents = RMColor.whiteColor()
//        ambientLightNode.geometry?.firstMaterial!.emission.intensity = 0.5
        ambientLightNode.light!.color = RMColor.darkGrayColor()
//        ambientLightNode.light?.castsShadow = true
        ambientLightNode.position = SCNVector3Make(worldRadius / 4, worldRadius / 4, worldRadius / 4)
        world.rootNode.addChildNode(ambientLightNode)
        
//        let moonNode = RMXModels.getNode(shapeType: ShapeType.SPHERE, radius: 80)
//        moonNode.light = SCNLight()
//        moonNode.light!.type = SCNLightTypeOmni
//        
//        moonNode.light?.castsShadow = true
//        
//        moonNode.light?.shadowMode = .Deferred
//        moonNode.light?.zFar = worldRadius * 2
//        
//        
//        let moon: RMXNode = RMXNode(inWorld: world, geometry: moonNode, type: .ABSTRACT, shape: .SUN, unique: true)
//        moon.setName("moon")
//        moon.node.pivot.m43 = -worldRadius
//        moon.node.eulerAngles.x = 135 * PI_OVER_180
//        moon.node.geometry?.firstMaterial!.emission.contents = RMColor.whiteColor()
//        moon.node.geometry?.firstMaterial!.emission.intensity = 1
//
//        moonNode.pivot.m43 += worldRadius / 2
//        if !fixed {
//            moon.node.runAction(SCNAction.repeatActionForever(SCNAction.rotateByAngle(CGFloat(1 * PI_OVER_180), aroundAxis: SCNVector3Make(1, y: 0, z: 0), duration: 1)))
//        }
//        
//        if addCameras {
//            RMXCamera.headcam(moon)
//            world.cameras += moon.cameras
//        }
        
        
        
    }
    
  
    class func gameOverMessage(game: RMXTeamGame) -> (AnyObject?) -> [String]?  {
        let teamPlayers: Int = game.teamPlayers.count
        return ({(world: AnyObject?) -> [String]? in
            if let game = world as? RMXTeamGame {
                for team in game.teams {
                    //                            if (game as! RMXScene).activeCamera.pivot.m43 == 0 {
                    //                                return RMXTeam.gameOverMessage(winner: team.0, player: game.activeSprite)
                    //                            }
                    let score = team.1.score
                    if score.kills == teamPlayers {
                        return [ "Team \(team.0) killed \(score.kills) players!"] + RMXTeam.gameOverMessage(winner: team.0, player: game.activeSprite)
                    } else if team.0 == game.activeSprite.attributes.teamID && score.deaths == teamPlayers {
                        return [ "Your teammates died \(score.deaths) times!"] + RMXTeam.gameOverMessage(winner: team.0, player: game.activeSprite)
                    }
                }
            }
            return nil
        })
    
    }
    
    class func setUpWorld(interface: RMXInterface?, type: GameType = .TEAM_GAME, backupWorld: Bool = false) -> RMXScene {
        if let interface = interface {

            let world = RMXScene() //interface.world//
            world.addObserver(interface, forKeyPath: RMXScene.kvScores, options: NSKeyValueObservingOptions.New, context: UnsafeMutablePointer<Void>())
            //SetUpEnvironment
            switch type {
            case .EMPTY:
                AiCubo.initialWorldSetup(world)
                world.gravityOff()
                world.name = "Empty Space"
//                AiCubo.createEarth(inWorld: world, addCameras: true)
                AiCubo.createLight(inWorld: world, fixed: true, addCameras: true)
                RMXArt.initializeTestingEnvironment(world,withAxis: true, withCubes: 10, shapes: .CYLINDER, .ROCK)
                AiCubo.addPlayers(world, noOfPlayers: 3, teams: 3)
                
                break
            case .TEST:
                world.name = "Testing World"
                AiCubo.initialWorldSetup(world, radius: world.radius * 2)
                AiCubo.createEarth(inWorld: world, addCameras: true)
                AiCubo.createLight(inWorld: world, fixed: false, addCameras: true)
                RMXArt.initializeTestingEnvironment(world,withAxis: true, withCubes: 50, shapes: .CYLINDER, .CUBE, .SPHERE)
                AiCubo.addPlayers(world, noOfPlayers: 20, teams: 0)
                RMXAi.addRandomMovement(to: world.sprites)
                break
            case .WEAPONS:
                world.name = "Weapons World"
                AiCubo.initialWorldSetup(world)
                AiCubo.createEarth(inWorld: world, addCameras: true, type: .CYLINDER_FLOOR)
                AiCubo.createLight(inWorld: world, fixed: true, addCameras: true)
                AiCubo.addPlayers(world, noOfPlayers: 6, teams: 2)
                AiCubo.particles(inWorld: world)
                world.gameOverMessage = self.gameOverMessage(world)
                break
            case .DOMED:
                world.name = "Domed World"
                AiCubo.initialWorldSetup(world)
                AiCubo.createEarth(inWorld: world, addCameras: true)
                AiCubo.createLight(inWorld: world, fixed: true, addCameras: true)
                AiCubo.domedEnvironment(world)
                break
            case .IN_GLOBE:
                AiCubo.initialWorldSetup(world)
                AiCubo.createEarth(inWorld: world, addCameras: true)
                AiCubo.createLight(inWorld: world, fixed: true, addCameras: true)
                AiCubo.insideGlobe(world)
                break
            case .TEAM_GAME:
                world.name = "Team Game: Play to win!"
                AiCubo.initialWorldSetup(world)
                AiCubo.createEarth(inWorld: world, addCameras: true, type: .CYLINDER_FLOOR)
                AiCubo.createLight(inWorld: world, fixed: false, addCameras: true)
                RMXArt.initializeTestingEnvironment(world,withAxis: false, withCubes: 20, shapes: .CYLINDER, .CUBE)
                AiCubo.addPlayers(world, noOfPlayers: 10, teams: 2)
                RMXAi.offenciveBehaviour(to: world.sprites)
                world.gameOverMessage = self.gameOverMessage(world)
                break
            case .TEAM_GAME_2:
                world.name = "Team Game: 3 teams"
                
                AiCubo.initialWorldSetup(world)
                AiCubo.createEarth(inWorld: world, addCameras: true)
                AiCubo.createLight(inWorld: world, fixed: true, addCameras: true)
                RMXArt.initializeTestingEnvironment(world,withAxis: false, withCubes: 12, shapes: .CYLINDER, .CUBE)
                AiCubo.addPlayers(world, noOfPlayers: 9, teams: 3)
                RMXAi.offenciveBehaviour(to: world.sprites)
                world.gameOverMessage = self.gameOverMessage(world)
                break
            default:
                AiCubo.initialWorldSetup(world)
                break
            }
            
//            interface.gameView!.scene = world.scene
//            interface.gameView.pointOfView = world.activeCamera
            world.rootNode.castsShadow = true
            for node in world.rootNode.childNodes {
                if node.rmxNode?.isActor ?? false {
                    node.castsShadow = true
                }
            }

            return world
        } else {
            fatalError("inteface not initialised")
        }
        
        
    }
    
    class func particles(inWorld world: RMXScene){
        let player = world.activeSprite
        let head = player.childNodeWithName("head", recursively: true)
        
        let ps = SCNParticleSystem()
        ps.emitterShape = head?.geometry
        
        head?.addParticleSystem(ps)
    }
    
    class func simplePlayer(world: RMXScene, asAi: Bool = false, unique: Bool? = nil, safeInit: Bool = false) -> RMXNode {
        //Set up player
        let unique = unique != nil ? unique! : !asAi //if unique not stated, players are unique, ais are not
        let player = self.simpleSprite(world, type: asAi ? .AI : .PLAYER, isUnique: unique, safeInit: safeInit)
        
        //        world.cameras += player.cameras
        
        return player
    }
    
    class func simpleSprite(world: RMXScene, type: RMXSpriteType = .PASSIVE, isUnique: Bool, safeInit: Bool = false) -> RMXNode {
        
        let player = RMXNode(inWorld: world, geometryNode: RMXModels.getNode(shapeType: ShapeType.BOBBLE_MAN, radius: 6, color: RMX.randomColor()), type: type, shape: .BOBBLE_MAN, unique: isUnique, safeInit: safeInit)
        
        let lim = world.radius
        player.setPosition(SCNVector3Random(lim, min: -lim, setY: world.ground + 20))//(0, 50, 50))//, resetTransform: <#Bool#>

        
        
        RMXAi.autoStablise(player)

        
        
        return player
    }
    
    
    class func soccerGame(world: RMXScene) {
  
    }
    
    class func insideGlobe(world: RMXScene) {
    
    }
    
    class func domedEnvironment(world: RMXScene) {
//        AiCubo.initialWorldSetup(world)
        
    }
    
    class func initialWorldSetup(world: RMXScene, radius: RMFloat? = nil, poppy: Bool = true, player2: Bool = true, additionalCameras: Bool = true){
        
        world.setRadius(radius)
        //Set up Main Player
        let player = world.activeSprite
        
        //Set up Poppy
        RMX.makePoppy(world: world, master: player)
        
        
        //Set Up Player 2
        if player2 {
            let p2 = self.simplePlayer(world, asAi: true)
            p2.updateName("Player")
            p2.addCameras()
            world.cameras += p2.cameras
        }

        //additional cameras
        if additionalCameras {
            let farCam = RMXCamera.free(inWorld: world)
            let topCam = RMXCamera.free(inWorld: world)
            farCam.position = SCNVector3Make(0 , y: 100, z: world.radius)
            topCam.pivot.m43 = world.radius * -2
            topCam.eulerAngles.x = -70 * PI_OVER_180
        }
   
    }
    
    class func addPlayers(world: RMXScene, noOfPlayers n: Int, teams: Int = 0){
        
        if world.gameOverMessage == nil {
            world.gameOverMessage = RMXTeam.isGameWon
        }
        for ( var i = 0; i < n ; ++i) {
            self.simpleSprite(world, type: .AI, isUnique: false)
        }
        
        if teams > 0 {
            let player = world.activeSprite
            let teamA = RMXTeam(gameWorld: world, captain: player)
//            player.attributes.invincible = true
            RMLog(teamA.id)
            for ( var i = 1; i < teams; i++) {
                RMXTeam(gameWorld: world)
            }
            
            let max: Int = n / teams
            RMLog("\(max)")
            var count = 0
            for team in world.teams {
                for player in world.players.filter({ (player) -> Bool in
                    RMLog("\(player.attributes.teamID)")
                    return player.attributes.teamID == RMXNode.TEAM_ASSIGNABLE
                }) {
                    RMLog("\(player.name!) added to team: \(team.0)")
                    if team.1.addPlayer(player) && ++count > max {
                        count = 0
                        break
                    }
                    
                }
            }
//            for player in world.children {
//                if player.isPlayer && player.attributes.teamID == "0" {
//                    if let team = world.teams["\(teamID)"] {
//                        if team.addPlayer(player) {
//                            count++
//                            if team.players!.count == max {
////                                NSLog("Team: \(team.id), players: \(count)")
//                                teamID++
//                                count = 0
//                            }
//
//                        }
//                    }
//                }
//            }
            

        }
    }


}