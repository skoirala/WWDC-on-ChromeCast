//
//  DevicePopoverViewController.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 19/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit


protocol DevicePopoverViewControllerDelegate: NSObjectProtocol
{
    func devicePopoverViewControllerDidSelectAirPlay(viewController: DevicePopoverViewController!)
    func devicePopoverViewControllerDidSelectDefaultDevice(viewController: DevicePopoverViewController)
    func devicePopoverViewControllerDidSelectDevice(device: GCKDevice)
}

class DevicePopoverViewController: UITableViewController
{
    let cellIdentifier = "CellIdentifier"

    var delegate: DevicePopoverViewControllerDelegate?
    var castController: CastController?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.registerClass(
            UITableViewCell.self,
            forCellReuseIdentifier: cellIdentifier
        )
    }

    override func tableView(
        tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int
    {
        return DeviceManager.sharedManager().allDevices().count
        //    return castController!.allFoundDevices.count
    }

    override func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
        ) -> UITableViewCell
    {

        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        //
        //    let device = castController!.allFoundDevices[indexPath.row]
        //
        //    if let selected = castController!.selectedDevice{
        //
        //      if selected.deviceID == device.deviceID{
        //
        //        cell.accessoryType = .Checkmark
        //
        //      }else{
        //
        //        cell.accessoryType = .None
        //
        //      }
        //
        //    }else{
        //
        //      cell.accessoryType = .None
        //
        //    }
        //
        //
        //    cell.textLabel.text = castController!.allFoundDevices[indexPath.row].friendlyName

        if indexPath.row == 0 {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        let aDevice  = DeviceManager.sharedManager().allDevices()[indexPath.row]
        cell.textLabel?.text = "\(aDevice.name())"
        return cell
    }

    override func tableView(
        tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath
        ) {
        if indexPath.row == 0 {
            delegate?.devicePopoverViewControllerDidSelectDefaultDevice(self)
        } else if indexPath.row == 1 {
            delegate?.devicePopoverViewControllerDidSelectAirPlay(self)
        } 
        //    
        //    let device = castController!.allFoundDevices[indexPath.row]
        //    
        //    castController!.selectDevice(device)
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
}
