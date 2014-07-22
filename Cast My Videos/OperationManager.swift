//
//  OperationManager.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 22/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit

class OperationManager: NSObject {
 
  lazy var operationQueue: NSOperationQueue = {
    let operationQueue = NSOperationQueue()
    operationQueue.maxConcurrentOperationCount = 4
    return operationQueue
  }()
  
  func fetchFromUrl() {
    
    operationQueue.waitUntilAllOperationsAreFinished()
    
    let networkOperation2014 = NetworkOperation(urlString: "https://developer.apple.com/videos/wwdc/2014/")
    
    
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
}
