//
//  NotificationCenter.swift
//  AiScene
//
//  Created by Max Bilbow on 28/07/2015.
//  Copyright © 2015 Rattle Media. All rights reserved.
//

import Foundation
public class MXNotificationCenter {
    //		static List<EventListener> _listeners = new List<EventListener> ();
    //
    static var listeners: Array<MXEventListener> = Array<MXEventListener> ()
    
    static var events: Dictionary<Any,EventStatus> = Dictionary<Any,EventStatus>();
    
    
    //		static Dictionary<IEvent,EventStatus> Events {
    //			get {
    //				return _events;
    //			}
    //		}
    //
    
    
    
    
    
    public static bool HasListener(EventListener listener) {
        return Listeners.Contains (listener);
    }
    public static void Reset(System.Enum theEvent) {
    Events[theEvent] = EventStatus.Idle;
    }
    
    public static void AddListener(EventListener listener) {
    if (!Listeners.Contains (listener)) {
				Listeners.Add(listener);
				if (Bugger.WillLog (RMXTests.EventCenter, listener.GetType () + " was added to Listeners (" + Listeners.Count + ")"))
    Debug.Log (Bugger.Last);
    }
    }
    
    public static void RemoveListener(EventListener listener) {
    if (Listeners.Contains (listener))
				if (!Listeners.Remove (listener))
    throw new System.Exception (listener.name + " exists but could not be removed from Listeners");
    }
    
    public static EventStatus StatusOf(System.Enum theEvent) {
    return Events.ContainsKey(theEvent) ? Events [theEvent] : EventStatus.Idle;
    }
    
    public static bool IsIdle(System.Enum theEvent) {
    return StatusOf (theEvent) == EventStatus.Idle;
    }
    
    public static bool IsActive(System.Enum theEvent) {
    return StatusOf (theEvent) == EventStatus.Active;
    }
    
    public static void EventDidOccur(System.Enum e) {
    EventDidOccur (e, null);
    }
    
    public static void EventDidOccur(System.Enum theEvent, object o) {
    Events [theEvent] = o is EventStatus ? (EventStatus) o : EventStatus.Completed;
    foreach (EventListener listener in Listeners) {
				listener.OnEvent(theEvent,o);
    }
    }
    
    
    public static bool WasCompleted(System.Enum theEvent) {
    return StatusOf (theEvent) == EventStatus.Completed;
    }
    
    public static void EventWillStart(System.Enum theEvent) {
    EventWillStart (theEvent, null);
    }
    
    public static void EventWillStart(System.Enum theEvent, object o) {
    if (!IsActive (theEvent)) {
				Events [theEvent] = o is EventStatus ? (EventStatus) o : EventStatus.Active;
				foreach (EventListener listener in Listeners) {
    listener.OnEventDidStart (theEvent, o);
				}
    }
    }
    public static void EventDidEnd(System.Enum theEvent) {
    EventDidEnd (theEvent, null);
    }
    public static void EventDidEnd(System.Enum theEvent, object o) {
    Events [theEvent] = Events [theEvent] = o is EventStatus ? (EventStatus) o : EventStatus.Completed;
    foreach (EventListener listener in Listeners) {
				listener.OnEventDidEnd(theEvent,o);
    }
    }
    
    public static void NotifyListeners(string message) {
    foreach (EventListener listener in Listeners) {
				listener.SendMessage (message, SendMessageOptions.DontRequireReceiver);
    }
    }
    
    
    
}