//
//  ParseOperation.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 19/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit

enum OperationState{
  case  Initial ,Ready, Executing, Finished
}


class ParseOperation: NSOperation {
  
  var year: String!
  
  
  init(_ year: String!){
     self.year = year
  }
  
  var state = OperationState.Initial
  
  var responseArray:  Array<[String: String!]>?

  
  
  var response: String?{
  didSet{
    if response{
      self.willChangeValueForKey("isReady")
      state = .Ready
      self.didChangeValueForKey("isReady")

    }
    }
  }
  
  
  override var ready: Bool{
  return state == .Ready
  }
  
  
  override var executing: Bool{
  return state == .Executing
  }
  
  override var finished: Bool{
  return state == .Finished
  }
  

  let regexFor2010Onwards = "<li .*>(.*)<\\/li>\\s*.*\\s*.*<p>(.*)<\\/p>[\\w\\s]+<p.*\\s+<a href=\"(.*.mov)\">HD<\\/a>"
  
  let regexFor2013Onwards = "(?:<li class=\"thumbnail-title\">(.*))?<\\/li>.*<\\/li><li.*\\s+.*\\s+<p>(.*)<\\/p>\\s*<p .*\\s+<a href=\"(.*.mov\\?dl=1)\">HD<\\/a>"
  
  override func start(){

    self.willChangeValueForKey("isReady")
    self.willChangeValueForKey("isExecuting")
    
    state = .Executing
    
    self.didChangeValueForKey("isReady")
    self.didChangeValueForKey("isExecuting")
    
    
    
    var errorPointer: NSError?
  
    var regexString: String
    
    if year == "2012"{
    
      regexString = regexFor2010Onwards
    
    }else{
      
      regexString =  regexFor2013Onwards
    
    }
    let regex = NSRegularExpression.regularExpressionWithPattern(regexString , options: NSRegularExpressionOptions.fromRaw(0)!, error: &errorPointer)
    let matches =  regex.matchesInString(response, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, response!.bridgeToObjectiveC().length))
    
    responseArray = Array<[String: String!]>()
    var results = Array<[String: String!]>()
    for i in matches{
      
      if let textCheckingResult = i as? NSTextCheckingResult{
        
        let titleRange = textCheckingResult.rangeAtIndex(1)
        let titleString = self.response!.bridgeToObjectiveC().substringWithRange(titleRange)
        
        let contentRange = textCheckingResult.rangeAtIndex(2)
        let contentString = self.response!.bridgeToObjectiveC().substringWithRange(contentRange)
        
        
        
        let linkRange = textCheckingResult.rangeAtIndex(3)
        let linkString = self.response!.bridgeToObjectiveC().substringWithRange(linkRange)
        
        
        var dict = ["title": titleString, "content": contentString, "url": linkString]
        results += dict
      }
    }
    responseArray = results
    
    self.willChangeValueForKey("isFinished")
    self.willChangeValueForKey("isExecuting")
    self.state = .Finished
    self.didChangeValueForKey("isExecuting")
    self.didChangeValueForKey("isFinished")
    
  }
  
  

  
}
