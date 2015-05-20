//: Playground - noun: a place where people can play

import Cocoa
import SceneKit
import GLKit
var str = "Hello, playground"

func RMXVector3Length(v: SCNVector3) -> CGFloat {

        return CGFloat(GLKVector3Length(SCNVector3ToGLKVector3(v)))

}


let vector = SCNVector3Make(-1,-1,-1)

RMXVector3Length(vector)