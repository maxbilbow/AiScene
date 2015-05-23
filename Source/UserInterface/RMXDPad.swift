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
   
    
    var moveButtonPad: UIImageView?// = RMXModels.getImage()
    var moveButton: UIView?
    var jumpButton: UIButton?
    var boomButton: UIButton?
    
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

    private var _count: Int = 0
    override func printDataToScreen(data: String) {
//        super.printDataToScreen(data)
////        self.dataView!.text = data
//        ++_count
//        if _count > 60 {
//            self.dataView?.text = data
//            _count = 0
//        }
    }
//    
//    override var view: RMXView {
//        return super.view as! RMXView
//    }
    override func setUpGestureRecognisers(){
//        let image = UIImage(contentsOfFile: "popNose.png")
//        button.setImage(image, forState: UIControlState.Normal)
        let topBar: CGFloat = 40; let buttonCount: CGFloat = 5
        
        self.dataView!.backgroundColor = UIColor.grayColor()
        self.dataView?.alpha = 0.3
        self.dataView?.bounds = CGRectMake(0, topBar, self.gameView.bounds.width, self.gameView.bounds.height - topBar )
        func makeBottomLeftBar (view: UIView)  {
            let lastCam: UIButton = UIButton(frame: CGRectMake(0, view.bounds.height - 30, view.bounds.width / 6, 20))
            
            lastCam.setTitle("< CAM ", forState:UIControlState.Normal)
            lastCam.addTarget(self, action: Selector("previousCamera:"), forControlEvents:UIControlEvents.TouchDown)
            lastCam.enabled = true
            view.addSubview(lastCam)
            
            let nextCam: UIButton = UIButton(frame: CGRectMake(view.bounds.width / 6, view.bounds.height - 30, view.bounds.width / 6, 20))
            
            nextCam.setTitle("CAM >", forState:UIControlState.Normal)
//            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            nextCam.addTarget(self, action: Selector("nextCamera:"), forControlEvents:UIControlEvents.TouchDown)
            nextCam.enabled = true
            view.addSubview(nextCam)
        }
        
        func makeTopBar (view: UIView)  {
            let switchButton: UIButton = UIButton(frame: CGRectMake(0, 0, view.bounds.width / buttonCount, topBar))
            
            switchButton.setTitle("<RESET> ", forState:UIControlState.Normal)
            switchButton.addTarget(self, action: Selector("resetTransform:"), forControlEvents:UIControlEvents.TouchDown)
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
            
            let explode: UIButton = UIButton(frame: CGRectMake(view.bounds.width * 3 / buttonCount, 0, view.bounds.width / buttonCount, topBar))
        
            explode.setTitle("<BOOM!>", forState:UIControlState.Normal)
//            explode.addTarget(self, action: Selector("explode:"), forControlEvents:UIControlEvents.TouchDown)
            explode.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "explode:"))
            explode.enabled = true
            explode.backgroundColor = UIColor.grayColor()
            view.addSubview(explode)
            
            let jump: UIButton = UIButton(frame: CGRectMake(view.bounds.width * 4 / buttonCount, 0, view.bounds.width / buttonCount, topBar))
            
            jump.setTitle("<DATA>", forState:UIControlState.Normal)
            //            behaviours.setTitle("BHAVIOURS OFF", forState:UIControlState.Selected)
            jump.addTarget(self, action: Selector( "printData:"), forControlEvents:UIControlEvents.TouchDown)
            jump.enabled = true
            jump.backgroundColor = UIColor.grayColor()
            view.addSubview(jump)
        }
        

        

        
        
        let w = self.gameView!.bounds.size.width
        let h = self.gameView!.bounds.size.height - topBar
        let leftView: UIView = UIImageView(frame: CGRectMake(0, topBar, w/2, h))
        let rightView: UIView = UIImageView(frame: CGRectMake(w / 3, topBar, w * 2 / 3, h))
        rightView.userInteractionEnabled = true
        makeTopBar(self.gameView)
        makeBottomLeftBar(self.gameView)
        
        
        
        
        
        
        //setLeftView(); //setRightView()//; setUpButtons()
        
        

        var bounds = self.moveButtonCenter//CGRectMake(origin.x, origin.y, size.width, size.height)
        bounds.size = CGSize(width: bounds.size.width + 10, height: bounds.size.height + 10)
        bounds.origin.x -= 5
        bounds.origin.y -= 5
        self.moveButton = self.moveButton(bounds.size, origin: bounds.origin)
        
        self.gameView.addSubview(self.moveButton!)
        self.gameView.bringSubviewToFront(self.moveButton!)
        
        let padImage: UIImage = RMXModels.getImage()
        self.moveButtonPad = UIImageView(frame: self.moveButtonCenter)//(image: padImage)
        self.moveButtonPad!.image = padImage
        self.moveButtonPad?.setNeedsDisplay()
        self.gameView.addSubview(self.moveButtonPad!)

        
        self.jumpButton = UIButton(frame: self.jumpButtonCenter)
        self.jumpButton?.setImage(RMXModels.getImage(), forState: UIControlState.Normal)
//        self.jumpButton?.setNeedsDisplay()
        let jump = UILongPressGestureRecognizer(target: self, action: "jump:")
        jump.minimumPressDuration = 0.0
        self.jumpButton?.addGestureRecognizer(jump)
        self.jumpButton!.enabled = true
        self.gameView.addSubview(self.jumpButton!)
        
        self.boomButton = UIButton(frame: self.boomButtonCenter)
        self.boomButton?.setImage(RMXModels.getImage(), forState: UIControlState.Normal)
//        self.boomButton?.setNeedsDisplay()
        let explode = UILongPressGestureRecognizer(target: self, action: "explode:")
        explode.minimumPressDuration = 0.0
        self.boomButton?.addGestureRecognizer(explode)
        self.boomButton!.enabled = true
        self.gameView.addSubview(self.boomButton!)
        
        
        self.gameView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "zoom:"))
        // add a tap gesture recognizer
        self.gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "grabOrThrow:"))
        rightView.addGestureRecognizer(UIPanGestureRecognizer(target: self,action: "handleOrientation:"))
        self.gameView.addSubview(rightView)
        
        self.gameView.bringSubviewToFront(self.boomButton!)
        self.gameView.bringSubviewToFront(self.jumpButton!)
    }
    
    var i = 0
    var moveOrigin: CGPoint = CGPoint(x: 0,y: 0)
    var lookOrigin: CGPoint = CGPoint(x: 0,y: 0)

    var boomTimer: RMFloatB = 1
    
    
}

    #else

class RMXDPad : RMXInterface {
    
}
#endif


