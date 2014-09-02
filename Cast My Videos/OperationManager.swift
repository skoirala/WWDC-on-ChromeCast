//
//  OperationManager.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 22/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit


class OperationManager: NSObject {
  
  
  
  
  let ParseOperationObservingContext = UnsafeMutablePointer<Int>(bitPattern: 1)
  
  let SaveOperationObservingContext = UnsafeMutablePointer<Int>(bitPattern: 2)
  
  lazy var operationQueue: NSOperationQueue = {
    let operationQueue = NSOperationQueue()
    operationQueue.maxConcurrentOperationCount = 4
    operationQueue.waitUntilAllOperationsAreFinished()

    return operationQueue
  }()
  
  
  
  
  func createOperationReturningFirstAndLastOperation(#url: String!, forYear year: String!) -> (firstOperation:NSOperation!, lastOperation: NSOperation!){
    
    let networkOperation = NetworkOperation(urlString: url)

    
    let parseOperation = ParseOperation(year)
    parseOperation.addDependency(networkOperation)
    
    networkOperation.completionBlock = {
      parseOperation.response = networkOperation.responseString
    }
    
    
    
    let saveOperation = SaveOperation(managedObjectContext: CoreDataManager.manager().managedObjectContext)
    saveOperation.year = year
    saveOperation.addDependency(parseOperation)
    
    parseOperation.completionBlock = {
      saveOperation.responseDictionary = parseOperation.responseArray
      
    }
    
    operationQueue.addOperations([networkOperation, parseOperation, saveOperation], waitUntilFinished: false)
    
    let parseOperationProgress = parseOperation.progress
    
    parseOperationProgress.addObserver(self, forKeyPath: "fractionCompleted", options: .New, context: ParseOperationObservingContext)
    
    let saveOperationProgress = saveOperation.progress
    
    saveOperation.addObserver(self, forKeyPath: "fractionCompleted", options: .New, context: SaveOperationObservingContext)

    
    
    
    return (networkOperation, saveOperation)
  
  }
  
  func fetchFromUrl() {
    
    var firstSetOfOperations = createOperationReturningFirstAndLastOperation(url: "https://developer.apple.com/videos/wwdc/2014/", forYear: "2014")
    
    var secondSetOfOperations = createOperationReturningFirstAndLastOperation(url: "https://developer.apple.com/videos/wwdc/2013/", forYear: "2013")
    
    secondSetOfOperations.firstOperation.addDependency(firstSetOfOperations.lastOperation)
    
  }
  
  override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
    if keyPath == "fractionCompleted"{
      if context == ParseOperationObservingContext{
        
        println("Completed \(change[NSKeyValueChangeNewKey])) % parsing")
        
      }else if context == SaveOperationObservingContext{
        
        println("Completed \(change) % saving")
        
      }
      
    }else{
      
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
      
    }
  }
}
  
 