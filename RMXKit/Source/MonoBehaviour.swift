//
//  MonoBehaviour.swift
//  RMXKit
//
//  Created by Max Bilbow on 16/07/2015.
//  Copyright © 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation

extension Mono {
    public class MonoBehaviour : Mono.Component, IBehaviour {
     
        /// Disabling this lets you skip the GUI layout phase.
        var useGUILayout: Bool = false
        ///	Cancels all Invoke calls on this MonoBehaviour.
        public func CancelInvoke() {}
        ///	Invokes the method methodName in time seconds.
        public func Invoke() {}
        ///	Invokes the method methodName in time seconds, then repeatedly every repeatRate seconds.
        public func InvokeRepeating() {}
        ///	Is any invoke on methodName pending?
        public func IsInvoking()  -> Bool { return false }
        ///	Starts a coroutine.
        public func StartCoroutine() {}
        ///	Stops all coroutines running on this behaviour.
        public func StopAllCoroutines() {}
        ///	Stops a coroutine running on this behaviour.
        public func StopCoroutine() {}
    }
}
