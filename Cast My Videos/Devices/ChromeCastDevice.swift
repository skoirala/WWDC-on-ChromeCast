
import UIKit

class ChromeCastDevice:NSObject, Device
{
    let device: GCKDevice

    let controller: CastController

    var deviceType:DeviceType {
        return DeviceType.DeviceTypeChromeCast
    }

    init(device: GCKDevice, chromCastController controller: CastController)
    {
        self.device = device
        self.controller = controller
    }

    func name() -> String
    {
        return self.device.friendlyName
    }

    func play()
    {

    }

    func pause()
    {

    }
    
    func seekToInterval()
    {
        
    }
    
}
