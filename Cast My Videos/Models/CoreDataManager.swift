//
//  CoreDataManager.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 21/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import CoreData

class CoreDataManager
{

    let managedObjectContext: NSManagedObjectContext!

    class func manager() -> CoreDataManager
    {
        struct ManagerStruct
        {
            static let manager: CoreDataManager = CoreDataManager()
            func instance() -> CoreDataManager
            {
                return ManagerStruct.manager
            }

        }
        return ManagerStruct().instance()
    }

    init()
    {
        managedObjectContext = NSManagedObjectContext(
            concurrencyType: .MainQueueConcurrencyType
        )
        initializeCoreDataStack()
    }

    func initializeCoreDataStack()
    {
        let momPath = NSBundle.mainBundle().URLForResource(
            "DataModel",
            withExtension: "momd"
            )!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: momPath)


        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]

        let documentDirectory = try? NSFileManager.defaultManager().URLForDirectory(
            .DocumentDirectory,
            inDomain: .UserDomainMask,
            appropriateForURL: nil,
            create: false)

        let fileUrl = documentDirectory?.URLByAppendingPathComponent("Item.sqlite")

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(
            managedObjectModel: managedObjectModel!
        )
        var error: NSError?

        let persistentStore: NSPersistentStore?
        do {
            persistentStore = try persistentStoreCoordinator.addPersistentStoreWithType(
                        NSSQLiteStoreType,
                        configuration: nil,
                        URL: fileUrl,
                        options: options)
        } catch let error1 as NSError {
            error = error1
            persistentStore = nil
        }

        if persistentStore != nil {
            if let theError = error {
                print("Could not create persistent store %d", theError.localizedDescription)
                exit(0);
            }
        }
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

    }
}

extension NSManagedObject
{

    class func insertNewForEntityNamed(
        name: String!,
        inManagedObjectContext context: NSManagedObjectContext!
        ) -> NSManagedObject
    {

        let entityDescription = NSEntityDescription.insertNewObjectForEntityForName(
            name,
            inManagedObjectContext: context
            ) as NSManagedObject

        return entityDescription
    }

    class func fetchedResultsControllerForEntityNamed(
        name: String!,
        withPredicate predicate: NSPredicate!,
        sectionNameKey sectionName: String!,
        sortDescriptors: [NSSortDescriptor]) -> NSFetchedResultsController?{

        let fetchRequest = NSFetchRequest(entityName: name)

        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = sortDescriptors

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.manager().managedObjectContext,
            sectionNameKeyPath: sectionName,
            cacheName: nil
            )

        var error: NSError?

        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }

        if let theError = error {
            print("Fetched results controller error \(error?.localizedDescription)")
            return nil
        }
        return fetchedResultsController
    }

    class func findAllForEntityNamed(
        name: String!,
        withPredicate predicate: NSPredicate!,
        inManagedObjectContext context: NSManagedObjectContext!) -> [NSManagedObject]?
    {
        let fetchRequest = NSFetchRequest(entityName: name)
        fetchRequest.predicate = predicate

        var objects: [NSManagedObject] = []
        
        do {
            objects = try context.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Error Occurred \(error.localizedDescription)" )
            return nil
        } catch {
            
        }
        return objects
    }

    class func findFirstEntityNamed(name: String!,
        withPredicate predicate: NSPredicate!,
        inManagedObjectContext context: NSManagedObjectContext!) -> NSManagedObject?
    {
        let objects = findAllForEntityNamed(
            name, withPredicate: predicate,
            inManagedObjectContext: context
        )

        if let allObjects = objects {
            if allObjects.count > 0 {
                return allObjects[0]
            } else {
                return nil
            }
        }
        return nil
    }
    
    class func countForEntityNamed(
        name: String!,
        withPredicate predicate: NSPredicate!,
        inManagedObjectContext context: NSManagedObjectContext!) -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: name)
        fetchRequest.predicate = predicate
        return context.countForFetchRequest(fetchRequest, error: nil)
    }
}
