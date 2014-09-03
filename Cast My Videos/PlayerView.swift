//
//  PlayerView.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 02/09/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import AVFoundation

typealias TimeObserver = (CMTime) -> Void

protocol PlayerViewDelegate: NSObjectProtocol{
  
  
  func playerView(playerView: PlayerView!, didBecomeReadyToPlay ready: Bool)
  func playerView(playerView: PlayerView!, didUpdateDuration duration: CMTime?)
  func playerViewTimeObserverForPlayer(playerView: PlayerView!) -> TimeObserver
  
}

class PlayerView: UIView {
  
  var observing = false
  
  var timeObserver: TimeObserver!
  
  
  var currentItem: AVPlayerItem?

  weak var delegate: PlayerViewDelegate?
  var observer: AnyObject?

  
  var playing: Bool{
    get {
      return self.player.rate != 0.0
    }
  }
  
  private var player: AVPlayer! = AVPlayer()
  
  private let AVPlayerItemObservingContext = UnsafeMutablePointer<Int>(bitPattern: 1)
  
  override class func layerClass() -> AnyClass{
    return AVPlayerLayer.self
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  
  override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
    
    if context == AVPlayerItemObservingContext && keyPath == "duration"{
      observing = false
      dispatch_async(dispatch_get_main_queue(), { [weak self]
      () -> Void in
        if let playerView = self{
          playerView.delegate?.playerView(playerView, didBecomeReadyToPlay: true)
        }
      });

      if let item = currentItem{
        item.removeObserver(self, forKeyPath: "duration")
      }
    }else{
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
  }
  
  func play(){
    playing ? player.pause() : player.play()
  }
  
  func preparePlayWithUrlString(url: String!){
    
    let asset = AVURLAsset(URL: NSURL(string: url), options: nil)
    
    observer = player.addPeriodicTimeObserverForInterval(CMTimeMake(2, 5), queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), usingBlock: delegate?.playerViewTimeObserverForPlayer(self))
    
    asset.loadValuesAsynchronouslyForKeys(["tracks"], completionHandler: { [weak self]() -> Void in
      if let thePlayer = self{
      var error: NSError?
      let status = asset.statusOfValueForKey("tracks", error:&error)
      
      switch(status){
        
        case .Loaded:
          dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
            if let playerView = self{
              if let theDelegate = playerView.delegate{
                theDelegate.playerView(playerView, didUpdateDuration: asset.duration)
              }
            }
          });
          
          let playerItem = AVPlayerItem(asset: asset)
          thePlayer.player.replaceCurrentItemWithPlayerItem(playerItem)
          thePlayer.observing = true
          playerItem.addObserver(thePlayer, forKeyPath: "duration", options: .New, context: thePlayer.AVPlayerItemObservingContext)
          thePlayer.currentItem = playerItem

      case .Failed:
        
          println("Failed to load")
      
        
      default:
        
        println("Default")
        
      }
      }
    })
    
  }
  
  
  private
  
  func setup(){
    let playerLayer = layer as AVPlayerLayer
    playerLayer.player = player
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
  }
  
  deinit{
    if observing {
      currentItem?.removeObserver(self, forKeyPath: "duration")
    }
    if let theObserver: AnyObject = observer{
      player.removeTimeObserver(theObserver)
      observer = nil
    }
  }
  
}
