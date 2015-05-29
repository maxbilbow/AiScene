//: Playground - noun: a place where people can play

import Cocoa
import SceneKit
import GLKit
var str = "Hello, playground"

let PI = 3.14159265358979323846

let PI_OVER_180 = PI / 180

let q = 60 * PI_OVER_180

struct RMXTeam {
    static var COUNT: Int = 0
    lazy var aa: Int = COUNT++
}

var team = RMXTeam()

println("hello \(team.aa)")