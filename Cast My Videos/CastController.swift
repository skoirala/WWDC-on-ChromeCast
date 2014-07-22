//
//  CastController.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 19/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit

protocol CastControllerDelegate{
  func castController(castController: CastController, didChangeDevices devices: [GCKDevice]);
}


class CastController: NSObject, GCKDeviceScannerListener, GCKDeviceManagerDelegate, GCKMediaControlChannelDelegate {
  
  
  var selectedDevice: GCKDevice?
  
  var delegate: CastControllerDelegate?
  
  let deviceScanner: GCKDeviceScanner!
  let mediaControlChannel: GCKMediaControlChannel!
  
  var deviceManager: GCKDeviceManager?
  
  var allFoundDevices = Array<GCKDevice>()

  init(){
    deviceScanner = GCKDeviceScanner()
    mediaControlChannel = GCKMediaControlChannel()
    super.init()
    mediaControlChannel.delegate = self
  }
  
  func seekToTimeInterval(time: Float64){
    mediaControlChannel.seekToTimeInterval(time)
  }
  
  func scanDevices(){
    deviceScanner.addListener(self)
    deviceScanner.startScan()
  }
  
  func selectDevice(device: GCKDevice!){
    let dict = NSBundle.mainBundle().infoDictionary as NSDictionary
    deviceManager = GCKDeviceManager(device: device, clientPackageName: dict["CFBundleIdentifier"] as String)
    selectedDevice = device
    deviceManager!.delegate = self
    deviceManager?.connect()
  }
  
  func playVideo(string: String!){
    
    let metadata = GCKMediaMetadata()
    metadata.setString(string.componentsSeparatedByString("_").bridgeToObjectiveC().componentsJoinedByString(" "), forKey: kGCKMetadataKeyTitle)
      
    
    let mediaInformation  = GCKMediaInformation(contentID: string, streamType: GCKMediaStreamType.None, contentType: "video/mp4", metadata: metadata, streamDuration: 0, mediaTracks: nil, textTrackStyle: nil, customData: nil)
    
    
    
    
    deviceManager?.addChannel(mediaControlChannel)
      
    if mediaControlChannel.requestStatus() != kGCKInvalidRequestID{
      playMedia(mediaInformation, fromDuration: 0)
    }
    
  }
  
  func playMedia(media: GCKMediaInformation!, fromDuration duration: Double){
    mediaControlChannel.loadMedia(media, autoplay: true, playPosition: duration)

  }
  
  func playVideo(string: String!, fromTime time: Double){
    let metadata = GCKMediaMetadata()
    metadata.setString(string.componentsSeparatedByString("_").bridgeToObjectiveC().componentsJoinedByString(" "), forKey: kGCKMetadataKeyTitle)
    
    
    let mediaInformation  = GCKMediaInformation(contentID: string, streamType: GCKMediaStreamType.None, contentType: "video/mp4", metadata: metadata, streamDuration: 0, mediaTracks: nil, textTrackStyle: nil, customData: nil)
    
    
    
    
    deviceManager?.addChannel(mediaControlChannel)
  
    if mediaControlChannel.requestStatus() != kGCKInvalidRequestID{
      playMedia(mediaInformation, fromDuration: time)
    }
  }
  func pause(){
    mediaControlChannel.pause()
  }
  
  // GCKDeviceScannerDelegate
  
  func deviceDidComeOnline(device: GCKDevice!) {
    let existing = allFoundDevices.filter({ device.deviceID == $0.deviceID})
    
    if existing.count == 0{
      println("Device Found \(device.friendlyName)")
      allFoundDevices += device
    }
    
    delegate?.castController(self, didChangeDevices: allFoundDevices)
    
  }
  
  func deviceDidGoOffline(device: GCKDevice!) {
    let existing = allFoundDevices.filter({ device.deviceID == $0.deviceID})
    if existing.count > 0{
      allFoundDevices = allFoundDevices.filter({device.deviceID != $0.deviceID})
    }
    delegate?.castController(self, didChangeDevices: allFoundDevices)

  }
  
  // GCKDeviceManagerDelegate
  
  
  let receiverId = "5AEF9E81"
  
  func deviceManagerDidConnect(deviceManager: GCKDeviceManager!) {
      deviceManager.launchApplication(receiverId)
  }
  
  
  func mediaControlChannelDidUpdateMetadata(mediaControlChannel: GCKMediaControlChannel!) {
   println("Updated metadata \(mediaControlChannel.approximateStreamPosition())")
  }
  
  func mediaControlChannelDidUpdateStatus(mediaControlChannel: GCKMediaControlChannel!) {
    println("Updated channel updated status \(mediaControlChannel.approximateStreamPosition())")
  }
  
  func deviceManager(deviceManager: GCKDeviceManager!, didReceiveStatusForApplication applicationMetadata: GCKApplicationMetadata!) {
      println("received status for application \(applicationMetadata)")
    
  }
  

  
}
