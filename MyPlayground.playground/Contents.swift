//: Playground - noun: a place where people can play

import Foundation


var name: String? = "max123"

var mass = 10.0
var damping = 0.1
var aDamping = 0.99
var _speed = 1000 * mass * damping / 10
var damped = _speed / damping


var s = 1000.0 * mass / ( 1.0 - damping ) / 10

damped = s * ( 1.0 - damping )

print(damped)