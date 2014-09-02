//
//  BaseOperation.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 02/08/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit

enum OperationState: String{
  case  Initial = "isInitial" ,Ready = "isReady", Executing = "isExecuting", Finished = "isFinished"
  
}

class BaseOperation: NSOperation {
  
  var state = OperationState.Initial
  
  let progress = NSProgress(totalUnitCount: Int64(NSIntegerMax))

  
  func transition(fromState from: OperationState, toState to:OperationState){
    
    self.willChangeValueForKey(from.toRaw())
    self.willChangeValueForKey(to.toRaw())
    
    state = to
    
    self.didChangeValueForKey(from.toRaw())
    self.didChangeValueForKey(to.toRaw())
    
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
  

  
  
}
