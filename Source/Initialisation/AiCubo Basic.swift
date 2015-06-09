//
//  AiCubo Basic.swift
//  AiScene
//
//  Created by Max Bilbow on 23/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit


 enum GameType { case TEST, EMPTY, SOCCER, POOL, DOMED, IN_GLOBE, TEAM_GAME, WEAPONS }
@available(OSX 10.10, *)
class AiCubo {
   
   
    class func createEarth(inWorld world: RMSWorld, radius: RMFloat? = nil, addCameras: Bool = true) {
        let worldRadius = radius ?? world.radius
        
        let earth: RMXSprite = RMXSprite(inWorld: world, geometry: RMXModels.getNode(shapeType: ShapeType.FLOOR, radius: worldRadius, color: RMColor.yellowColor()), type: .BACKGROUND, unique: true)
        
        world.physicsWorld.gravity = SCNVector3Make(0,y: -9.8 * 10,z: 0)
        
        
        earth.setName("Earth")
        
        let earthPosition = SCNVector3Make(0,y: -earth.height / 2, z: 0)
        earth.setPosition(earthPosition)
        //earth.node.runAction(SCNAction.repeatActionForever(SCNAction.moveTo(earthPosition, duration: 1)))
        if addCameras {
            earth.addCameras()
            world.cameras += earth.cameras
        }

        
    }
 
    class func createLight(inWorld world: RMSWorld, fixed: Bool = true, radius: RMFloat? = nil, addCameras: Bool = true){
        let worldRadius = radius ?? world.radius
        
        let lightNode = RMXModels.getNode(shapeType: ShapeType.SPHERE, radius: 100)
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.geometry?.firstMaterial!.emission.contents = RMColor.whiteColor()
        lightNode.geometry?.firstMaterial!.emission.intensity = 1
        
        let sun: RMXSprite = RMXSprite(inWorld: world, geometry: lightNode, type: .ABSTRACT, shape: ShapeType.SUN, unique: true)
        sun.setName("Sun")
        sun.node.pivot.m43 = -worldRadius
        sun.node.eulerAngles.x = -45 * PI_OVER_180
        if !fixed {
            sun.node.runAction(SCNAction.repeatActionForever(SCNAction.rotateByAngle(CGFloat(1 * PI_OVER_180), aroundAxis: SCNVector3Make(1, y: 0, z: 0), duration: 1)))
        }
        if addCameras {
            RMXCamera.headcam(sun)
            world.cameras += sun.cameras
        }
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = RMColor.darkGrayColor()
        
        if fixed {
            sun.node.addChildNode(ambientLightNode)
        } else {
            let moon = RMXSprite(inWorld: world, type: .ABSTRACT, shape: .SUN, color: RMColor.lightGrayColor(), unique: true)
            moon.setName("Moon")
            moon.node.pivot.m43 = sun.node.pivot.m43
            moon.node.eulerAngles.x = 4 * sun.node.eulerAngles.x
            if !fixed {
                moon.node.runAction(SCNAction.repeatActionForever(SCNAction.rotateByAngle(CGFloat(1 * PI_OVER_180), aroundAxis: SCNVector3Make(1, y: 0, z: 0), duration: 1)))
            }
            if addCameras {
                RMXCamera.headcam(moon)
                world.cameras += moon.cameras
            }

        }
    }
    
  
    
    
    class func setUpWorld(interface: RMXInterface?, type: GameType = .TEAM_GAME, backupWorld: Bool = false) -> RMSWorld {
        if let interface = interface {

            let world = RMSWorld(interface: interface) //interface.world//
            world.addObserver(interface, forKeyPath: RMSWorld.kvScores, options: NSKeyValueObservingOptions.New, context: UnsafeMutablePointer<Void>())
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
                AiCubo.createLight(inWorld: world, fixed: true, addCameras: true)
                RMXArt.initializeTestingEnvironment(world,withAxis: true, withCubes: 50, shapes: .CYLINDER, .CUBE, .SPHERE)
                AiCubo.addPlayers(world, noOfPlayers: 20, teams: 0)
                RMXAi.addRandomMovement(to: world.sprites)
                break
            case .WEAPONS:
                world.name = "Weapons World"
                AiCubo.initialWorldSetup(world)
                AiCubo.createEarth(inWorld: world, addCameras: true)
                AiCubo.createLight(inWorld: world, fixed: true, addCameras: true)
                AiCubo.particles(inWorld: world)
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
                AiCubo.createEarth(inWorld: world, addCameras: true)
                AiCubo.createLight(inWorld: world, fixed: true, addCameras: true)
                RMXArt.initializeTestingEnvironment(world,withAxis: false, withCubes: 50, shapes: .CYLINDER, .SPHERE)
                AiCubo.addPlayers(world, noOfPlayers: 20, teams: 2)
                RMXAi.offenciveBehaviour(to: world.sprites)
                break
            default:
                AiCubo.initialWorldSetup(world)
                break
            }
            
//            interface.gameView!.scene = world.scene
//            interface.gameView.pointOfView = world.activeCamera
            
            return world
        } else {
            fatalError("inteface not initialised")
        }
        
        
    }
    
    class func particles(inWorld world: RMSWorld){
        let player = world.activeSprite
        let head = player.node.childNodeWithName("head", recursively: true)
        
        let ps = SCNParticleSystem()
        ps.emitterShape = head?.geometry
        
        head?.addParticleSystem(ps)
    }
    
    class func simplePlayer(world: RMSWorld, asAi: Bool = false, unique: Bool? = nil) -> RMXSprite {
        //Set up player
        let unique = unique != nil ? unique! : !asAi //if unique not stated, players are unique, ais are not
        let player = self.simpleSprite(world, type: asAi ? .AI : .PLAYER, isUnique: unique)
        
        //        world.cameras += player.cameras
        
        return player
    }
    
    class func simpleSprite(world: RMSWorld, type: RMXSpriteType = .PASSIVE, isUnique: Bool) -> RMXSprite {
        
        let player = RMXSprite(inWorld: world, geometry: RMXModels.getNode(shapeType: ShapeType.BOBBLE_MAN, radius: 6, color: RMX.randomColor()), type: type, shape: .BOBBLE_MAN, unique: isUnique).asPlayer()
        
        let lim = Int(world.radius)
        player.setPosition(SCNVector3Random(lim, min: -lim))//(0, 50, 50))//, resetTransform: <#Bool#>

        
        
        RMXAi.autoStablise(player)

        
        
        return player
    }
    
    
    class func soccerGame(world: RMSWorld) {
  
    }
    
    class func insideGlobe(world: RMSWorld) {
    
    }
    
    class func domedEnvironment(world: RMSWorld) {
//        AiCubo.initialWorldSetup(world)
        
    }
    
    class func initialWorldSetup(world: RMSWorld, radius: RMFloat? = nil, poppy: Bool = true, player2: Bool = true, additionalCameras: Bool = true){
        
        if let r = radius {
            world.setRadius(r)
        }
        //Set up Main Player
        let player = world.activeSprite
        
        //Set up Poppy
        RMX.makePoppy(world: world, master: player)
        
        
        //Set Up Player 2
        if player2 {
            let p2 = self.simplePlayer(world, asAi: true)
            p2.setName("Player")
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
    
    class func addPlayers(world: RMSWorld, noOfPlayers n: Int, teams: Int = 0){
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
                    return player.attributes.teamID == RMXSprite.TEAM_ASSIGNABLE
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