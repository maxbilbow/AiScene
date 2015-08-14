//
//  RMX.swift
//  RattleGL
//
//  Created by Max Bilbow on 17/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

import Foundation
import SceneKit

//public typealias RMXNode = SCNNode
public typealias AiBehaviour = (AnyObject!) -> Void

//public enum AiState { case MOVING, TURNING, IDLE }
//public enum PoppyState: Int32 { case IDLE = 1, READY_TO_CHASE , CHASING, FETCHING }
public enum RMXSpriteType: Int { case  AI = 0, PLAYER, BACKGROUND, PASSIVE, ABSTRACT, KINEMATIC, CAMERA }
public enum ShapeType: Int { case CUBE , SPHERE, CYLINDER, CYLINDER_FLOOR,  OILDRUM, BOBBLE_MAN, LAST,ROCK,SPACE_SHIP, PILOT,  PLANE, FLOOR, DOG, AUSFB,PONGO, NULL, SUN, CAMERA }
public enum KeyboardType { case French, UK, DEFAULT }


public struct RMX {

    public static var COUNT: Int = 0
}


public protocol RMXObject : NSObjectProtocol {
    var name: String? { get }
    var rmxID: Int? { get }
    var uniqueID: String? { get }
    var print: String { get }
}


public struct RMKeyValue {
    public static let name   = "name"
    public static let Sprite = "Sprite"
    public static let Health = "health"
    public static let Points = "points"
    public static let Kills  = "kills"
    public static let Deaths = "deaths"
}


public protocol RMSingleton {
//    static func current() -> Self!
//    static var current: Self! { get }
    init()
}
