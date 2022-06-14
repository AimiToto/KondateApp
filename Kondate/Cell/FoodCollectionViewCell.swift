//
//  FoodCollectionViewCell.swift
//  Kondate
//
//  Created by 石川愛海 on 2022/06/11.
//

import UIKit

class FoodCollectionViewCell: UICollectionViewCell {
    @IBOutlet var foodImageView: UIImageView!
    @IBOutlet var foodLabel: UILabel!
    @IBOutlet var maruView: UIView!
    
    override var isSelected: Bool {
        didSet {
            if(self.isSelected){
                maruView.layer.borderColor = UIColor(red: 255/255, green: 201/255, blue: 101/255, alpha: 1.0).cgColor
                maruView.layer.borderWidth = 7
            }else{
                maruView.layer.borderWidth = 0
            }
        }
    }
}
