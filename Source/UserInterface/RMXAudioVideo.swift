//
//  RMXAudioVideo.swift
//  
//
//  Created by Max Bilbow on 28/05/2015.
//
//

import Foundation
import AVFoundation
import SceneKit

protocol RMXLocatable {
    func getPosition() -> RMXVector
}


class RMXAudioVideo {
    
    var interface: RMXInterface
    
    var sounds: [String:AVAudioPlayer] = [
        RMXInterface.BOOM : RMXAudioVideo.player(RMXAudioVideo.url("Air Reverse Burst 2", ofType: "caf")),
        RMXInterface.JUMP : RMXAudioVideo.player(RMXAudioVideo.url("Pop", ofType: "m4a")),
        RMXInterface.THROW_ITEM : RMXAudioVideo.player(RMXAudioVideo.url("Baseball Catch", ofType: "caf")),
        "Pop"  : RMXAudioVideo.player(RMXAudioVideo.url("Pop", ofType: "m4a")),
        "pop2" : RMXAudioVideo.player(RMXAudioVideo.url("pop2", ofType: "m4a")),
        "pop1" : RMXAudioVideo.player(RMXAudioVideo.url("pop1", ofType: "m4a"))
    ]

    init(interface: RMXInterface){
        self.interface = interface
//        for sound in self.sounds {
//            sound.1.prepareToPlay()
//        }
//        self.sounds["hit"]?.volume = 0.1
//        self.sounds[RMXInterface.JUMP]?.volume = 0.0
//        self.sounds[RMXInterface.BOOM]?.volume = 0.3
    }
    
    private var soundsQueue: [AVAudioPlayer] = []
    func playAudio() {
        for sound in self.soundsQueue {
            sound.play()
        }
        self.soundsQueue.removeAll(keepCapacity: true)
    }
    
    class func url(name: String, ofType ext: String) -> NSURL? {
        return NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(name, ofType: ext)!)
    }
    
    func playSound(name: String, info: RMXLocatable?, volume maxVolume: Float = 1, range: Float = 500, autoPlay: Bool = true, volume: Float = 1) -> Bool {
        var position: RMXVector!
        if let contact = info {
            position = contact.getPosition()
        } else {
            position = self.interface.activeCamera!.getPosition()
        }
        if position.length > range {
            return false
        }

        if let sound = self.sounds[name] {// self.getPlayer(name) {

            let camera = self.interface.activeCamera
            let left = camera!.worldTransform.leftTo(position)
            let distance = (position - camera!.getPosition()).length
            if  distance < Float(camera!.camera!.zNear) || distance == 0 {
                sound.volume = volume
            } else if distance > range {
                return false
            } else {
                sound.volume = (1 - distance / range) * volume ///TODO: better way of calculating this
            }
            sound.pan = Float(left.velocity) / range
//            if sound.pan > 1 { sound.pan = 1 } else if sound.pan < -1 { sound.pan = -1 }

            //println(" \(name) - position: \(position.print), camera: \(camera!.getPosition().print)\n \(name) - Distance from Camera: \(distance.toData())")
//            println("VOLUME: \(sound.volume)\n cam:\n\(camera!.worldTransform.print) left: \(left.print) \n PAN: \(sound.pan.toData()) \n\n")
            sound.prepareToPlay()
            if autoPlay {
                sound.play()
            } else {
                self.soundsQueue.append(sound)
            }
            return true
        } else {
            return false
//            NSLog("sound '\(name)' not recognised")
        }
    }
    
    class func player(url: NSURL?) -> AVAudioPlayer {
        return AVAudioPlayer(contentsOfURL: url, error: nil)
    }
//    func getPlayer(name: String) -> AVAudioPlayer? {
//        if let url = self.url(name, ofType ext: {
//            return AVAudioPlayer(contentsOfURL: url, error: nil)
//        } else {
//            return nil
//        }
//    }
}