 //
//  SaveOperation.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 21/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import CoreData



class SaveOperation: BaseOperation {
  

  
  var year: String!
  
  
  
  var savingManagedObjectContext: NSManagedObjectContext?
  
  let persistentStoreCoorinator: NSPersistentStoreCoordinator
  
  let mainManagedObjectContext: NSManagedObjectContext
  
  
  
  var responseDictionary: Array<Dictionary<String, String>>?{
  
    didSet{
      
      if (responseDictionary != nil){
        
        transition(fromState: .Initial, toState: .Ready)

      }
    }
  }
  

  
  
  init(managedObjectContext: NSManagedObjectContext){
  
    
    mainManagedObjectContext = managedObjectContext
    
    persistentStoreCoorinator = managedObjectContext.persistentStoreCoordinator
    
    super.init()

  
  }
  
  
  override func start(){
    
    transition(fromState: .Ready, toState: .Executing)
    
    savingManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "managedObjectContextSaved:", name: NSManagedObjectContextDidSaveNotification, object: savingManagedObjectContext)

    savingManagedObjectContext!.persistentStoreCoordinator = persistentStoreCoorinator

    
    if let aResponseDictionary = responseDictionary{
      progress.totalUnitCount = Int64(aResponseDictionary.count)
      progress.completedUnitCount = 0
      for dict: Dictionary<String, String> in aResponseDictionary{
        
        let count = Item.countForEntityNamed("Item", withPredicate: NSPredicate(format: "url = %@", dict["url"]!), inManagedObjectContext: savingManagedObjectContext)
        
        if count == 0{
          let item = Item.insertNewForEntityNamed("Item", inManagedObjectContext: savingManagedObjectContext) as Item
        
          item.setValuesForKeysWithDictionary(dict)
          item.year = year

        }
        progress.completedUnitCount += 1
 
      }
      
      savingManagedObjectContext!.save(nil)
    }
    
    
  }
  
  func managedObjectContextSaved(notification: NSNotification!){
    let mergeChanges: () -> () = {
      self.mainManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
      self.transition(fromState: .Executing, toState: .Finished)
    }
    
    if NSThread.isMainThread(){
      mergeChanges()
    }else{
      dispatch_sync(dispatch_get_main_queue(), mergeChanges)
    }
    
  }
  
  
  
  
}
