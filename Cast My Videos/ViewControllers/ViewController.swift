//
//  ViewController.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 19/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AVFoundation
import MediaPlayer


let CellIdentifier = "CellIdentifier"

class ViewController: UITableViewController, UIPopoverPresentationControllerDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, SearchResultViewControllerDelegate
{
    var searchController: UISearchController?

    var airplayPlayer: AVPlayer!
    var airplayWindow: UIWindow?

    let wwdcVideoPredicates = NSPredicate(
        format: "userDefined = false",
        argumentArray: nil
    )
    let userDefinedVideoPredicates = NSPredicate(
        format: "userDefined = true",
        argumentArray: nil
    )

    //MARK: --- Lazy Initializer ---

    lazy var fetchedResultsController: NSFetchedResultsController? = {
        let aFetchedResultsController = Item.fetchedResultsControllerForEntityNamed(
            "Item",
            withPredicate:self.wwdcVideoPredicates,
            sectionNameKey: nil,
            sortDescriptors: [
                NSSortDescriptor(key: "title", ascending: true)
            ]
        )

        aFetchedResultsController!.delegate = self
        return aFetchedResultsController
        }()

    lazy var operationManager: OperationManager = {
        return OperationManager()
        }()

    //Mark: ----------------------

    var devicesBarButtonItem: UIBarButtonItem?
    var videos: Array<String> =  Array<String>()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        prepareSearchController()
        prepareView()
        operationManager.fetchFromUrl()
        DeviceManager.sharedManager().beginScanning()
    }

    func prepareView()
    {
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.estimatedRowHeight = 44.0

        tableView.tableFooterView = UIView(frame: CGRectZero)

        let barButtonItem = UIBarButtonItem(
            title: "Devices",
            style: .Plain,
            target: self,
            action: "showDevices:"
        )

        navigationItem.rightBarButtonItem = barButtonItem

        devicesBarButtonItem = barButtonItem

        devicesBarButtonItem!.enabled = false

        let alertBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: "inputUrl:"
        )

        navigationItem.rightBarButtonItem = alertBarButtonItem

        let segmentedControl = UISegmentedControl(items: ["WWDC", "My Own"]);
        navigationItem.titleView = segmentedControl

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(
            self,
            action: "segmentedControlValueChanged:",
            forControlEvents: .ValueChanged
        )
    }

    func segmentedControlValueChanged(sender: UISegmentedControl!)
    {
        fetchedResultsController = Item.fetchedResultsControllerForEntityNamed(
            "Item",
            withPredicate:
            sender.selectedSegmentIndex == 0 ? wwdcVideoPredicates : userDefinedVideoPredicates,
            sectionNameKey: nil,
            sortDescriptors:
            [
                NSSortDescriptor(key: "title", ascending: true)
            ]
        )
        fetchedResultsController?.delegate = self
        tableView.reloadSections(
            NSIndexSet(index: 0),
            withRowAnimation: .Automatic
        )
    }

    func prepareSearchController()
    {
        let searchResultController = storyboard!.instantiateViewControllerWithIdentifier("SearchResultViewController") as SearchResultViewController
        searchResultController.delegate = self
        searchController = UISearchController(searchResultsController: searchResultController)
        searchController!.searchResultsUpdater = self
        definesPresentationContext = true
        searchController!.searchBar.frame = CGRectMake(
            0, 0, CGRectGetWidth(tableView.bounds), 44.0
        )
        tableView.tableHeaderView = searchController!.searchBar
        searchController!.searchBar.searchBarStyle = .Minimal
    }


    func inputUrl(sender: AnyObject!)
    {
        let alertController = UIAlertController(title: "Provide the url to cast", message: nil, preferredStyle: .Alert)

        alertController.addTextFieldWithConfigurationHandler(
            { (textField: UITextField!) in
                textField.placeholder = "http://developer.apple.com/202_hd_whats_new_in_cocoa_touch"
            }
        )

        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler:
            { (alertAction: UIAlertAction!) in


                let theTextField =  alertController.textFields![0]  as UITextField

                let string = theTextField.text

                if !string.isEmpty{

                    let count = Item.countForEntityNamed("Item", withPredicate: NSPredicate(format: "url = %@", string), inManagedObjectContext: CoreDataManager.manager().managedObjectContext)
                    var item: Item

                    if(count > 0){

                        item = Item.findFirstEntityNamed("Item", withPredicate: NSPredicate(format: "url = %@", string), inManagedObjectContext: CoreDataManager.manager().managedObjectContext) as Item

                    }else{

                        item = Item.insertNewForEntityNamed("Item", inManagedObjectContext: CoreDataManager.manager().managedObjectContext) as Item


                        item.url = string
                        item.userDefined = ObjCBool(true)
                    }

                    var error : NSError?
                    CoreDataManager.manager().managedObjectContext.save(&error)
                }
            }
            )
        )

        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        presentViewController(alertController, animated: true, completion: nil)

    }

    func showDevices(button: UIBarButtonItem!)
    {
        let devicePopoverViewController = DevicePopoverViewController()

        devicePopoverViewController.modalPresentationStyle = .Popover

        devicePopoverViewController.preferredContentSize = CGSize(width: 200, height: 150)

        let popoverViewController = devicePopoverViewController.popoverPresentationController

        popoverViewController?.permittedArrowDirections = .Any

        popoverViewController?.barButtonItem = devicesBarButtonItem

        popoverViewController?.delegate = self


        presentViewController(devicePopoverViewController, animated: true, completion: nil)
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let fetchedObject: AnyObject? = fetchedResultsController?.fetchedObjects![indexPath.row]
        performSegueWithIdentifier("PlayingViewController", sender:fetchedObject)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if segue.identifier == "PlayingViewController" {
            let playingViewController = segue.destinationViewController as PlayingViewController
            playingViewController.item = sender as? Item
        }
    }

    override func tableView(
        tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
        return fetchedResultsController!.fetchedObjects!.count
    }

    override func tableView(
        tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath
        ) -> CGFloat
    {
        return 99
    }

    override func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
        ) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            CellIdentifier, forIndexPath: indexPath
            ) as ItemTableViewCell
        let item = fetchedResultsController?.fetchedObjects![indexPath.row] as Item

        cell.setItem(item)
        return cell
    }

    override func tableView(
        tableView: UITableView,
        accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath
        )
    {
        let item = self.fetchedResultsController?.fetchedObjects![indexPath.row] as Item

        let alertController = UIAlertController(
            title: "Name the video",
            message: nil,
            preferredStyle: .Alert
        )
        alertController.addTextFieldWithConfigurationHandler{
            (textField: UITextField!) in
            textField.placeholder = "My Video"

            if let title =  item.title {
                textField.text = title
            }
        }

        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {
            (alertAction: UIAlertAction!) in
            let theTextField =  alertController.textFields![0]  as UITextField

            let string = theTextField.text

            if !string.isEmpty {
                item.title = string
                CoreDataManager.manager().managedObjectContext.save(nil)
            }
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)

    }

    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController!) -> UIModalPresentationStyle
    {
        return .None
    }
    
    
    //MARK: --- NSFetchedResultsControllerDelegate ---
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!)
    {
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        let searchResultController = searchController.searchResultsController as SearchResultViewController
        
        searchResultController.searchString = searchController.searchBar.text
    }
    
    func searchResultViewController(viewController: SearchResultViewController!,
        didSelectItem item: Item!)
    {
        performSegueWithIdentifier("PlayingViewController", sender: item)
    }
}
