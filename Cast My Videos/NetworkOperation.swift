//
//  NetworkManager.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 19/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit

class NetworkOperation:NSOperation {
  
  let urlString: String
  var responseString: String?
  
  init(urlString: String){
    self.urlString = urlString
    
  }
  
  override func main() {
    let url = NSURL(string: urlString)
    let urlRequest = NSURLRequest(URL: url)
    
    let data = NSData(contentsOfURL: url)
    responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
    
  }


}
