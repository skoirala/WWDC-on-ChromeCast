//
//  CastController.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 19/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit

extension String.CharacterView: Equatable {
    
}

public func ==(character1: String.CharacterView, character2: String.CharacterView) -> Bool {
    return String(character1) == String(character2)
}

let ChromeCastDeviceDidBecomeOnlineNotification = "ChromeCastDeviceDidComeOnlineNotification"
let ChromeCastDeviceDidBecomeOfflineNotification = "ChromeCastDeviceDidBecomeOfflineNotification"
let receiverId = "5AEF9E81"

class CastController: NSObject, GCKDeviceScannerListener, GCKDeviceManagerDelegate, GCKMediaControlChannelDelegate
{
    var selectedDevice: GCKDevice?

    let deviceScanner: GCKDeviceScanner!
    let mediaControlChannel: GCKMediaControlChannel!

    var deviceManager: GCKDeviceManager?

    var allFoundDevices: [ChromeCastDevice] = [ChromeCastDevice]()

    override init()
    {
        deviceScanner = GCKDeviceScanner()
        mediaControlChannel = GCKMediaControlChannel()
        super.init()
        mediaControlChannel.delegate = self
    }

    func seekToTimeInterval(time: Float64)
    {
        mediaControlChannel.seekToTimeInterval(time)
    }

    func scanDevices()
    {
        deviceScanner.addListener(self)
        deviceScanner.startScan()
    }

    func selectDevice(device: GCKDevice!)
    {
        if let dict = NSBundle.mainBundle().infoDictionary as NSDictionary? {
            deviceManager = GCKDeviceManager(device: device, clientPackageName: dict["CFBundleIdentifier"] as! String)
            selectedDevice = device
            deviceManager!.delegate = self
            deviceManager?.connect()
        }
    }

    func playVideo(string: String!)
    {
        let metadata = GCKMediaMetadata()
        let joinedString = string.characters.split(isSeparator: { $0 == "_"}).map(String.init).joinWithSeparator(" ")
        
        metadata.setString(joinedString, forKey: kGCKMetadataKeyTitle)


        let mediaInformation  = GCKMediaInformation(
            contentID: string,
            streamType: GCKMediaStreamType.None,
            contentType: "video/mov",
            metadata: metadata,
            streamDuration: 0,
            mediaTracks: nil,
            textTrackStyle: nil,
            customData: nil
        )
        
        deviceManager?.addChannel(mediaControlChannel)

        if mediaControlChannel.requestStatus() != kGCKInvalidRequestID {
            playMedia(mediaInformation, fromDuration: 0)
        }

    }

    func playMedia(
        media: GCKMediaInformation!,
        fromDuration duration: Double
        )
    {
        mediaControlChannel.loadMedia(media, autoplay: true, playPosition: duration)

    }

    func playVideo(string: String!, fromTime time: Double)
    {
        let metadata = GCKMediaMetadata()
        let joinedString = string.characters.split(isSeparator: { "_" == $0}).map(String.init).joinWithSeparator(" ")
            
        metadata.setString(joinedString, forKey: kGCKMetadataKeyTitle)

        let mediaInformation  = GCKMediaInformation(
            contentID: string,
            streamType: GCKMediaStreamType.None,
            contentType: "video/mp4",
            metadata: metadata,
            streamDuration: 0,
            mediaTracks: nil,
            textTrackStyle: nil,
            customData: nil
        )

        deviceManager?.addChannel(mediaControlChannel)

        if mediaControlChannel.requestStatus() != kGCKInvalidRequestID {
            playMedia(mediaInformation, fromDuration: time)
        }
    }
    func pause()
    {
        mediaControlChannel.pause()
    }

    // GCKDeviceScannerDelegate

    func deviceDidComeOnline(device: GCKDevice!)
    {
        let existing = allFoundDevices.filter(
            { device.deviceID == $0.device.deviceID }
        )

        if existing.count == 0 {
            print("Device Found \(device.friendlyName)")
            let device = ChromeCastDevice(
                device: device,
                chromCastController: self
            )

            allFoundDevices.append(device)

            NSNotificationCenter.defaultCenter().postNotificationName(
                ChromeCastDeviceDidBecomeOnlineNotification
                , object: self,
                userInfo: nil
            )

        }


        //    delegate?.castController(self, didChangeDevices: allFoundDevices)

    }

    func deviceDidGoOffline(device: GCKDevice!)
    {
        let existing = allFoundDevices.filter(
            { device.deviceID == $0.device.deviceID}
        )
        if existing.count > 0 {
            allFoundDevices = allFoundDevices.filter(
                {device.deviceID != $0.device.deviceID}
            )
        }
        NSNotificationCenter.defaultCenter().postNotificationName(
            ChromeCastDeviceDidBecomeOfflineNotification,
            object: self,
            userInfo: nil
        )
        //    delegate?.castController(self, didChangeDevices: allFoundDevices)

    }

    // GCKDeviceManagerDelegate

    func deviceManagerDidConnect(deviceManager: GCKDeviceManager!)
    {
        deviceManager.launchApplication(receiverId)
    }

    func mediaControlChannelDidUpdateMetadata(
        mediaControlChannel: GCKMediaControlChannel!
        )
    {
        print("Updated metadata \(mediaControlChannel.approximateStreamPosition())")
    }
    
    func mediaControlChannelDidUpdateStatus(
        mediaControlChannel: GCKMediaControlChannel!
        )
    {
        print("Updated channel updated status \(mediaControlChannel.approximateStreamPosition())")
    }
    
    func deviceManager(deviceManager: GCKDeviceManager!,
        didReceiveStatusForApplication applicationMetadata: GCKApplicationMetadata!
        )
    {
        print("received status for application \(applicationMetadata)")
        
    }
}
