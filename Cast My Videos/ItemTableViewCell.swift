//
//  ItemTableViewCell.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 21/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
  
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var durationLabel: UILabel!
  @IBOutlet var yearLabel: UILabel!


    override init(style: UITableViewCellStyle, reuseIdentifier: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
    }

    required init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  
  override func layoutSubviews(){
    super.layoutSubviews()
    nameLabel!.preferredMaxLayoutWidth = bounds.size.width - 20 - 100
    super.layoutSubviews()
  }
  
  override func prepareForReuse() {
    
    super.prepareForReuse()
  
    nameLabel.text = ""
  
    durationLabel.text = ""
  }
  
  func setItem(item: Item){
    
    if let name = item.title {
      
      if name.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 28{
        nameLabel.text = "\(name.substringToIndex(advance(name.startIndex, 28)))"
      }else{
        nameLabel.text = name
      }

    
    }else{
      
      if item.url!.utf16Count > 28{
        nameLabel.text = "\(item.url!.substringToIndex(advance(item.url!.startIndex, 28)))..."
      }else{
        nameLabel.text = item.url!
      }
    }
    
    if let duration = item.duration{
      
      durationLabel.text = duration
      
    }
    
    if let year = item.year{
      yearLabel.text = year
    }
    
  }
  


}
