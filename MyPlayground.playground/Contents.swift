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
import SceneKit

class RMXSprite {
    var position = SCNVector3Make(0,0,0)
}
private var _ground: CGFloat? = 1
private var _radius: CGFloat? = 2
func validate(sprite: RMXSprite) -> Bool {
    var valid = true
    if let radius = _radius {
        var position = sprite.position
        position.y = 0
        if radius > 0 && position.distanceTo(RMXVector3Zero) > radius {
            return false
        }
    } else if let earth = self._scene.rootNode.childNodeWithName("Earth", recursively: true) {
        _radius = earth.radius
        _ground = earth.sprite?.top.y
        self.validate(sprite)
    }
    if let ground = _ground {
        valid = sprite.position.y < ground
    }
retur