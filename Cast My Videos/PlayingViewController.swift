//
//  PlayingViewController.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 19/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import QuartzCore

class PlayingViewController: UIViewController, PlayerViewDelegate, UIPopoverPresentationControllerDelegate, DevicePopoverViewControllerDelegate {
  
  @IBOutlet weak var playPauseButton: UIButton!
  
  @IBOutlet weak var timerLabel: UILabel!
  
  @IBOutlet weak var playerView: PlayerView!
  
  @IBOutlet weak var scrubber: UISlider!
  
  
  var previousPlayingState = false
  
  var displayLink: CADisplayLink?
  
  var item: Item?
  
  var refinedUrl: String?
  
  
  var duration: CMTime?
  
  var currentTime: CMTime = CMTimeMakeWithSeconds(1, 5)
  
  var playing: Bool = false

  
  
  @IBAction func playButtonTapped(button: UIButton!){
    
    button.setTitle(playerView.playing ? "Play" : "Pause", forState: .Normal)
    
    playerView.playPause()
    
    
//    if !(displayLink != nil){
//      
//      displayLink = CADisplayLink(target: self, selector: "updateSlider:")
//      displayLink!.frameInterval = 60
//      displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
//      
//    }
//    
//    if !playing{
//      
//      displayLink!.paused = false
//      playing = true
//      
//      if CMTimeCompare(CMTimeMakeWithSeconds(0, 5), currentTime) == 0{
//        
//        castController!.playVideo(refinedUrl!)
//        
//      }else{
//        
//        castController!.playVideo(refinedUrl!, fromTime:Double(CMTimeGetSeconds(currentTime)))
//        
//      }
//      
//      button.setTitle("Pause", forState: .Normal)
//      
//    }else{
//      
//      displayLink!.paused = true
//      
//      playing  = false
//      
//      castController!.pause()
//      
//      button.setTitle("Play", forState: .Normal)
//      
//    }
  }
  
  func updateSlider(slider: AnyObject!){
    
    updateTimerLabel()
    if duration != nil{
      let durationInSeconds = CMTimeGetSeconds(duration!)
      
      let value: Float = Float(CMTimeGetSeconds(currentTime)) / Float(durationInSeconds)
      
      scrubber!.value = value

    }
    
//    let a = castController!.mediaControlChannel?.requestStatus()
//    
//    if a != kGCKInvalidRequestID{
//      
//      let streamPosition = castController!.mediaControlChannel?.mediaStatus?.streamPosition
//      
//      if (streamPosition != nil){
//        
//        currentTime = CMTimeMakeWithSeconds(streamPosition!, 10)
//        
//        updateTimerLabel()
//        
//        if (duration != nil){
//        
//          let durationInSeconds = CMTimeGetSeconds(duration!)
//        
//          let value: Float = Float(streamPosition!) / Float(durationInSeconds)
//        
//          scrubber!.value = value
//          
//        }
//      }
//      
//      
//    }
  }
  
  @IBAction func scrubberDragged(scrubber: UISlider){
    
    let durationInSeconds = CMTimeGetSeconds(duration!)
    
    
    currentTime = CMTimeMakeWithSeconds(Float64(scrubber.value) * durationInSeconds,Int32(currentTime.timescale))
    
    updateTimerLabel()
    
  }
  
  func scrubberTouchDown(scrubber: UISlider!){
    
    previousPlayingState = playerView.playing
    
    if previousPlayingState{
      playerView.playPause()
    }
    
//    castController!.pause()
//    
//    displayLink!.paused = true
  
  }
  
  func scrubberTouchUpInside(scrubber: UISlider!){
    
    
//    castController!.playVideo(refinedUrl!, fromTime:Double(CMTimeGetSeconds(currentTime)))
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue()){
//      
//      self.displayLink!.paused = false
//      
//    }
    
    playerView.seekToTime(currentTime, completionHandler: { [weak self](done: Bool) -> Void in
      if let playingViewController = self{
        if playingViewController.previousPlayingState{
          playingViewController.playerView.play(true)
        }else{
          playingViewController.playerView.play()
        }
      }
    });
    
  }
  
  var videoToPlay: String?
  
