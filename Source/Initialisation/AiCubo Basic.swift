//
//  AiCubo Basic.swift
//  AiScene
//
//  Created by Max Bilbow on 23/05/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit



class AiCubo {
    enum Type { case TEST, EMPTY, SOCCER, POOL, DOMED, IN_GLOBE, TEAM_GAME }
    
    class func simpleUniquePlayer(world: RMSWorld) -> RMXSprite {
        //Set up player
        let player = self.simpleSprite(world, sprite: world.activeSprite, type: .PLAYER, isUnique: true)
        
//        world.cameras += player.cameras
        
        return player
    }
    
    class func setUpWorld(interface: RMXInterface?, type: Type = .TEAM_GAME, backupWorld: Bool = false){
        if let interface = interface {
            if let world = interface.world {
                world.deleteWorld(backup: backupWorld)
                //SetUpEnvironment
                switch type {
                case .EMPTY:
                    self.simpleUniquePlayer(world)
                    if world.hasGravity {
                        world.toggleGravity()
                    }
                    let poppy = RMX.makePoppy(world: world, master: world.activeSprite!)
                    RMXArt.initializeTestingEnvironment(world,withAxis: false, withCubes: 1, radius: world.radius / 2)
                    
                    break
                case .TEST:
                    _testingEnvironment(interface)
                    for player in world.players {
                        if player.type == RMXSpriteType.AI && !player.isUnique {
                            RMXAi.addRandomMovement(to: player)
                        }
                    }
                    break
                case .DOMED:
                    _domedEnvironment(interface)
                    break
                case .IN_GLOBE:
                    _insideGlobe(interface)
                    break
                case .TEAM_GAME:
                    teamGame(interface)
                    break
                default:
                    _testingEnvironment(interface)
                    break
                }
                let ambientLightNode = SCNNode()
                ambientLightNode.light = SCNLight()
                ambientLightNode.light!.type = SCNLightTypeAmbient
                ambientLightNode.light!.color = NSColor.darkGrayColor()
                world.scene.rootNode.addChildNode(ambientLightNode)
                interface.gameView!.scene = world.scene
                interface.gameView.pointOfView = world.activeCamera

            } else {
                fatalError("World not initialised")
            }
        } else {
            fatalError("inteface not initialised")
        }
        
        
    }
    
    class func simpleSprite(world: RMSWorld, sprite: RMXSprite? = nil, type: RMXSpriteType = .PASSIVE, isUnique: Bool) -> RMXSprite {
        
        let player = sprite ?? RMXSprite.new(inWorld: world, node: RMXModels.getNode(shapeType: ShapeType.BOBBLE_MAN.rawValue, radius: 6, color: RMXArt.randomNSColor(), mode: type), type: type, isUnique: isUnique).asPlayer()
        
        player.setPosition(position: RMXVector3Random(max: 50, min: -50))//(0, 50, 50))//, resetTransform: <#Bool#>

        
        
        RMXAi.autoStablise(player)

        
        
        return player
    }
    
    class func addTrailingCamera(to sprite: RMXSprite) {
        if sprite.type == .PLAYER {
//            let followCam = RMXCamera.followCam(sprite.node, option: .FREE)
//            sprite.cameras.append(followCam)
        }
    }
    
    internal class func _soccerGame(interface: RMXInterface) {
        if let world = interface.world {
            
        }
    }
    
    internal class func _insideGlobe(interface: RMXInterface) {
        if let world = interface.world {
            _testingEnvironment(interface)
            let earth = world.scene.rootNode.childNodeWithName("Earth", recursively: true)!
            let globe = RMXSprite.new(inWorld: world, node: RMXModels.getNode(shapeType: ShapeType.SPHERE.rawValue, mode: .BACKGROUND, radius: RMSWorld.RADIUS * 10, color: NSColor.yellowColor()), type: .BACKGROUND, isUnique: true)
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
        
    }
    
    internal class func _domedEnvironment(interface: RMXInterface) {
        _testingEnvironment(interface)
        
    }
    
