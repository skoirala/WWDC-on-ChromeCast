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

class PlayingViewController: UIViewController {
  
  @IBOutlet var playPauseButton: UIButton
  
  @IBOutlet var timerLabel: UILabel
  
  @IBOutlet var scrubber: UISlider
  
  var displayLink: CADisplayLink?
  
  
  var item: Item?
  
  var refinedUrl: String?
  
  
  var duration: CMTime?
  
  var currentTime: CMTime = CMTimeMakeWithSeconds(1, 5)
  
  var playing: Bool = false
  
  @IBAction func playButtonTapped(button: UIButton!){
    
    if !displayLink{
      
      displayLink = CADisplayLink(target: self, selector: "updateSlider:")
      displayLink!.frameInterval = 60
      displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
      
    }
    
    if !playing{
      
      displayLink!.paused = false
      playing = true
      
      if CMTimeCompare(CMTimeMakeWithSeconds(0, 5), currentTime) == 0{
        
        castController!.playVideo(refinedUrl!)
        
      }else{
        
        castController!.playVideo(refinedUrl!, fromTime:Double(CMTimeGetSeconds(currentTime)))
        
      }
      
      button.setTitle("Pause", forState: .Normal)
      
    }else{
      
      displayLink!.paused = true
      
      playing  = false
      
      castController!.pause()
      
      button.setTitle("Play", forState: .Normal)
      
    }
  }
  
  func updateSlider(slider: AnyObject!){
    
    let a = castController!.mediaControlChannel?.requestStatus()
    
    if a != kGCKInvalidRequestID{
      
      let streamPosition = castController!.mediaControlChannel?.mediaStatus?.streamPosition
      
      if streamPosition{
        
        currentTime = CMTimeMakeWithSeconds(streamPosition!, 10)
        
        updateTimerLabel()
        
        if duration{
        
          let durationInSeconds = CMTimeGetSeconds(duration!)
        
          let value: Float = Float(streamPosition!) / Float(durationInSeconds)
        
          scrubber.value = value
          
        }
      }
      
      
    }
  }
  
  @IBAction func scrubberDragged(scrubber: UISlider){
    
    let durationInSeconds = CMTimeGetSeconds(duration!)
    
    
    currentTime = CMTimeMakeWithSeconds(Float64(scrubber.value) * durationInSeconds,Int32(currentTime.timescale))
    
    updateTimerLabel()
    
  }
  
  func scrubberTouchDown(scrubber: UISlider!){
    
    castController!.pause()
    
    displayLink!.paused = true
  
  }
  
  func scrubberTouchUpInside(scrubber: UISlider!){
    
    castController!.playVideo(refinedUrl!, fromTime:Double(CMTimeGetSeconds(currentTime)))
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue()){
      
      self.displayLink!.paused = false
      
    }
    
  }
  
  var videoToPlay: String?
  
  var castController: CastController?
  
  
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    println(item?.url)
    
    scrubber.addTarget(self, action: "scrubberTouchDown:", forControlEvents: .TouchDown)
    
    scrubber.addTarget(self, action: "scrubberTouchUpInside:", forControlEvents: .TouchUpInside)
    
    
    refinedUrl = item?.url!
    
    scrubber.enabled = false
    let url = NSURL(string: refinedUrl)
    
    let avAsset = AVURLAsset(URL: url, options: nil)
    
    
    avAsset.loadValuesAsynchronouslyForKeys(["tracks"], completionHandler: {
      
      switch avAsset.statusOfValueForKey("tracks", error: nil){
        
      case .Loaded:
        
        self.duration = avAsset.duration
        
        dispatch_async(dispatch_get_main_queue(), {
          
          self.updateTimerLabel()
          
          let totalTime = self.timeFromDuration(self.duration!)
          self.item!.duration = totalTime as String
          CoreDataManager.manager().managedObjectContext.save(nil)
          
          })
        
        self.scrubber.enabled = true
        
      default:
        
        break
      }
      })
    
  }
  
  func updateTimerLabel(){
    
    if duration{
      let totalTime = timeFromDuration(self.duration!)
      
      let currentTime = timeFromDuration(self.currentTime)
      
      
      self.timerLabel.text = NSString(format: "%@ / %@", currentTime, totalTime)
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
  
  
}
