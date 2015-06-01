//
//  AiCubo Basic.swift
//  AiScene
//
//  Created by Max Bilbow on 23/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit


 enum GameType { case TEST, EMPTY, SOCCER, POOL, DOMED, IN_GLOBE, TEAM_GAME }
class AiCubo {
   
    
    
    
    class func setUpWorld(interface: RMXInterface?, type: GameType = .TEAM_GAME, backupWorld: Bool = false) -> RMSWorld {
        if let interface = interface {

            let world = RMSWorld(interface: interface) //interface.world//
            //SetUpEnvironment
            switch type {
            case .EMPTY:
//                self.simpleUniquePlayer(world)
                if world.hasGravity {
                    world.toggleGravity()
                }
//                let poppy = RMX.makePoppy(world: world, master: world.activeSprite)
                RMXArt.initializeTestingEnvironment(world,withAxis: true, withCubes: 10, radius: RMSWorld.RADIUS , shapes: .CYLINDER, .ROCK)
                AiCubo.addPlayers(world, n: 3, teams: 0)
                
                break
            case .TEST:
                AiCubo.testingEnvironment(interface, world: world)
                RMXArt.initializeTestingEnvironment(world,withAxis: true, withCubes: 50, radius: RMSWorld.RADIUS * 2, shapes: .CYLINDER, .CUBE, .SPHERE, .ROCK)
                AiCubo.addPlayers(world, n: 20, teams: 0)
                RMXAi.addRandomMovement(to: world.children)

                break
            case .DOMED:
                AiCubo.domedEnvironment(interface, world: world)
                break
            case .IN_GLOBE:
                AiCubo.insideGlobe(interface, world: world)
                break
            case .TEAM_GAME:
                AiCubo.testingEnvironment(interface, world: world)
                RMXArt.initializeTestingEnvironment(world,withAxis: false, withCubes: 50, radius: RMSWorld.RADIUS * 5, shapes: .CYLINDER, .SPHERE)
                
                AiCubo.addPlayers(world, n: 20, teams: 2)
               
                break
            default:
                AiCubo.testingEnvironment(interface, world: world)
                break
            }
            let ambientLightNode = SCNNode()
            ambientLightNode.light = SCNLight()
            ambientLightNode.light!.type = SCNLightTypeAmbient
            ambientLightNode.light!.color = NSColor.darkGrayColor()
            world.scene.rootNode.addChildNode(ambientLightNode)
//            interface.gameView!.scene = world.scene
//            interface.gameView.pointOfView = world.activeCamera
            
            return world
        } else {
            fatalError("inteface not initialised")
        }
        
        
    }
    
    class func simplePlayer(world: RMSWorld, asAi: Bool = false, unique: Bool? = nil) -> RMXSprite {
        //Set up player
        let unique = unique != nil ? unique! : !asAi //if unique not stated, players are unique, ais are not
        let player = self.simpleSprite(world, type: asAi ? .AI : .PLAYER, isUnique: unique)
        
        //        world.cameras += player.cameras
        
        return player
    }
    
    class func simpleSprite(world: RMSWorld, type: RMXSpriteType = .PASSIVE, isUnique: Bool) -> RMXSprite {
        
        let player = RMXSprite.new(inWorld: world, node: RMXModels.getNode(shapeType: ShapeType.BOBBLE_MAN, radius: 6, color: RMXArt.randomNSColor(), mode: type), type: type, isUnique: isUnique).asPlayer()
        
        let lim = Int(RMSWorld.RADIUS)
        player.setPosition(position: RMXVector3Random(lim, -lim))//(0, 50, 50))//, resetTransform: <#Bool#>

        
        
        RMXAi.autoStablise(player)

        
        
        return player
    }
    
    
    class func soccerGame(interface: RMXInterface, world: RMSWorld) {
  
    }
    
    class func insideGlobe(interface: RMXInterface, world: RMSWorld) {
        AiCubo.testingEnvironment(interface, world: world)
        let earth = world.scene.rootNode.childNodeWithName("Earth", recursively: true)!
        let globe = RMXSprite.new(inWorld: world, node: RMXModels.getNode(shapeType: ShapeType.SPHERE, mode: .BACKGROUND, radius: RMSWorld.RADIUS * 20, color: NSColor.yellowColor()), type: .BACKGROUND, isUnique: true)
        globe.node.geometry!.firstMaterial?.doubleSided = true
        if let gNode: SCNSphere = globe.node.geometry as? SCNSphere {
            gNode.geodesic = true
            
        }
        world.scene.rootNode.replaceChildNode(earth, with: globe.node)
        for child in world.children {
            if child.rmxID != globe.rmxID {
                child.node.removeFromParentNode()
                globe.node.addChildNode(child.node)//TODO: fix it
            }
        }
        
