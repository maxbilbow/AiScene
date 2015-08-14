//
//  main.swift
//  RMXUnity
//
//  Created by Max Bilbow on 17/07/2015.
//  Copyright © 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation
////import RMXKit

print("start")


let max = Mono.GameObject(named: "Max")

var array: [Mono.GameObject] = [ max ]
max.AddComponent(DieWhenTouched)

class Test {
    var testListCount = 0
    func printAll(list: Bool = false) {

        print("\n---ALL OBJECTS (List \(++testListCount)), Total \(Mono.GameObject.gameObjects.count) : \(array.count) ---")
        
        
        if list {
            let ptr = UnsafeMutablePointer<NSObject>.alloc(sizeof(NSObject))
            ptr.initialize(max)
            var output: String = String(format:"   FIRST: %@, %p", array.first!, ptr)
            var i = 0
            for object in Mono.GameObject.gameObjects {
                
                ptr.memory = object.1
        //        print(object)
                output += String(format: "\n   %@ / %@, %p",object.0, ptr.memory, ptr)
                let dict = ptr.memory as! Mono.GameObject
                let comp = dict !== array[i] ? "!==" : "==="
                ptr.memory = array[i]
                output += String(format: " \(comp) %@, %p", ptr.memory, ptr)
                ++i
            }
            print(output)
        }
        
    }

    func main() {
        printAll()

        array.append(Mono.GameObject())
        printAll()

        array.append(Mono.GameObject())
        printAll()

        array.append(Mono.GameObject())
        printAll()

        array.append(max.clone() as! Mono.GameObject)
        printAll()

        array.append(max.clone() as! Mono.GameObject)
        printAll(true)
    }

}

Test().main()
