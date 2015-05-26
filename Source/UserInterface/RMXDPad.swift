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
    let rollSpeed: RMFloatB = -1
    
    var moveButtonPad: UIImageView?// = RMXModels.getImage()
    var moveButton: UIView?
    var jumpButton: UIButton?
    var boomButton: UIButton?
    var topBar: UIView?
    var menuAccessBar: UIView?
    var pauseMenu: UIView?
    
    override func viewDidLoad(coder: NSCoder!){
        super.viewDidLoad(coder)
        if _hasMotion {
            self.motionManager.startAccelerometerUpdates()
            self.motionManager.startDeviceMotionUpdates()
            self.motionManager.startGyroUpdates()
            self.motionManager.startMagnetometerUpdates()
        }
        
        RMXInterface.moveSpeed *= 2 //-0.01 //-0.4
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
    
    func getRect(withinRect bounds: CGRect? = nil, row: (CGFloat, CGFloat), col: (CGFloat, CGFloat)) -> CGRect {
        let bounds = bounds ?? self.gameView.bounds
        return CGRectMake(bounds.width * (col.0 - 1) / col.1, bounds.height * (row.0 - 1) / row.1, bounds.width / col.1, bounds.height / row.1)
    }
    
    func makeButton(title: String? = nil, selector: String? = nil, view: UIView? = nil, row: (CGFloat, CGFloat), col: (CGFloat, CGFloat)) -> UIButton {
        let view = view ?? self.gameView
        let btn = UIButton(frame: getRect(withinRect: view?.bounds, row: row, col: col))//(view!.bounds.width * col.0 / col.1, view!.bounds.height * row.0 / row.1, view!.bounds.width / col.1, view!.bounds.height / row.1))
        if let title = title {
            btn.setTitle(title, forState:UIControlState.Normal)
        }
        if let selector = selector {
            btn.addTarget(self, action: Selector(selector), forControlEvents:UIControlEvents.TouchDown)
        }
        
        btn.enabled = true
        view?.addSubview(btn)
        return btn
    }
    
    func showTopBar(recogniser: UIGestureRecognizer) {
        if let topBar = self.topBar {
            topBar.hidden = !topBar.hidden
            self.menuAccessBar!.hidden = !self.menuAccessBar!.hidden
        }
    }
    
    override func hideButtons(hide: Bool) {
        self.moveButton?.hidden = hide
        self.moveButtonPad?.hidden = hide
        self.jumpButton?.hidden = hide
        self.boomButton?.hidden = hide
        super.hideButtons(hide)
    }
    
   override  func pauseGame(sender: AnyObject?) {
        super.pauseGame(sender)
        self.pauseMenu?.hidden = false
        self.menuAccessBar?.hidden = true
        self.hideButtons(true)
        
    }
    
    override func unPauseGame(sender: AnyObject?) {
        super.unPauseGame(sender)
        self.pauseMenu?.hidden = true
        self.menuAccessBar?.hidden = false
        self.hideButtons(false)
    }
    
    override func optionsMenu(sender: AnyObject?) {
        super.optionsMenu(sender)
    }
    
    override func exitToMainMenu(sender: AnyObject?) {
        super.exitToMainMenu(sender)
    }

    override func restartSession(sender: AnyObject?) {
        super.restartSession(sender)
    }
    
    var topBarBounds: CGRect {
        return CGRectMake(0,0, self.gameView.bounds.width, self.gameView.bounds.height * 0.1)
    }
    
    internal func makePauseMenu() {
        self.menuAccessBar = UIView(frame: self.topBarBounds)
        self.makeButton(title: "      +", selector: "showTopBar:", view: self.menuAccessBar, row: (1,1), col: (self.topColumns,self.topColumns))
        self.makeButton(title: "||     ", selector: "pauseGame:" , view: self.menuAccessBar, row: (1,1), col: (1,self.topColumns))
        
        self.gameView.addSubview(self.menuAccessBar!)
        
        self.pauseMenu = UIView(frame: self.topBarBounds)
        self.pauseMenu!.hidden = true
        self.pauseMenu?.backgroundColor = UIColor.grayColor()
        
        self.makeButton(title: "||     ", selector: "unPauseGame:" , view: self.pauseMenu, row: (1,1), col: (1,self.topColumns))
        self.makeButton(title: "Restart", selector: "restartSession:", view: self.pauseMenu, row: (1,1), col: (3,6))
        self.makeButton(title: "Options", selector: "optionsMenu:", view: self.pauseMenu, row: (1,1), col: (3,4))
        self.makeButton(title: "Exit to main menu", selector: "exitToMainMenu:", view: self.pauseMenu, row: (1,1), col: (4,4))

        
        
        let last: CGFloat = self.topColumns; let rows: CGFloat = 1// view.bounds.height / height
        self.gameView.addSubview(self.pauseMenu!)
    }
    
    private let topColumns: CGFloat = 7
    
    internal func makeTopBar ()  {
        
        self.topBar = UIView(frame: self.topBarBounds)
        self.topBar!.backgroundColor = UIColor.grayColor()
        self.topBar!.hidden = true
        
        let view = self.topBar!
        
        let last: CGFloat = self.topColumns; let rows: CGFloat = 1// view.bounds.height / height
        
        
        self.makeButton(title: "  < CAM", selector: "previousCamera:", view: view, row: (1,rows), col: (1,self.topColumns))
        
        self.makeButton(title: "  RESET", selector: "resetTransform:", view: view, row: (1,rows), col: (2,self.topColumns)) //UIButton(frame: rect(1))
        
        self.makeButton(title: "   AI  ", selector: "toggleAi:", view: view, row: (1,rows), col: (3,self.topColumns))
        
        self.makeButton(title: " GRAV  ", selector: "toggleAllGravity:", view: view, row: (1,rows), col: (4,self.topColumns))
        
        self.makeButton(title: " DATA  ", selector: "printData:", view: view, row: (1,rows), col: (5,self.topColumns))
        
        self.makeButton(title: "  CAM >", selector: "nextCamera:", view: view, row: (1,rows), col: (6,self.topColumns))
        
        self.makeButton(title: "      -", selector: "showTopBar:", view: view, row: (1,rows), col: (last,self.topColumns))
        
        self.gameView.addSubview(self.topBar!)
//        self.gameView.addSubview(self.menuAccessBar!)
        
    }
    
    override func setUpGestureRecognisers(){
//        let image = UIImage(contentsOfFile: "popNose.png")
//        button.setImage(image, forState: UIControlState.Normal)
//        let topBar: CGFloat = 40;
        self.makeTopBar()
        self.makePauseMenu()
        
        
        
        let topBar = self.topBar!
        self.dataView!.backgroundColor = UIColor.grayColor()
        self.dataView?.alpha = 0.3
        self.dataView?.bounds = CGRectMake(0, topBar.bounds.height, self.gameView.bounds.width, self.gameView.bounds.height - topBar.bounds.height )
        
        
       
        
        
        

        

        
        
        let w = self.gameView!.bounds.size.width
        let h = self.gameView!.bounds.size.height - topBar.bounds.height
        let leftView: UIView = UIImageView(frame: CGRectMake(0, topBar.bounds.height, w/2, h))
        let rightView: UIView = UIImageView(frame: CGRectMake(w / 3, topBar.bounds.height, w * 2 / 3, h))
        rightView.userInteractionEnabled = true
        
        
    
        

        
        
        
        
        
        
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
        let handleMovement: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,action: "handleMovement:")
        handleMovement.minimumPressDuration = 0.0
        self.moveButtonPad!.addGestureRecognizer(handleMovement)
        self.moveButtonPad!.userInteractionEnabled = true
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