    internal class func _testingEnvironment(interface: RMXInterface){
        if let world = interface.world {
            let player = self.simpleUniquePlayer(world)
            world.activeSprite = player
            //Set Up Player 2
            let p2 = self.simpleUniquePlayer(world)
            
            
            //Set up Poppy
//            let poppy = RMX.makePoppy(world: world, master: player)
//            poppy.attributes.setTeam(ID: -1)
            //            world.players["Poppy"] =
            
            //Set up background
            let worldRadius = RMSWorld.RADIUS * 10
            
            let sun: RMXSprite = RMXSprite.new(inWorld: world, type: .ABSTRACT, isUnique: true).makeAsSun(rDist: worldRadius)
            sun.addAi({ (node: RMXNode!) -> Void in
                sun.node.transform *= RMXMatrix4MakeRotation( -sun.rotationSpeed,  sun.rAxis)
            })
            let lightNode = RMXModels.getNode(shapeType: ShapeType.SPHERE.rawValue, mode: .ABSTRACT, radius: 100)
            lightNode.light = SCNLight()
            lightNode.light!.type = SCNLightTypeOmni
            lightNode.geometry?.firstMaterial!.emission.contents = NSColor.whiteColor()
            lightNode.geometry?.firstMaterial!.emission.intensity = 1
            sun.node.addChildNode(lightNode)
            
            let earth: RMXSprite = RMXSprite.new(inWorld: world, node: RMXModels.getNode(shapeType: ShapeType.FLOOR.rawValue, mode: .BACKGROUND, radius: worldRadius, color: NSColor.yellowColor()), type: .BACKGROUND, isUnique: true)
            
            //let earth: RMXSprite = RMXSprite.new(inWorld: world, node: RMXModels.getNode(shapeType: ShapeType.FLOOR.rawValue, mode: .PASSIVE, radius: worldRadius, color: NSColor.yellowColor()), type: .BACKGROUND, isUnique: true)
            
            world.scene.physicsWorld.gravity = RMXVector3Make(0,-9.8 * 10,0)
            
            //            earth.physicsField = SCNPhysicsField.radialGravityField()
            
            //            earth.physicsField!.categoryBitMask = Int(SCNPhysicsCollisionCategory.Default.rawValue)
            
            earth.setName(name: "Earth")
            let earthPosition = RMXVector3Make(0,-worldRadius / 2, 0)
            earth.setPosition(position: RMXVector3Make(0,-worldRadius / 2, 0))
            earth.node.runAction(SCNAction.repeatActionForever(SCNAction.moveTo(earthPosition, duration: 1)))
            
    
            

            
            //camera
            RMXCamera.headcam(sun)
            
            
            
    
//            world.cameras += player.cameras
            world.cameras += p2.cameras
            
            world.cameras += earth.cameras
            world.cameras += sun.cameras
            
            let topCam = RMXCamera.free(inWorld: world)
            topCam.pivot.m43 = RMSWorld.RADIUS * -5
            topCam.eulerAngles.x = -70 * PI_OVER_180
//            world.cameras.append(topCam)
            
            let farCam = RMXCamera.free(inWorld: world)
            farCam.position = RMXVector3Make(0 , 100, RMSWorld.RADIUS)
//            world.cameras.append(farCam)
            
            world.aiOn = true

        }
        
    }
    
    internal class func teamGame(interface: RMXInterface){
        if let world = interface.world {
            _testingEnvironment(interface)
            RMXArt.initializeTestingEnvironment(world,withAxis: false, withCubes: 100, radius: RMSWorld.RADIUS / 2)
            let player = world.activeSprite!
            let teamA = RMXTeam(gameWorld: world, captain: player)
            player.attributes.invincible = true
            let teamB = RMXTeam(gameWorld: world)
            
            
            
            var aOrB = true
            for player in world.nonTeamPlayers {
                let team = aOrB ? teamA : teamB
                team.addPlayer(player)
                aOrB = !aOrB
            }
            
            let poppy = RMX.makePoppy(world: world, master: player)
            poppy.attributes.setTeam(ID: -1)
            world.cameras += poppy.cameras
            
            for teamMate in world.teamPlayers {
                if teamMate.type == RMXSpriteType.AI && !teamMate.isUnique {
                    RMXAi.offenciveBehaviour(to: teamMate)
                }
            }
        }
    }

}