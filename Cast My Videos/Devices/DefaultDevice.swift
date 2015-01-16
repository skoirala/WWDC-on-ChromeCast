
import UIKit

import AVFoundation

class DefaultDevice: NSObject, Device
{

    var deviceType:DeviceType {
        return DeviceType.DeviceTypeDefault
    }

    var player: AVPlayer?

    func name() -> String
    {
        return "Default"
    }

    func seekToInterval()
    {

    }

    func pause()
    {
        player?.play()
    }

    func play()
    {
        player?.pause()
    }
}