  var castController: CastController?
  
  
  func selectDevice(barButtonItem: UIBarButtonItem){
    
    let devicePopoverViewController = DevicePopoverViewController()
    devicePopoverViewController.modalPresentationStyle = .Popover
    devicePopoverViewController.delegate = self
    devicePopoverViewController.preferredContentSize = CGSizeMake(200, 200)
    let popOverController = devicePopoverViewController.popoverPresentationController
    
    popOverController.permittedArrowDirections = .Any
    popOverController.barButtonItem = barButtonItem
    popOverController.delegate = self

    presentViewController(devicePopoverViewController, animated: true, completion: nil)
  }
  

  override func viewDidLoad() {
    
    super.viewDidLoad()
  
    playerView.delegate = self
    playerView.preparePlayWithUrlString(item!.url)
    
//    playerView.allowAirplay = true
    
    
    let deviceSelectionBarButtonItem = UIBarButtonItem(title: "Device", style: .Plain, target: self, action: "selectDevice:")
    
    navigationItem.rightBarButtonItem = deviceSelectionBarButtonItem
    
    
//    println(item?.url)
    
    scrubber!.addTarget(self, action: "scrubberTouchDown:", forControlEvents: .TouchDown)
    
    scrubber!.addTarget(self, action: "scrubberTouchUpInside:", forControlEvents: .TouchUpInside)
    
    
    refinedUrl = item?.url!
    playPauseButton.enabled = false
    scrubber!.enabled = false
//    let url = NSURL(string: refinedUrl!)
//    
//    let avAsset = AVURLAsset(URL: url, options: nil)
//    
//    
//    avAsset.loadValuesAsynchronouslyForKeys(["tracks"], completionHandler: {
//      
//      switch avAsset.statusOfValueForKey("tracks", error: nil){
//        
//      case .Loaded:
//        
//        self.duration = avAsset.duration
//        
//        dispatch_async(dispatch_get_main_queue(), {
//          
//          self.updateTimerLabel()
//          
//          let totalTime = self.timeFromDuration(self.duration!)
//          self.item!.duration = totalTime as String
//          CoreDataManager.manager().managedObjectContext.save(nil)
//          self.scrubber!.enabled = true
//
//          })
//        
//        
//      default:
//        
//        break
//      }
//      })
//    
  }
  
  func updateTimerLabel(){
    
    if (duration != nil){
      let totalTime = timeFromDuration(self.duration!)
      
      let currentTime = timeFromDuration(self.currentTime)
      
      
      self.timerLabel!.text = NSString(format: "%@ / %@", currentTime, totalTime)
    }
    
  }
  
  func timeFromDuration(time: CMTime) -> NSString!{
    let seconds = Int(CMTimeGetSeconds(time))
    
    let minutes = seconds / 60;
    
    let remainingSeconds = seconds % 60;
    
    let hours = minutes / 60
    
    let remainingMinutes = minutes % 60
    
    return  NSString(format: "%0.2d : %0.2d : %0.2d", hours, remainingMinutes, remainingSeconds)
    
  }
  
  //MARK: PlayerViewDelegate
  
  func playerView(playerView: PlayerView!, didBecomeReadyToPlay ready: Bool) {
    playPauseButton.enabled = true
    self.scrubber!.enabled = true

  }
  
  
  func playerView(playerView: PlayerView!, didUpdateDuration duration: CMTime?) {
    self.duration = duration
    
    self.updateTimerLabel()
    let totalTime = self.timeFromDuration(self.duration!)
    self.item!.duration = totalTime as String
    CoreDataManager.manager().managedObjectContext.save(nil)
  }
  
  func playerViewTimeObserverForPlayer(playerView: PlayerView!) -> TimeObserver {
    return {
      [weak self] (time:CMTime) in
      if let playingViewController = self{
        playingViewController.currentTime = time
        playingViewController.updateSlider(playingViewController.scrubber)
      }
    }

  }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle{
    return .None
  }

  //MARK: DevicePopoverViewControllerDelegate
  
  func devicePopoverViewControllerDidSelectDefaultDevice(viewController: DevicePopoverViewController) {
    playerView.allowAirplay = false
  }
  
  func devicePopoverViewControllerDidSelectAirPlay(viewController: DevicePopoverViewController!) {
    playerView.allowAirplay = true
    playPauseButton.enabled = true
    scrubber.enabled = true
  }
  
  func devicePopoverViewControllerDidSelectDevice(device: GCKDevice) {
    
  }
  
  
}
