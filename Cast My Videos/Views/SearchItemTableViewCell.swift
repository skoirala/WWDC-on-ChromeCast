//
//  SearchItemTableViewCell.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 22/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit

class SearchItemTableViewCell: ItemTableViewCell
{

  override func layoutSubviews()
  {
    super.layoutSubviews()
    nameLabel!.preferredMaxLayoutWidth = bounds.size.width - 30
    super.layoutSubviews()
  }
  
  override func setItem(item: Item)
  {
    
    if let name = item.title {
      if name.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) > 30 {
        let upperLimit = item.url!.startIndex.advancedBy(30)
        nameLabel!.text = "\(name.substringToIndex(upperLimit))..."
      } else {
        nameLabel!.text = name
      }
    } else {
      if item.url!.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) > 30 {
        let upperLimit = item.url!.startIndex.advancedBy(30)
        nameLabel!.text = "\(item.url!.substringToIndex(upperLimit))..."
      } else {
        nameLabel!.text = item.url!
      }
    }
    
    if let duration = item.duration {
      durationLabel!.text = duration
    }
    
    if let year = item.year {
      yearLabel!.text = year
    }
    
  }
}
