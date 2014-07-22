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
  
  @lazy var fetchedResultsController: NSFetchedResultsController? = {
    
    let aFetchedResultsController = Item.fetchedResultsControllerForEntityNamed("Item", withPredicate:nil, sectionNameKey: nil, sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)])
    aFetchedResultsController!.delegate = self
    
    return aFetchedResultsController
  
    }()
  
  
  let castController = CastController()
  
  @lazy var operationQueue: NSOperationQueue = {
    let operationQueue = NSOperationQueue()
    operationQueue.maxConcurrentOperationCount = 4
    return operationQueue
  }()
  

  
  var devicesBarButtonItem: UIBarButtonItem?
  
  
  var videos: Array<String> =  Array<String>()
                            
  override func viewDidLoad() {
    
    
    super.viewDidLoad()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    tableView.tableFooterView = UIView(frame: CGRectZero)
    
    prepareSearchController()
    
    CoreDataManager.manager()

    
    castController.scanDevices()
    
    castController.delegate = self
    
    let barButtonItem = UIBarButtonItem(title: "Devices", style: .Plain, target: self, action: "showDevices:")
    
    navigationItem.rightBarButtonItem = barButtonItem
    
    devicesBarButtonItem = barButtonItem
    
    devicesBarButtonItem!.enabled = false
    
    let alertBarButtonItem = UIBarButtonItem(title: "Url", style: .Plain, target: self, action: "inputUrl:")
    
    navigationItem.leftBarButtonItem = alertBarButtonItem
    
    
    fetchFromUrl()
    

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
  
  func fetchFromUrl() {
    
    operationQueue.waitUntilAllOperationsAreFinished()

    let networkOperation2014: NetworkOperation = NetworkOperation(urlString: "https://developer.apple.com/videos/wwdc/2014/")
    
    
    let parseOperation2014 = ParseOperation()
    parseOperation2014.addDependency(networkOperation2014)
    
    networkOperation2014.completionBlock = {
      parseOperation2014.response = networkOperation2014.responseString
    }
    
    
    operationQueue.addOperations([networkOperation2014, parseOperation2014], waitUntilFinished: false)
    
    
    let saveOperation2014 = SaveOperation(managedObjectContext: CoreDataManager.manager().managedObjectContext)
    saveOperation2014.year = "2014"

    saveOperation2014.addDependency(parseOperation2014)
    
    parseOperation2014.completionBlock = {
      saveOperation2014.responseDictionary = parseOperation2014.responseArray

    }
    
    operationQueue.addOperation(saveOperation2014)
    
    
    
    
    
    let networkOperation2013: NetworkOperation = NetworkOperation(urlString: "https://developer.apple.com/videos/wwdc/2013/")
    
    networkOperation2013.addDependency(saveOperation2014)
    
    let parseOperation2013 = ParseOperation()
    parseOperation2013.addDependency(networkOperation2013)
    
    networkOperation2013.completionBlock = {
      parseOperation2013.response = networkOperation2013.responseString
    }
    
    
    operationQueue.addOperations([networkOperation2013, parseOperation2013], waitUntilFinished: false)
    
    
    let saveOperation2013 = SaveOperation(managedObjectContext: CoreDataManager.manager().managedObjectContext)
    saveOperation2013.year = "2013"
    
    saveOperation2013.addDependency(parseOperation2013)
    
    parseOperation2013.completionBlock = {
      saveOperation2013.responseDictionary = parseOperation2013.responseArray
      
    }
    
    operationQueue.addOperation(saveOperation2013)

  
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

