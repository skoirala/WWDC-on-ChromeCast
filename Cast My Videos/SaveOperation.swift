 //
//  SaveOperation.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 21/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import CoreData



class SaveOperation: NSOperation {
  
  
  var state = OperationState.Initial
  
  var year: String!
  
  
  var savingManagedObjectContext: NSManagedObjectContext?
  
  let persistentStoreCoorinator: NSPersistentStoreCoordinator
  
  let mainManagedObjectContext: NSManagedObjectContext
  
  
  
  var responseDictionary: Array<Dictionary<String, String!>>?{
    didSet{
      self.willChangeValueForKey("isReady")
      if responseDictionary{
        state = .Ready
      }
      self.didChangeValueForKey("isReady")
    }
  }
  

  
  
  init(managedObjectContext: NSManagedObjectContext){
  
    
    mainManagedObjectContext = managedObjectContext
    
    persistentStoreCoorinator = managedObjectContext.persistentStoreCoordinator
    
    super.init()

  
  }
  
  
  
  
  override var ready: Bool{
    return state == OperationState.Ready
  }
  
  
  override var executing: Bool{
    return state == OperationState.Executing
  }
  
  override var finished: Bool{
    return state == OperationState.Finished
  }
  
  override func start(){
    
    self.willChangeValueForKey("isReady")
    self.willChangeValueForKey("isExecuting")
    
    state = .Executing
    
    self.didChangeValueForKey("isReady")
    self.didChangeValueForKey("isExecuting")
    
    savingManagedObjectContext = NSManagedObjectContext()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "managedObjectContextSaved:", name: NSManagedObjectContextDidSaveNotification, object: savingManagedObjectContext)

    savingManagedObjectContext!.persistentStoreCoordinator = persistentStoreCoorinator
    
    if let aResponseDictionary = responseDictionary{
      
      for dict: Dictionary<String, String!> in aResponseDictionary{
        
        let count = Item.countForEntityNamed("Item", withPredicate: NSPredicate(format: "url = %@", dict["url"]!), inManagedObjectContext: savingManagedObjectContext)
        
        if count > 0{
          continue
        }
        else{
          let item = Item.insertNewForEntityNamed("Item", inManagedObjectContext: savingManagedObjectContext) as Item
        
          item.setValuesForKeysWithDictionary(dict)
          item.year = year

        }
        
        
      }
      
      savingManagedObjectContext!.save(nil)
    }
    
    
  }
  
  func managedObjectContextSaved(notification: NSNotification!){
    let mergeChanges: () -> () = {
      self.mainManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
      
      self.willChangeValueForKey("isFinished")
      self.willChangeValueForKey("isExecuting")
      self.state = .Finished
      self.didChangeValueForKey("isExecuting")
      self.didChangeValueForKey("isFinished")
    }
    
    if NSThread.isMainThread(){
      mergeChanges()
    }else{
      dispatch_sync(dispatch_get_main_queue(), mergeChanges)
    }
    
  }
  
  
  
  
}
