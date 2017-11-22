//
//  HistoryTableViewCell.swift
//  DrawingApp
//
//  Created by Alban on 28.02.16.
//  Copyright © 2016 Medigarage Studios LTD. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {


    @IBOutlet weak var sentImg: UIImageView!
    @IBOutlet weak var predictionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
