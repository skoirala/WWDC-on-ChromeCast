//
//  DevicePopoverViewController.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 19/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit


protocol DevicePopoverViewControllerDelegate: NSObjectProtocol{
  
  func devicePopoverViewControllerDidSelectAirPlay(viewController: DevicePopoverViewController!)
  func devicePopoverViewControllerDidSelectDefaultDevice(viewController: DevicePopoverViewController)
  func devicePopoverViewControllerDidSelectDevice(device: GCKDevice)
  
}

class DevicePopoverViewController: UITableViewController {
  
  
  var delegate: DevicePopoverViewControllerDelegate?
  
  var castController: CastController?
  let cellIdentifier = "CellIdentifier"
  
  var devices: [String] = ["Default", "Airplay"]
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    
  }
  
  
  
  override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
    return devices.count
//    return castController!.allFoundDevices.count
  }
  
  
  override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
    
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
    
    if indexPath.row == 0{
      cell.accessoryType = .Checkmark
    }else{
      cell.accessoryType = .None
    }
    cell.textLabel.text = "\(devices[indexPath.row])"
    return cell
  }
  
  override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    
    if indexPath.row == 0{
      delegate?.devicePopoverViewControllerDidSelectDefaultDevice(self)
    }else if indexPath.row == 1{
      delegate?.devicePopoverViewControllerDidSelectAirPlay(self)
    }
//    
//    let device = castController!.allFoundDevices[indexPath.row]
//    
//    castController!.selectDevice(device)
    
    dismissViewControllerAnimated(true, completion: nil)
    
  }
  
  
}
