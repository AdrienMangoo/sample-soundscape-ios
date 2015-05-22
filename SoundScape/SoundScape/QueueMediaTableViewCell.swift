//
//  QueueMediaTableViewCell.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 5/12/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import UIKit

class QueueMediaTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitileImageView: UILabel!
    
    @IBOutlet weak var userColorImageView: UIImageView!
    
    @IBOutlet weak var albumNameLabel: UILabel!
    
    @IBOutlet weak var nowPlayingImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
