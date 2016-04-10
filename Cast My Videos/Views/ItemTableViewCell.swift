//
//  ItemTableViewCell.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 21/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell
{
  
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var durationLabel: UILabel!
  @IBOutlet var yearLabel: UILabel!

  override func layoutSubviews()
  {
    super.layoutSubviews()
    nameLabel!.preferredMaxLayoutWidth = bounds.size.width - 20 - 100
    super.layoutSubviews()
  }
  
  override func prepareForReuse()
  {
    super.prepareForReuse()
    nameLabel.text = ""
    durationLabel.text = ""
  }
  
  func setItem(item: Item)
  {
    if let name = item.title {
      if name.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 28{
        nameLabel.text = "\(name.substringToIndex(name.startIndex.advancedBy(28)))"
      } else {
        nameLabel.text = name
      }
    } else {
      if item.url!.characters.count > 28 {
        nameLabel.text = "\(item.url!.substringToIndex(item.url!.startIndex.advancedBy(28)))..."
      } else {
        nameLabel.text = item.url!
      }
    }
    
    if let duration = item.duration {
      durationLabel.text = duration
    }
    
    if let year = item.year {
      yearLabel.text = year
    }
  }
}
