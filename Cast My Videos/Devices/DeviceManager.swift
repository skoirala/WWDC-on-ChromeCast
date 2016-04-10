

import UIKit

class DeviceManager: NSObject
{
    private lazy var castController = CastController()

    private var selectedDevice: Device?

    func play()
    {
        selectedDevice?.play()
    }

    func pause()
    {
        selectedDevice?.pause()
    }

    func seekToInterval()
    {

    }

    func allDevices() -> [Device]
    {
        var allDevices = [Device]()
        allDevices.append(DefaultDevice())
        allDevices.append(AirPlay())
        for aDevice in castController.allFoundDevices {
            allDevices.append(aDevice)
        }
        return allDevices
    }

    class func sharedManager() -> DeviceManager
    {
        struct SingletonHandler
        {
            static let deviceManager = DeviceManager()

            static func manager () -> DeviceManager
            {
                return deviceManager
            }
        }

        return SingletonHandler.manager()
    }

    override init()
    {
        super.init()
        registerForChromeCastDeviceNotification()
        registerForAirplayDeviceNotification()
    }

    func beginScanning()
    {
        castController.scanDevices()
    }

    private func registerForChromeCastDeviceNotification()
    {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "chromeCastDeviceDidConnect:",
            name: ChromeCastDeviceDidBecomeOnlineNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "chromeCastDeviceDidDisconnect:",
            name: ChromeCastDeviceDidBecomeOfflineNotification,
            object: nil
        )
    }

    private func registerForAirplayDeviceNotification()
    {
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: "externalDeviceDidConnect:",
            name: UIScreenDidConnectNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "externalDeviceDidDisconnect:",
            name: UIScreenDidDisconnectNotification,
            object: nil
        )
    }

    func externalDeviceDidConnect(notification: NSNotification)
    {
        print("External device connected")
    }

    func externalDeviceDidDisconnect(notification: NSNotification)
    {
        print("External device disconnected")
    }

    func chromeCastDeviceDidConnect(notification: NSNotification)
    {
        print("ChromeCast device connected")
    }

    private func chromeCastDeviceDidDisconnect(notification: NSNotification)
    {
        print("ChromeCast device disconnected")
    }

    func deviceDidBecomeOnline(notification: NSNotification)
    {
        print(self.castController.allFoundDevices)
    }

    func deviceDidBecomeOfflineNotification(
        notification: NSNotification
    )
    {
        print(self.castController.allFoundDevices)
    }
}
