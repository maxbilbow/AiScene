//
//  Accelorometer.swift
//  AiCubo
//
//  Created by Max Bilbow on 28/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
import GLKit

extension RMXDPad {
    func accelerometer() {
//        if true { return }
//        else {
//            let g = self.motionManager.deviceMotion.gravity
//            self.world!.physics.directionOfGravity = RMXVector3Make(RMFloat(g.x), RMFloat(g.y), RMFloat(g.z))
//        }
        
        func tilt(direction: RMInputKeyValue, tilt: RMFloat){
            let rollSpeed = self.rollSpeed
            let rollThreshold: RMFloat = 0.1
            if tilt > rollThreshold {
                let speed = (1.0 + tilt) * rollSpeed
                self.action(direction, speed: speed)
            } else if tilt < -rollThreshold {
                let speed = (-1.0 + tilt) * rollSpeed
                self.action(direction, speed: speed)
            }
        }
        
        let key = "accelerometerCounter"
//        let i = self.world!.clock?.getCounter(forKey:key)
//        if i == 1 { self.world!.clock?.setCounter(forKey: key) } else { return }
        if let deviceMotion = self.motionManager.deviceMotion {
            tilt(UserAction.ROLL_LEFT, tilt: RMFloat(deviceMotion.gravity.y))
            //tilt("pitch", RMFloat(self.motionManager.deviceMotion.gravity.z))
//            tilt("yaw", RMFloat(self.motionManager.deviceMotion.gravity.x)
            func updateGravity() {
//                let g = deviceMotion.gravity
//                self.gravity.x = RMFloat(g.x)
//                RMX.gravity.y = RMFloat(g.y)
//                RMX.gravity.z = RMFloat(g.z)
            }
//            updateGravity()
  
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
            e = self.motionManager.gyroData!.rotationRate.x
            f = self.motionManager.gyroData!.rotationRate.y
            g = self.motionManager.gyroData!.rotationRate.z
            if let magnetometerData = self.motionManager.magnetometerData {
                h = magnetometerData.magneticField.x
                i = magnetometerData.magneticField.y
                j = magnetometerData.magneticField.z
            } else { h=0;i=0;j=0 }
            k = deviceMotion.userAcceleration.x
            l = deviceMotion.userAcceleration.y
            m = deviceMotion.userAcceleration.z
            
//            let d = deviceMotion.magneticField.accuracy.rawValue
            
            print("           Gravity,\(x.toData()),\(y.toData()),\(z.toData())")
            print("   Magnetic Field1,\(q.toData()),\(r.toData()),\(s.toData())")
            print("   Magnetic Field2,\(h.toData()),\(i.toData()),\(j.toData())")
            print("     Rotation Rate,\(t.toData()),\(u.toData()),\(v.toData())")
            print("Gyro Rotation Rate,\(e.toData()),\(f.toData()),\(g.toData())")
            print("          Attitude,\(a.toData()),\(b.toData()),\(c.toData())")
            print("          userAcc1,\(k.toData()),\(l.toData()),\(m.toData())")
            
            
            if self.motionManager.accelerometerData != nil {
                print("          userAcc2,\(self.motionManager.accelerometerData!.acceleration.x.toData()),\(self.motionManager.accelerometerData!.acceleration.y.toData()),\(self.motionManager.accelerometerData!.acceleration.z.toData())")
                // println("      Magnetic field accuracy: \(d)")
            }
        }
        else {
//            RMLog("No motion?!")
        }
        // println()
    }
}

