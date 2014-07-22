//
//  ViewController.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 19/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit
import CoreData

let CellIdentifier = "CellIdentifier"


class ViewController: UITableViewController, CastControllerDelegate, UIPopoverPresentationControllerDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, SearchResultViewControllerDelegate {
  
  var searchController: UISearchController?
  
  lazy var fetchedResultsController: NSFetchedResultsController? = {
    
    let aFetchedResultsController = Item.fetchedResultsControllerForEntityNamed("Item", withPredicate:nil, sectionNameKey: nil, sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)])
    aFetchedResultsController!.delegate = self
    
    return aFetchedResultsController
  
    }()
  
  lazy var operationManager: OperationManager = {
    return OperationManager()
  }()
  
  let castController = CastController()
  
  
  var devicesBarButtonItem: UIBarButtonItem?
  
  
  var videos: Array<String> =  Array<String>()
                            
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    
    prepareSearchController()
    
    prepareView()
    
    scanDevices()
    
    operationManager.fetchFromUrl()

  }
  
  func scanDevices(){
    
    castController.scanDevices()
    
    castController.delegate = self
    
  }
  
  func prepareView(){
    
    tableView.rowHeight = UITableViewAutomaticDimension
    
    tableView.estimatedRowHeight = 44.0
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
    let barButtonItem = UIBarButtonItem(title: "Devices", style: .Plain, target: self, action: "showDevices:")
    
    navigationItem.rightBarButtonItem = barButtonItem
    
    devicesBarButtonItem = barButtonItem
    
    devicesBarButtonItem!.enabled = false
    
    let alertBarButtonItem = UIBarButtonItem(title: "Url", style: .Plain, target: self, action: "inputUrl:")
    
    navigationItem.leftBarButtonItem = alertBarButtonItem
    
  }
  
  func prepareSearchController(){
    
    let searchResultController = storyboard.instantiateViewControllerWithIdentifier("SearchResultViewController") as SearchResultViewController
    searchResultController.delegate = self
    
    
    searchController = UISearchController(searchResultsController: searchResultController)
    searchController!.searchResultsUpdater = self
    definesPresentationContext = true
    searchController!.searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 44.0)
    tableView.tableHeaderView = searchController!.searchBar
    
  }
  
  
  func inputUrl(sender: AnyObject!){
    
    let alertController = UIAlertController(title: "Provide the url to cast", message: nil, preferredStyle: .Alert)
    
    alertController.addTextFieldWithConfigurationHandler({
    
      (textField: UITextField!) in
      
        textField.placeholder = "http://developer.apple.com/202_hd_whats_new_in_cocoa_touch"
      
      })
    
    alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: {
      (alertAction: UIAlertAction!) in
      
      if(self.castController.selectedDevice){
        
        let theTextField =  alertController.textFields[0]  as UITextField
        
          let string = theTextField.text
        
          if !string.isEmpty{
            
            let count = Item.countForEntityNamed("Item", withPredicate: NSPredicate(format: "url = %@", string), inManagedObjectContext: CoreDataManager.manager().managedObjectContext)
            var item: Item
            
            if(count > 0){
            
              item = Item.findFirstEntityNamed("Item", withPredicate: NSPredicate(format: "url = %@", string), inManagedObjectContext: CoreDataManager.manager().managedObjectContext) as Item
              
            }else{
            
              item = Item.insertNewForEntityNamed("Item", inManagedObjectContext: CoreDataManager.manager().managedObjectContext) as Item
            
            
              item.url = string
            }
            
            var error : NSError?
            CoreDataManager.manager().managedObjectContext.save(&error)
            
            let playingViewController = self.storyboard.instantiateViewControllerWithIdentifier("PlayingViewController") as PlayingViewController
            
            playingViewController.item = item
            
            self.navigationController.pushViewController(playingViewController, animated: true)
            
            playingViewController.castController = self.castController
          
          }
        
        }
      
      }))
    
    presentViewController(alertController, animated: true, completion: nil)
    
  }
  
  func showDevices(button: UIBarButtonItem!){
    
    let devicePopoverViewController = DevicePopoverViewController()
    
    devicePopoverViewController.modalPresentationStyle = .Popover
    
    devicePopoverViewController.preferredContentSize = CGSize(width: 200, height: 150)
    
    devicePopoverViewController.castController = castController
    
    
    let popoverViewController = devicePopoverViewController.popoverPresentationController
    
    popoverViewController.permittedArrowDirections = .Any
    
    popoverViewController.barButtonItem = devicesBarButtonItem
    
    popoverViewController.delegate = self

    
    presentViewController(devicePopoverViewController, animated: true, completion: nil)
  }
  
  
  override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    
    if let selectedDevice = castController.selectedDevice{
      
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
      performSegueWithIdentifier("PlayingViewController", sender: fetchedResultsController?.fetchedObjects[indexPath.row])
    
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    
    if segue.identifier == "PlayingViewController"{
     
      let playingViewController = segue.destinationViewController as PlayingViewController
      
      playingViewController.item = sender as? Item
     
      playingViewController.castController = castController
    
    }
  }
  
  override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
    
    return fetchedResultsController!.fetchedObjects.count
    
  }
  
  override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
     return 99
  }
  
  override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as ItemTableViewCell
    
    
    let item = fetchedResultsController!.fetchedObjects[indexPath.row] as Item
    
    cell.setItem(item)
    
    return cell
  }
  
  override func tableView(tableView: UITableView!, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath!) {
    
    let item = self.fetchedResultsController?.fetchedObjects[indexPath.row] as Item

    let alertController = UIAlertController(title: "Name the video", message: nil, preferredStyle: .Alert)
    
    alertController.addTextFieldWithConfigurationHandler{
      (textField: UITextField!) in
      
      textField.placeholder = "My Video"
      
      if let title =  item.title{
        textField.text = title
      }
      
      
    }
    
    alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: {
      (alertAction: UIAlertAction!) in
      let theTextField =  alertController.textFields[0]  as UITextField
      
      let string = theTextField.text
      
        if !string.isEmpty{
          
          item.title = string
          CoreDataManager.manager().managedObjectContext.save(nil)
        }
      }))
    presentViewController(alertController, animated: true, completion: nil)
    
  }
  

  func castController(castController: CastController, didChangeDevices devices: [GCKDevice]) {
    
    devicesBarButtonItem!.enabled = devices.count > 0
    
  }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle{
    
    return .None
  
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController!) {
    tableView.reloadData()
  }
  
  func updateSearchResultsForSearchController(searchController: UISearchController!) {
    let searchResultController = searchController.searchResultsController as SearchResultViewController
    
    searchResultController.searchString = searchController.searchBar.text
    
    
  }
  
   func searchResultViewController(viewController: SearchResultViewController!, didSelectItem item: Item!) {
    performSegueWithIdentifier("PlayingViewController", sender: item)

  }

}

