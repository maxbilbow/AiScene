//
//  GameView.swift
//  SceneCubo
//
//  Created by Max Bilbow on 05/04/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import SceneKit

class GameView: SCNView  {
    
    var world: RMSWorld? {
        return self.interface?.world
    }
    
    var observer: RMXSprite {
        return self.world!.observer
    }
    
    
    var interface: RMXInterface?
    var gvc: GameViewController?
    
    func initialize(gvc: GameViewController, interface: RMXInterface){
        self.gvc = gvc
        self.interface = interface
        self.delegate = self.interface
    
        self.setUpWorld()
    }
    
        
      
    func setWorld(type: RMXWorldType){
        if self.world!.type != type {
            self.world!.setWorldType(worldType: type)
        }
    }
    
    
    
    func setUpWorld(){
        
        if let world = self.world {
            
            //Set up player
            let radius = RMFloatB((observer.geometry! as! SCNSphere).radius)
            let height = radius * 2
            let head = RMXModels.getNode(shapeType: ShapeType.SPHERE.rawValue, mode: .KINEMATIC, radius: radius * 0.5)
            head.physicsBody = SCNPhysicsBody()
            head.physicsBody!.mass = -10
            world.activeSprite.node.addChildNode(head)
            head.camera = RMXCamera()
            head.physicsBody!.mass = 0
            //        let bum = SCNNode()
            //        bum.physicsBody = SCNPhysicsBody()
            //        bum.physicsBody?.mass = RMFloat(self.observer.mass * 100)
            //        bum.position.y = -radius * 10
            //        bum.physicsBody?.resetTransform()
            //        self.observer.node.addChildNode(bum)
            
            head.position = SCNVector3Make(0, height * 0.9, 0)
            world.activeSprite.addCamera(head)
            self.pointOfView = head

            //Set up Poppy
            
            world.players["Poppy"] = RMX.makePoppy(world: world)
            
            //Set up background
            let worldRadius = RMSWorld.RADIUS * 10
            
            let sun: RMXSprite = RMXSprite.new(parent: world, type: .BACKGROUND, isUnique: true).makeAsSun(rDist: worldRadius)
            sun.addBehaviour { (isOn) -> () in
                sun.node.transform *= RMXMatrix4MakeRotation( -sun.rotationSpeed,  sun.rAxis)
            }
            
            let earth: RMXSprite = RMXSprite.new(parent: world, node: RMXModels.getNode(shapeType: ShapeType.FLOOR.rawValue, mode: .BACKGROUND, radius: worldRadius, color: NSColor.yellowColor()), type: .BACKGROUND, isUnique: true)
            
            world.scene.physicsWorld.gravity = RMXVector3Make(0,-9.8 * 10,0)
            
            //            earth.physicsField = SCNPhysicsField.radialGravityField()
            
            //            earth.physicsField!.categoryBitMask = Int(SCNPhysicsCollisionCategory.Default.rawValue)
            
            earth.setName(name: "The Ground")
            earth.setPosition(position: RMXVector3Make(0,-worldRadius / 2, 0))
            earth.addBehaviour({ (isOn) -> () in
                earth.resetTransform()
            })
            world.insertChild( earth, andNode: true)
            
            // retrieve the ship node
            if let node = self.scene?.rootNode.childNodeWithName("ship", recursively: true) {
                let ship = RMXSprite.new(parent: world, node: node, type: .AI, isUnique: true)
                node.physicsBody = SCNPhysicsBody.dynamicBody()
                node.physicsBody!.mass = 0.1
                ship.addBehaviour({ (isOn) -> () in
                    //Fly in circles?
                })
            }
            
            
            RMXArt.initializeTestingEnvironment(world,withAxis: true, withCubes: 100, radius: worldRadius)
            
            //cameras
            let sunCam: RMXNode = RMXNode()
            world.scene.rootNode.addChildNode(sunCam)
            
            sunCam.camera = RMXCamera()
            sunCam.position = RMXVector3Make(0 , 100, RMSWorld.RADIUS)
            world.observer.addCamera(sunCam)
            world.observer.addCamera( world.poppy.node)
        }
    }

       

    
}
