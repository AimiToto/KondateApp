//
//  FoodListViewController.swift
//  Kondate
//
//  Created by 石川愛海 on 2022/06/11.
//

import UIKit
import Foundation
import RealmSwift

class FoodListViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet var FoodList: UICollectionView!
    let realm = try! Realm()
    var ingredients = [Ingredient]()
    var selectFoods = [Ingredient]()
    var keepKind = ""
    var keepCategory = ""
    var keepName = ""
    var keepImage: UIImage! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 254/255, green: 247/255, blue: 219/255, alpha: 1.0)
        MyNavigationSet()
        navigationController?.delegate = self
        FoodList.allowsMultipleSelection = true
        
        FoodList.delegate = self
        FoodList.dataSource = self
        getIngredientsData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getIngredientsData()
        // Do any additional setup after loading the view.
    }

    //Segue準備
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 遷移先が、AViewControllerだったら……
        if let nextVC = viewController as? MenuAddViewController {
            nextVC.ingredients = selectFoods
            nextVC.selectKind = keepKind
            nextVC.selectCategory = keepCategory
            nextVC.formedName = keepName
            nextVC.formedImage = keepImage
        }
    }
    
    //Realmから材料データを取得＆リストを更新
    func getIngredientsData() {
        ingredients = Array(realm.objects(Ingredient.self))
        FoodList.reloadData()
    }
    
    //見た目を整える
    func MyNavigationSet() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 255/255, green: 201/255, blue: 101/255, alpha: 1.0)
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 201/255, blue: 101/255, alpha: 1.0)
            navigationController?.navigationBar.tintColor = UIColor.white
        }
    }
    
    //材料を追加するためのポップアップウィンドウ
    @IBAction func FoodAdd(_ sender: Any) {
        var foodTextField = UITextField()
        let foodAlert = UIAlertController(title: "新しい材料を追加", message: "", preferredStyle: .alert)
        let foodAddCancel = UIAlertAction(title: "キャンセル", style: .destructive) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        let foodAddAction = UIAlertAction(title: "追加", style: .default) { (action) in
            guard let text = foodTextField.text, !text.isEmpty,
                  let foodText = foodTextField.text else { return }
            self.ingreAdd(IngreText: foodText)
            self.getIngredientsData()
            self.dismiss(animated: true, completion: nil)
        }
        foodAlert.addTextField { (textField) in
            textField.placeholder = "トマト"
            foodTextField = textField
        }
        foodAlert.addAction(foodAddCancel)
        foodAlert.addAction(foodAddAction)
        present(foodAlert, animated: true, completion: nil)
    }
    func ingreAdd(IngreText: String) {
        let ingredient = Ingredient()
        ingredient.id = UUID().uuidString
        ingredient.name = IngreText
        try! realm.write({
            realm.add(ingredient)
        })
    }
}

extension FoodListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // CollectionViewが何個のCellを表示するのか設定するデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ingredients.count
    }
    // Cellの中身を設定するデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCell", for: indexPath)
        guard let foodImageView = cell.viewWithTag(1) as? UIImageView,
              let foodLabel = cell.viewWithTag(2) as? UILabel,
              let maruView = cell.viewWithTag(3) else { return cell }
        
        let ingredient = ingredients[indexPath.row]
        foodLabel.text = ingredient.name
        if ingredient.imgUrl != nil {
            foodImageView.image = UIImage(named: ingredient.imgUrl!)
        } else {
            foodImageView.image = UIImage()
        }
        if selectFoods.contains(where: {$0.name == ingredient.name}) {
            FoodList.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        // Cellの見た目をカスタマイズ
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowRadius = 2
        cell.layer.shadowOffset = CGSize(width: 2, height: 2)
        maruView.backgroundColor = .white
        maruView.layer.cornerRadius = 10
        maruView.layer.masksToBounds = true
        return cell
    }
    
    //didSelectItemAtでcellを選択した時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = ingredients[indexPath.row]
        selectFoods.append(selected)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selected = ingredients[indexPath.row]
        selectFoods.removeAll(where: {$0 == selected})
    }
}

extension FoodListViewController: UICollectionViewDelegateFlowLayout {
    // Cellのサイズを設定するデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth: CGFloat = FoodList.frame.width - 20
        return CGSize(width: availableWidth / 2, height: 70)
    }
    // Cellの間隔を設定するデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 10)
    }
}
