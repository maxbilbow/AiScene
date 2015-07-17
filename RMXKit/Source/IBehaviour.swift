//
//  MonoBehaviour.swift
//  RMXKit
//
//  Created by Max Bilbow on 16/07/2015.
//  Copyright © 2015 Rattle Media Ltd. All rights reserved.
//

import Foundation

//extension Mono {
@objc public protocol IBehaviour : NSObjectProtocol {
    
    //Messages
    ///	Awake is called when the script instance is being loaded.
    optional func Awake()
    ///	This function is called every fixed framerate frame, if the MonoBehaviour is enabled.
    optional func FixedUpdate()
    /// LateUpdate is called every frame, if the Behaviour is enabled.
    optional func LateUpdate()
    /// Callback for setting up animation IK (inverse kinematics).
    optional func OnAnimatorIK()
    ///	Callback for processing animation movements for modifying root motion.
    optional func OnAnimatorMove()
    ///	Sent to all game objects when the player gets or loses focus.
    optional func OnApplicationFocus()
    /// Sent to all game objects when the player pauses.
    optional func OnApplicationPause()
    /// Sent to all game objects before the application is quit.
    optional func OnApplicationQuit()
    ///	If OnAudioFilterRead is implemented, Unity will insert a custom filter into the audio DSP chain.
    optional func OnAudioFilterRead()
    ///	OnBecameInvisible is called when the renderer is no longer visible by any camera.
    optional func OnBecameInvisible()
    /// OnBecameVisible is called when the renderer became visible by any camera.
    optional func OnBecameVisible()
    /// OnCollisionEnter is called when this collider/rigidbody has begun touching another rigidbody/collider.
    optional func OnCollisionEnter()
    /// Sent when an incoming collider makes contact with this object's collider (2D physics only).
    optional func OnCollisionEnter2D()
    ///	OnCollisionExit is called when this collider/rigidbody has stopped touching another rigidbody/collider.
    optional func OnCollisionExit()
    /// Sent when a collider on another object stops touching this object's collider (2D physics only).
    optional func OnCollisionExit2D()
    /// OnCollisionStay is called once per frame for every collider/rigidbody that is touching rigidbody/collider.
    optional func OnCollisionStay()
    ///	Sent each frame where a collider on another object is touching this object's collider (2D physics only).
    optional func OnCollisionStay2D()
    /// Called on the client when you have successfully connected to a server.
    optional func OnConnectedToServer()
    /// OnControllerColliderHit is called when the controller hits a collider while performing a Move.
    optional func OnControllerColliderHit()
    ///	This function is called when the MonoBehaviour will be destroyed.
    optional func OnDestroy()
    /// This function is called when the behaviour becomes disabled () or inactive.
    optional func OnDisable()
    /// Called on the client when the connection was lost or you disconnected from the server.
    optional func OnDisconnectedFromServer()
    /// Implement OnDrawGizmos if you want to draw gizmos that are also pickable and always drawn.
    optional func OnDrawGizmos()
    /// Implement this OnDrawGizmosSelected if you want to draw gizmos only if the object is selected.
    optional func OnDrawGizmosSelected()
    /// This function is called when the object becomes enabled and active.
    optional func OnEnable()
    /// Called on the client when a connection attempt fails for some reason.
    optional func OnFailedToConnect()
    /// Called on clients or servers when there is a problem connecting to the MasterServer.
    optional func OnFailedToConnectToMasterServer()
    /// OnGUI is called for rendering and handling GUI events.
    optional func OnGUI()
    /// Called when a joint attached to the same game object broke.
    optional func OnJointBreak()
    ///	This function is called after a new level was loaded.
    optional func OnLevelWasLoaded()
    /// Called on clients or servers when reporting events from the MasterServer.
    optional func OnMasterServerEvent()
    ///	OnMouseDown is called when the user has pressed the mouse button while over the GUIElement or Collider.
    optional func OnMouseDown()
    /// OnMouseDrag is called when the user has clicked on a GUIElement or Collider and is still holding down the mouse.
    optional func OnMouseDrag()
    /// Called when the mouse enters the GUIElement or Collider.
    optional func OnMouseEnter()
    /// Called when the mouse is not any longer over the GUIElement or Collider.
    optional func OnMouseExit()
    /// Called every frame while the mouse is over the GUIElement or Collider.
    optional func OnMouseOver()
    /// OnMouseUp is called when the user has released the mouse button.
    optional func OnMouseUp()
    /// OnMouseUpAsButton is only called when the mouse is released over the same GUIElement or Collider as it was pressed.
    optional func OnMouseUpAsButton()
    /// Called on objects which have been network instantiated with Network.Instantiate.
    optional func OnNetworkInstantiate()
    /// OnParticleCollision is called when a particle hits a collider.
    optional func OnParticleCollision()
    /// Called on the server whenever a new player has successfully connected.
    optional func OnPlayerConnected()
    /// Called on the server whenever a player disconnected from the server.
    optional func OnPlayerDisconnected()
    /// OnPostRender is called after a camera finished rendering the scene.
    optional func OnPostRender()
    /// OnPreCull is called before a camera culls the scene.
    optional func OnPreCull()
    /// OnPreRender is called before a camera starts rendering the scene.
    optional func OnPreRender()
    /// OnRenderImage is called after all rendering is complete to render image.
    optional func OnRenderImage()
    /// OnRenderObject is called after camera has rendered the scene.
    optional func OnRenderObject()
    /// Used to customize synchronization of variables in a script watched by a network view.
    optional func OnSerializeNetworkView()
    /// Called on the server whenever a Network.InitializeServer was invoked and has completed.
    optional func OnServerInitialized()
    /// This function is called when the list of children of the transform of the GameObject has changed.
    optional func OnTransformChildrenChanged()
    /// This function is called when the parent property of the transform of the GameObject has changed.
    optional func OnTransformParentChanged()
    /// OnTriggerEnter is called when the Collider other enters the trigger.
    optional func OnTriggerEnter()
    /// Sent when another object enters a trigger collider attached to this object (2D physics only).
    optional func OnTriggerEnter2D()
    /// OnTriggerExit is called when the Collider other has stopped touching the trigger.
    optional func OnTriggerExit()
    /// Sent when another object leaves a trigger collider attached to this object (2D physics only).
    optional func OnTriggerExit2D()
    /// OnTriggerStay is called once per frame for every Collider other that is touching the trigger.
    optional func OnTriggerStay()
    /// Sent each frame where another object is within a trigger collider attached to this object (2D physics only).
    optional func OnTriggerStay2D()
    /// This function is called when the script is loaded or a value is changed in the inspector (Called in the editor only).
    optional func OnValidate()
    /// OnWillRenderObject is called once for each camera if the object is visible.
    optional func OnWillRenderObject()
    /// Reset to default values.
    optional func Reset()
    /// Start is called on the frame when a script is enabled just before any of the Update methods is called the first time.
    optional func Start()
    /// Update is called every frame, if the MonoBehaviour is enabled.
    optional func Update()
}
