//
//  PlayerView.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 02/09/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import AVFoundation


class PlayerView: UIView {

  
  
  var player: AVPlayer! = AVPlayer()
  
  let AVPlayerItemObservingContext = UnsafeMutablePointer<Int>(bitPattern: 1)
  
  override class func layerClass() -> AnyClass{
    return AVPlayerLayer.self
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    let playerLayer = layer as AVPlayerLayer
    playerLayer.player = player
    playerLayer.videoGravity = AVLayerVideoGravityResize
    playerLayer.contentsCenter = CGRectMake(0, 0, 1, 1)
    
  }
 
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    let playerLayer = layer as AVPlayerLayer
    playerLayer.player = player
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill


  }
  
  
  override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
    if context == AVPlayerItemObservingContext && keyPath == "duration"{
      player.play()
      
    }else{
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
  }
  
  func playWithUrlString(url: String!){
    
    let asset = AVURLAsset(URL: NSURL(string: url), options: nil)
    
    asset.loadValuesAsynchronouslyForKeys(["tracks"], completionHandler: { [unowned self]() -> Void in
      var error: NSError?
      let status = asset.statusOfValueForKey("tracks", error:&error)
      
      switch(status){
        
        case .Loaded:
          let playerItem = AVPlayerItem(asset: asset)
          self.player.replaceCurrentItemWithPlayerItem(playerItem)
          playerItem.addObserver(self, forKeyPath: "duration", options: .New, context: self.AVPlayerItemObservingContext)

      case .Failed:
        
          println("Failed to load")
      
        
      default:
        
        println("Default")
        
      }
      
    })
    
  }
  
  
  
  
  
  
  
}