        world.toggleGravity()
        
    }
    
    class func domedEnvironment(interface: RMXInterface, world: RMSWorld) {
        AiCubo.testingEnvironment(interface, world: world)
        
    }
    
    class func testingEnvironment(interface: RMXInterface, world: RMSWorld){
        let player = world.activeSprite
        //Set Up Player 2
        let p2 = self.simplePlayer(world, asAi: true)
        p2.setName(name: "Player")
        
        //Set up Poppy
        let poppy = RMX.makePoppy(world: world, master: player)
        poppy.setName(name: "Poppy")
        poppy.attributes.setTeam(ID: -1)
        //            world.players["Poppy"] =
        
        //Set up background
        let worldRadius = RMSWorld.RADIUS * 10
        
        let sun: RMXSprite = RMXSprite.new(inWorld: world, type: .BACKGROUND, isUnique: true).makeAsSun(rDist: worldRadius)
        sun.addAi({ (node: SCNNode!) -> Void in
            if world.aiOn {
                sun.node.transform *= RMXMatrix4MakeRotation( -sun.rotationSpeed,  sun.rAxis)
            }
        })
        let lightNode = RMXModels.getNode(shapeType: ShapeType.SPHERE, mode: .BACKGROUND, radius: 100)
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.geometry?.firstMaterial!.emission.contents = NSColor.whiteColor()
        lightNode.geometry?.firstMaterial!.emission.intensity = 1
        sun.setPosition(position: RMXVector3Make(RMSWorld.RADIUS , RMSWorld.RADIUS * 5, 0))
        sun.node.addChildNode(lightNode)
        
        let earth: RMXSprite = RMXSprite.new(inWorld: world, node: RMXModels.getNode(shapeType: ShapeType.FLOOR, mode: .BACKGROUND, radius: worldRadius, color: NSColor.yellowColor()), type: .BACKGROUND, isUnique: true)
    
        world.scene.physicsWorld.gravity = RMXVector3Make(0,-9.8 * 10,0)
      
        
        earth.setName(name: "Earth")
        
        let earthPosition = RMXVector3Make(0,-worldRadius / 2, 0)
        earth.setPosition(position: RMXVector3Make(0,-worldRadius / 2, 0))
        earth.node.runAction(SCNAction.repeatActionForever(SCNAction.moveTo(earthPosition, duration: 1)))
        

        

        
        //camera
        
        
        
        

//        world.cameras += player.cameras
        p2.addCameras()
        poppy.addCameras()
        earth.addCameras()
        RMXCamera.headcam(sun)
        world.cameras += poppy.cameras
        world.cameras += p2.cameras
        let farCam = RMXCamera.free(inWorld: world)
        let topCam = RMXCamera.free(inWorld: world)
        
        world.cameras += earth.cameras
        world.cameras += sun.cameras
        
        farCam.position = RMXVector3Make(0 , 100, RMSWorld.RADIUS)
        topCam.pivot.m43 = RMSWorld.RADIUS * -5
        topCam.eulerAngles.x = -70 * PI_OVER_180


        
        
    }
    
    class func addPlayers(world: RMSWorld, n: Int, teams: Int = 0){
        for ( var i = 0; i < n ; ++i) {
            self.simpleSprite(world, type: .AI, isUnique: false)
        }
        
        if teams > 0 {
            let player = world.activeSprite
            let teamA = RMXTeam(gameWorld: world, captain: player)
            player.attributes.invincible = true
//            NSLog(teamA.id.toData())
            for ( var i = 1; i < teams; i++) {
                let team = RMXTeam(gameWorld: world)
            }
            
            let max: Int = n / teams
            var count = 0
            var teamID = 1 //team 0 is not a team
            for player in world.children {
                if player.isPlayer && player.attributes.teamID == 0 {
                    if let team = world.teams[teamID] {
                        if team.addPlayer(player) {
                            count++
                            if team.players.count == max {
                                teamID++
                                count = 0
                            }

                        }
                    }
                }
            }
            
//            NSLog("\(world.children.count), \(world.teamPlayers.count)")

             RMXAi.offenciveBehaviour(to: world.children)

        }
    }


}