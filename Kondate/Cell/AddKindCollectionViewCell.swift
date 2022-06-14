//
//  AddKindCollectionViewCell.swift
//  Kondate
//
//  Created by 石川愛海 on 2022/06/14.
//

import UIKit

class AddKindCollectionViewCell: UICollectionViewCell {
    @IBOutlet var akLabel: UILabel!
    @IBOutlet var akView: UIView!
    
    override var isSelected: Bool {
        didSet {
            if(self.isSelected){
                akView.layer.borderColor = UIColor(red: 255/255, green: 201/255, blue: 101/255, alpha: 1.0).cgColor
                akView.layer.borderWidth = 7
            }else{
                akView.layer.borderWidth = 0
            }
        }
    }
}
