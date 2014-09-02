//
//  ParseOperation.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 19/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit



class ParseOperation: BaseOperation {
  
  var year: String!
  
  

  
  init(_ year: String!){
     self.year = year
  }
  
  
  var responseArray:  Array<[String: String]>?

  
  
  var response: NSString?{
  didSet{
    if (response != nil){
        transition(fromState: .Initial, toState: .Ready)
      }
    }
  }
  


  let regexFor2010Onwards = "<li .*>(.*)<\\/li>\\s*.*\\s*.*<p>(.*)<\\/p>[\\w\\s]+<p.*\\s+<a href=\"(.*.mov)\">HD<\\/a>"
  
  let regexFor2013Onwards = "(?:<li class=\"thumbnail-title\">(.*))?<\\/li>.*<\\/li><li.*\\s+.*\\s+<p>(.*)<\\/p>\\s*<p .*\\s+<a href=\"(.*.mov\\?dl=1)\">HD<\\/a>"
  
  override func start(){
    
    transition(fromState: .Ready, toState: .Executing)
    
    var errorPointer: NSError?
  
    var regexString: String
    
    if year == "2012"{
    
      regexString = regexFor2010Onwards
    
    }else{
      
      regexString =  regexFor2013Onwards
    
    }
    let regex = NSRegularExpression.regularExpressionWithPattern(regexString , options: NSRegularExpressionOptions.fromRaw(0)!, error: &errorPointer)
    
    
    
    let matches = regex?.matchesInString(response!, options: NSMatchingOptions.ReportCompletion, range:NSMakeRange(0, response!.length))

    responseArray = Array<[String: String]>()
    var results = Array<[String: String]>()
    
    if let allMatches = matches{
      progress.totalUnitCount = Int64(allMatches.count)
      progress.completedUnitCount = Int64(0)
      
      for i in allMatches{
        
        if let textCheckingResult = i as? NSTextCheckingResult{
          
          
          let titleString = self.response!.substringWithRange(textCheckingResult.rangeAtIndex(1))
          
          let contentRange = textCheckingResult.rangeAtIndex(2)
          let contentString = self.response!.substringWithRange(contentRange)
          
          
          
          let linkRange = textCheckingResult.rangeAtIndex(3)
          let linkString = self.response!.substringWithRange(linkRange)
          
          
          var dict = ["title": titleString, "content": contentString, "url": linkString]
          results.append(dict)
        }
        
        progress.completedUnitCount += 1

        
      }
        
    }
    
    responseArray = results
    
   transition(fromState: .Executing, toState: .Finished)
    
  }
  
  

  
}
