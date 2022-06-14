//
//  AddCateCollectionViewCell.swift
//  Kondate
//
//  Created by 石川愛海 on 2022/06/14.
//

import UIKit

class AddCateCollectionViewCell: UICollectionViewCell {
    @IBOutlet var acLabel: UILabel!
    @IBOutlet var acView: UIView!
    
    override var isSelected: Bool {
        didSet {
            if(self.isSelected){
                acView.layer.borderColor = UIColor(red: 255/255, green: 201/255, blue: 101/255, alpha: 1.0).cgColor
                acView.layer.borderWidth = 7
            }else{
                acView.layer.borderWidth = 0
            }
        }
    }
}
