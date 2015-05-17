//
//  Accelorometer.swift
//  AiCubo
//
//  Created by Max Bilbow on 28/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit

#if iOS

extension RMXDPad {
    func accelerometer() {
//        if true { return }
//        else {
//            let g = self.motionManager.deviceMotion.gravity
//            self.world!.physics.directionOfGravity = RMXVector3Make(RMFloatB(g.x), RMFloatB(g.y), RMFloatB(g.z))
//        }
        
        func tilt(direction: String, tilt: RMFloatB){
            let rollSpeed = RMFloatB(fabs(RMXInterface.moveSpeed)*4)
            let rollThreshold: RMFloatB = 0.1
            if tilt > rollThreshold {
                let speed = (1.0 + tilt) * rollSpeed
                self.action(action: direction, speed: speed)
            } else if tilt < -rollThreshold {
                let speed = (-1.0 + tilt) * rollSpeed
                self.action(action: direction, speed: speed)
            }
        }
        
        let key = "accelerometerCounter"
//        let i = self.world!.clock?.getCounter(forKey:key)
//        if i == 1 { self.world!.clock?.setCounter(forKey: key) } else { return }
        if let deviceMotion = self.motionManager.deviceMotion {
//            tilt("roll", RMFloatB(self.motionManager.deviceMotion.gravity.y))
            //tilt("pitch", RMFloatB(self.motionManager.deviceMotion.gravity.z))
//            tilt("yaw", RMFloatB(self.motionManager.deviceMotion.gravity.x))
            if let attitude = deviceMotion.attitude {
                //self.action(action: "setRoll",speed: RMFloatB(attitude.roll))
                //self.action(action: "setPitch",speed: RMFloatB(-attitude.pitch))
            }
            if !_testing { return }
            var x,y,z, q, r, s, t, u, v,a,b,c,e,f,g,h,i,j,k,l,m:Double
            x = deviceMotion.gravity.x
            y = deviceMotion.gravity.y
            z = deviceMotion.gravity.z
            q = deviceMotion.magneticField.field.x
            r = deviceMotion.magneticField.field.y
            s = deviceMotion.magneticField.field.z
            t = deviceMotion.rotationRate.x
            u = deviceMotion.rotationRate.y
            v = deviceMotion.rotationRate.z
            a = deviceMotion.attitude.pitch
            b = deviceMotion.attitude.roll
            c = deviceMotion.attitude.yaw
            e = self.motionManager.gyroData.rotationRate.x
            f = self.motionManager.gyroData.rotationRate.y
            g = self.motionManager.gyroData.rotationRate.z
            if let magnetometerData = self.motionManager.magnetometerData {
                h = magnetometerData.magneticField.x
                i = magnetometerData.magneticField.y
                j = magnetometerData.magneticField.z
            } else { h=0;i=0;j=0 }
            k = deviceMotion.userAcceleration.x
            l = deviceMotion.userAcceleration.y
            m = deviceMotion.userAcceleration.z
            
            let d = deviceMotion.magneticField.accuracy.value
            
            println("           Gravity,\(x.toData()),\(y.toData()),\(z.toData())")
            println("   Magnetic Field1,\(q.toData()),\(r.toData()),\(s.toData())")
            println("   Magnetic Field2,\(h.toData()),\(i.toData()),\(j.toData())")
            println("     Rotation Rate,\(t.toData()),\(u.toData()),\(v.toData())")
            println("Gyro Rotation Rate,\(e.toData()),\(f.toData()),\(g.toData())")
            println("          Attitude,\(a.toData()),\(b.toData()),\(c.toData())")
            println("          userAcc1,\(k.toData()),\(l.toData()),\(m.toData())")
            
            
            if self.motionManager.accelerometerData != nil {
                let dp = "04.1"
                println("          userAcc2,\(self.motionManager.accelerometerData!.acceleration.x.toData()),\(self.motionManager.accelerometerData!.acceleration.y.toData()),\(self.motionManager.accelerometerData!.acceleration.z.toData())")
                // println("      Magnetic field accuracy: \(d)")
            }
        }
        else {
            NSLog("No motion?!")
        }
        // println()
    }
}

#endif
