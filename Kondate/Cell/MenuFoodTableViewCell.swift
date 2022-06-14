//
//  MenuFoodTableViewCell.swift
//  Kondate
//
//  Created by 石川愛海 on 2022/06/13.
//

import UIKit

class MenuFoodTableViewCell: UITableViewCell {
    
    @IBOutlet var mfImageView: UIImageView!
    @IBOutlet var mfLabel: UILabel!
    @IBOutlet var maruView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
