//
//  Device.swift
//  Cast My Videos
//
//  Created by Sandeep on 1/15/15.
//  Copyright (c) 2015 caster. All rights reserved.
//

import UIKit

enum DeviceType: String
{
    case DeviceTypeDefault = "Default"
    case DeviceTypeAirplay = "Airplay"
    case DeviceTypeChromeCast = "ChromeCast"
}

protocol Device
{
    var deviceType: DeviceType { get }

    func name() -> String
    func play()
    func pause()
    func seekToInterval()
}