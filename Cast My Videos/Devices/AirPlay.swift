

import UIKit
import AVFoundation

class AirPlay: NSObject, Device
{

    var player: AVPlayer?

    var deviceType:DeviceType {
        return DeviceType.DeviceTypeAirplay
    }

    func name() -> String
    {
        return "Airplay"
    }

    func play()
    {
        player?.play()
    }

    func pause()
    {
        player?.pause()
    }

    func seekToInterval()
    {
        
    }
}
