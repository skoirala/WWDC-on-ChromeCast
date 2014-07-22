//
//  DevicePopoverViewController.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 19/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit

class DevicePopoverViewController: UITableViewController {
  
  var castController: CastController?
  let cellIdentifier = "CellIdentifier"
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    
  }
  
  
  
  override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
    return castController!.allFoundDevices.count
  }
  
  
  override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
    
    let device = castController!.allFoundDevices[indexPath.row]
    
    if let selected = castController!.selectedDevice{
      
      if selected.deviceID == device.deviceID{
        
        cell.accessoryType = .Checkmark
        
      }else{
        
        cell.accessoryType = .None
        
      }
      
    }else{
      
      cell.accessoryType = .None
      
    }
    
    
    cell.textLabel.text = castController!.allFoundDevices[indexPath.row].friendlyName
    return cell
  }
  
  override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    
    let device = castController!.allFoundDevices[indexPath.row]
    
    castController!.selectDevice(device)
    
    dismissViewControllerAnimated(true, completion: nil)
    
  }
  
  
}
