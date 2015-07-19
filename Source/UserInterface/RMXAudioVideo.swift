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
//import RMXKit



//@available(OSX 10.9, *)
class RMSoundBox {
    
    private static var _current: RMSoundBox?
    
    static var current: RMSoundBox {
        return _current ?? RMSoundBox()
    }
    
    var sounds: [String:AVAudioPlayer]!
    
   
    init() {
        if RMSoundBox._current != nil {
            fatalError(RMXException.Singleton.rawValue)
        } else {
            RMSoundBox._current = self
            self.sounds = [
                UserAction.BOOM.rawValue : player(_url("Air Reverse Burst 2", ofType: "caf")),
                UserAction.JUMP.rawValue : player(_url("Pop", ofType: "m4a")),
                UserAction.THROW_ITEM.rawValue : player(_url("Baseball Catch", ofType: "caf")),
                "Pop"  : player(_url("Pop", ofType: "m4a")),
                "pop2" : player(_url("pop2", ofType: "m4a")),
                "pop1" : player(_url("pop1", ofType: "m4a"))
            ]            
        }
    }
    private var soundsQueue: [AVAudioPlayer] = []
    func playAudio() {
        for sound in self.soundsQueue {
            sound.play()
        }
        self.soundsQueue.removeAll(keepCapacity: true)
    }
    
    private func _url(name: String, ofType ext: String) -> NSURL? {
        return NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(name, ofType: ext)!)
    }
    

    func playSound(name: String, info: AnyObject?, volume maxVolume: Float = 1, range: Float = 500, autoPlay: Bool = true, volume: Float = 1) -> Bool {
        var position: SCNVector3!
        if let contact = info as? SCNNode {
            position = contact.presentationNode().position
        } else {
            position = RMXCameraNode.current?.presentationNode().position
        }
        if Float(position.length) > range {
            return false
        }

        if let sound = self.sounds[name] {// self.getPlayer(name) {

            if let camera = RMXCameraNode.current {
                let left = camera.worldTransform.leftTo(position)
                let distance = Float((position - camera.worldTransform.position).length)
                if  distance < Float(camera.camera!.zNear) || distance == Float(0) {
                    sound.volume = volume
                } else if distance > range {
                    return false
                } else {
                    sound.volume = (1 - distance / range) * volume ///TODO: better way of calculating this
                }
                sound.pan = Float(left.velocity) / range
            }
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
    
    private func player(url: NSURL?) -> AVAudioPlayer! {
        do {
            return try AVAudioPlayer(contentsOfURL: url!)
        } catch {
            print(error)
            return nil
        }
    }
//    func getPlayer(name: String) -> AVAudioPlayer? {
//        if let url = self.url(name, ofType ext: {
//            return AVAudioPlayer(contentsOfURL: url, error: nil)
//        } else {
//            return nil
//        }
//    }
}