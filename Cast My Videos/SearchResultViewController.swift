//
//  SearchResultViewController.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 22/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit
import CoreData


protocol SearchResultViewControllerDelegate{
  func searchResultViewController(viewController: SearchResultViewController!, didSelectItem item: Item!)
}

class SearchResultViewController: UITableViewController, NSFetchedResultsControllerDelegate {

  
  
  let CellIdentifier = "CellIdentifier"
  
  var delegate: SearchResultViewControllerDelegate?
  
 
  
  lazy var fetchedResultsController: NSFetchedResultsController? =  {
    var predicate: NSPredicate? = nil
    
    let fetchRequest = NSFetchRequest(entityName: "Item")
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.manager().managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    
    fetchedResultsController.delegate = self
    fetchedResultsController.performFetch(nil)
      return fetchedResultsController
  }()

  var searchString: String?{
    didSet{
      var predicate: NSPredicate? = nil

      if let theSearchTerm = searchString{
        predicate =     NSPredicate(format: "title contains[cd] %@ or content contains[cd] %@ or year contains[cd] %@" , theSearchTerm, theSearchTerm, theSearchTerm )
        
      }
      fetchedResultsController!.fetchRequest.predicate = predicate
      fetchedResultsController?.performFetch(nil)
      tableView.reloadData()
    }
  }

  
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    
    
    tableView.tableFooterView = UIView(frame: CGRectZero)
        
    let effect = UIBlurEffect(style: .ExtraLight)
    let blurredView = UIVisualEffectView(effect: effect)
    
    
    tableView.backgroundView = blurredView
    
  }
  
  
  
  override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController!.fetchedObjects.count
  }
  
  override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as ItemTableViewCell
    let item = fetchedResultsController!.fetchedObjects[indexPath.row] as Item
    cell.setItem(item)
    return cell
    
  }
  
  override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    delegate?.searchResultViewController(self, didSelectItem: fetchedResultsController?.fetchedObjects[indexPath.row] as Item)
    
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController!) {
    tableView.reloadData()
  }
  

}
