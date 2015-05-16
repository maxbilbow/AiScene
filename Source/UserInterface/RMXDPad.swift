//
//  RMXDPad.swift
//  RattleGL
//
//  Created by Max Bilbow on 23/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import GLKit
#if iOS

import CoreMotion
import UIKit
    

class RMXDPad : RMXInterface {
    
     let _testing = false
     let _hasMotion = true
    
    let motionManager: CMMotionManager = CMMotionManager()
   
    
    
    override func viewDidLoad(coder: NSCoder!){
        super.viewDidLoad(coder)
        if _hasMotion {
            self.motionManager.startAccelerometerUpdates()
            self.motionManager.startDeviceMotionUpdates()
            self.motionManager.startGyroUpdates()
            self.motionManager.startMagnetometerUpdates()
        }
        
        RMXInterface.moveSpeed *= -0.2
        #if SceneKit
            RMXInterface.lookSpeed *= 0.1
            #else
        self.lookSpeed *= -0.02
        #endif
    }
    override func update() {
        super.update()
        self.accelerometer()
    }
//    
//    override var view: RMXView {
//        return super.view as! RMXView
//    }
    override func setUpGestureRecognisers(){
//        let image = UIImage(contentsOfFile: "popNose.png")
//        button.setImage(image, forState: UIControlState.Normal)
        let topBar: CGFloat = 40; let buttonCount: CGFloat = 5
        func makeBottomLeftBar (view: UIView)  {
            let lastCam: UIButton = UIButton(frame: CGRectMake(0, view.bounds.height - 30, view.bounds.width / 3, 20))
            
            lastCam.setTitle("< CAM ", forState:UIControlState.Normal)
            lastCam.addTarget(self, action: Selector("previousCamera:"), forControlEvents:UIControlEvents.TouchDown)
            lastCam.enabled = true
            view.addSubview(lastCam)
            
            let nextCam: UIButton = UIButton(frame: CGRectMake(view.bounds.width / 3, view.bounds.height - 30, view.bounds.width / 3, 20))
            
            nextCam.setTitle("CAM >", forState:UIControlState.Normal)
//            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            nextCam.addTarget(self, action: Selector("nextCamera:"), forControlEvents:UIControlEvents.TouchDown)
            nextCam.enabled = true
            view.addSubview(nextCam)
        }
        
        func makeTopBar (view: UIView)  {
            let switchButton: UIButton = UIButton(frame: CGRectMake(0, 0, view.bounds.width / buttonCount, topBar))
            
            switchButton.setTitle("<SWITCH> ", forState:UIControlState.Normal)
            switchButton.addTarget(self, action: Selector("switchEnvironment:"), forControlEvents:UIControlEvents.TouchDown)
            switchButton.enabled = true
            switchButton.backgroundColor = UIColor.grayColor()
            view.addSubview(switchButton)
            
            let behaviours: UIButton = UIButton(frame: CGRectMake(view.bounds.width / buttonCount, 0, view.bounds.width / buttonCount, topBar))
            
            behaviours.setTitle("<Toggle AI>", forState:UIControlState.Normal)
            //            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            behaviours.addTarget(self, action: Selector("toggleAi:"), forControlEvents:UIControlEvents.TouchDown)
            behaviours.enabled = true
            behaviours.backgroundColor = UIColor.grayColor()
            view.addSubview(behaviours)
            
            let gravity: UIButton = UIButton(frame: CGRectMake(view.bounds.width * 2 / buttonCount, 0, view.bounds.width / buttonCount, topBar))
            
            gravity.setTitle("<Gravity>", forState:UIControlState.Normal)
            //            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            gravity.addTarget(self, action: Selector("toggleAllGravity:"), forControlEvents:UIControlEvents.TouchDown)
            gravity.enabled = true
            gravity.backgroundColor = UIColor.grayColor()
            view.addSubview(gravity)
            
            let playerGravity: UIButton = UIButton(frame: CGRectMake(view.bounds.width * 3 / buttonCount, 0, view.bounds.width / buttonCount, topBar))
            
            playerGravity.setTitle("<My Gravity>", forState:UIControlState.Normal)
            //            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            playerGravity.addTarget(self, action: Selector("toggleGravity:"), forControlEvents:UIControlEvents.TouchDown)
            playerGravity.enabled = true
            playerGravity.backgroundColor = UIColor.grayColor()
            view.addSubview(playerGravity)
            
            let jump: UIButton = UIButton(frame: CGRectMake(view.bounds.width * 4 / buttonCount, 0, view.bounds.width / buttonCount, topBar))
            
            jump.setTitle("<JUMP>", forState:UIControlState.Normal)
            //            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            jump.addTarget(self, action: Selector("jump:"), forControlEvents:UIControlEvents.TouchDown)
            jump.enabled = true
            jump.backgroundColor = UIColor.grayColor()
            view.addSubview(jump)
        }

        
        
        let w = self.gameView!.bounds.size.width
        let h = self.gameView!.bounds.size.height - topBar
        let leftView: UIView = UIImageView(frame: CGRectMake(0, topBar, w/2, h))
        let rightView: UIView = UIImageView(frame: CGRectMake(w/2, topBar, w/2, h))
        makeTopBar(self.gameView)
        makeBottomLeftBar(leftView)
        
        
        
        func setLeftView() {
            
            let view = leftView
           
            let movement:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,action: "handleMovement:")
//            movement.numberOfTouchesRequired = 1
            movement.minimumPressDuration = 0
            view.addGestureRecognizer(movement)
            
            
            
            
            view.userInteractionEnabled = true
            self.gameView!.addSubview(leftView)
            
            
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "grabOrThrow:"))
            
        }
        
        func setRightView() {
            
            let view = rightView
            let look:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self,action: "handleOrientation:")
//            look.minimumPressDuration = 0
            view.addGestureRecognizer(look)
            

//            view.addGestureRecognizer(UILongPressGestureRecognizer(target: self,  action: "extendArm:"))
            view.userInteractionEnabled = true
            self.gameView!.addSubview(rightView)
            
                
            // add a tap gesture recognizer
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "grabOrThrow:"))
           

        }
        
        
//    self.gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "grabOrThrow:"))
        
        setLeftView(); setRightView()//; setUpButtons()
        
    }
    
    var i = 0
    var moveOrigin: CGPoint = CGPoint(x: 0,y: 0)
    var lookOrigin: CGPoint = CGPoint(x: 0,y: 0)

    
    
    
}

#endif


