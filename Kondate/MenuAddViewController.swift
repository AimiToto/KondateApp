//
//  MenuAddViewController.swift
//  Kondate
//
//  Created by 石川愛海 on 2022/06/14.
//

import Foundation
import UIKit
import RealmSwift

class MenuAddViewController: UIViewController {
    
    @IBOutlet var imageButton: UIButton!
    @IBOutlet var menuTextFeild: UITextField!
    @IBOutlet var foodList: UICollectionView!
    @IBOutlet var kindList: UICollectionView!
    @IBOutlet var categoryList: UICollectionView!
    @IBOutlet weak var foodListHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    let realm = try! Realm()
    var ingredients = [Ingredient]()
    var kinds = [String]()
    var categorys = [String]()
    var selectKind = ""
    var selectCategory = ""
    var formedName = ""
    var formedImage: UIImage! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 254/255, green: 247/255, blue: 219/255, alpha: 1.0)
        MyNavigationSet()
        reloadList()
        keepInfo()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadList()
        keepInfo()
        // Do any additional setup after loading the view.
    }
    
    //foodListを任意の高さに設定
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if (ingredients.count % 2) == 0 {
            let foodlistH = CGFloat(ingredients.count / 2 * 80)
            foodListHeight.constant = foodlistH
            scrollViewHeight.constant = CGFloat(1000 + foodlistH)
        } else {
            let foodlistH = CGFloat(ingredients.count / 2 * 80 + 80)
            foodListHeight.constant = foodlistH
            scrollViewHeight.constant = CGFloat(1000 + foodlistH)
        }
    }
    
    //各Listを更新
    func reloadList() {
        foodList.reloadData()
        kindList.reloadData()
        categoryList.reloadData()
    }
    
    //Segue準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addFood" {
            let nextVC = segue.destination as! FoodListViewController
            nextVC.selectFoods = ingredients
            nextVC.keepKind = selectKind
            nextVC.keepCategory = selectCategory
            if menuTextFeild.text != "" {
                formedName = menuTextFeild.text!
                nextVC.keepName = formedName
            }
            if imageButton.backgroundImage(for: .normal) != nil {
                formedImage = imageButton.backgroundImage(for: .normal)
                nextVC.keepImage = formedImage
            }
        }
    }
    
    //ここからメニューを追加するためのコード
    // 保存ボタンを押したときのアクション
    @IBAction func didTapSaveButton() {
        do{
            guard let _ = menuTextFeild.text,
            imageButton.backgroundImage(for: .normal) != nil,
            0 < ingredients.count else { return }
            let kondate = Kondate()
            kondate.id = UUID().uuidString
            let menuText = menuTextFeild.text!
            kondate.name = menuText
            let menuImage = imageButton.backgroundImage(for: .normal)!
            let imageURLStr = saveImage(image: menuImage)
            kondate.imgUrl = imageURLStr
            kondate.kind = selectKind
            kondate.category = selectCategory
            kondate.isOriginal = true
            kondate.isFavorite = false
            let ingres = ingredients
            kondate.ingredient.append(objectsIn: ingres)
            try! realm.write({
                realm.add(kondate)
                print("成功！", kondate)
            })
        } catch {
            print("エラーだよ、、、")
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // 画像を保存するメソッド
    func saveImage(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        
        do {
            let fileName = UUID().uuidString + ".jpeg" // ファイル名を決定(UUIDは、ユニークなID)
            let imageURL = getImageURL(fileName: fileName) // 保存先のURLをゲット
            try imageData.write(to: imageURL) // imageURLに画像を書き込む
            return fileName
        } catch {
            print("Failed to save the image:", error)
            return nil
        }
    }
    // URLを取得するメソッド
    func getImageURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }
    // 画像選択ボタンを押したときのアクション
    @IBAction func didTapImageButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    //見た目を整えるためのメソッド
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
    func keepInfo() {
        if formedName != "" {
            menuTextFeild.text = formedName
        }
        if formedImage != nil {
            imageButton.setBackgroundImage(formedImage, for: .normal)
        }
    }
}

extension MenuAddViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // ライブラリから戻ってきた時に呼ばれるデリゲートメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return picker.dismiss(animated: true) }
        imageButton.setBackgroundImage(pickedImage, for: .normal) // imageButtonのバックグラウンドに選択した画像をセット
        picker.dismiss(animated: true)
    }
}

extension MenuAddViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // CollectionViewが何個のCellを表示するのか設定するメソッド
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == foodList && ingredients.count >= 1 {
            return ingredients.count
        } else if collectionView == kindList {
            return 5
        } else if collectionView == categoryList {
            return 5
        } else {
            return 0
        }
    }
    // Cellの中身を設定するメソッド
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == foodList {
            let aicell = collectionView.dequeueReusableCell(withReuseIdentifier: "addIngredient", for: indexPath)
            guard let aiImageView = aicell.viewWithTag(1) as? UIImageView,
                  let aiLabel = aicell.viewWithTag(2) as? UILabel,
                  let aiView = aicell.viewWithTag(3) else { return aicell }
            
            if ingredients.count >= 1 {
                let ingre = ingredients[indexPath.row]
                aiLabel.text = ingre.name
                if ingre.imgUrl != nil {
                    aiImageView.image = UIImage(named: ingre.imgUrl!)
                } else {
                    aiImageView.image = UIImage()
                }
                // Cellの見た目をカスタマイズ
                aicell.backgroundColor = .white
                aicell.layer.cornerRadius = 10
                aicell.layer.borderWidth = 7
                aicell.layer.borderColor = UIColor(red: 255/255, green: 201/255, blue: 101/255, alpha: 1.0).cgColor
                aicell.layer.masksToBounds = false
                aicell.layer.shadowColor = UIColor.black.cgColor
                aicell.layer.shadowOpacity = 0.2
                aicell.layer.shadowRadius = 2
                aicell.layer.shadowOffset = CGSize(width: 2, height: 2)
                aiView.backgroundColor = .white
                aiView.layer.cornerRadius = 10
                aiView.layer.masksToBounds = true
            }
            return aicell
            
        } else if collectionView == kindList {
            let akcell = collectionView.dequeueReusableCell(withReuseIdentifier: "addKind", for: indexPath)
            guard let akLabel = akcell.viewWithTag(1) as? UILabel,
                  let akView = akcell.viewWithTag(2) else { return akcell }
            
            kinds = ["和食", "洋食", "中華料理", "韓国料理", "その他"]
            let kind = kinds[indexPath.row]
            akLabel.text = kind
            if kind == selectKind {
                kindList.selectItem(at: indexPath, animated: true, scrollPosition: [])
            }
            
            akcell.backgroundColor = .white
            akcell.layer.cornerRadius = 10
            akcell.layer.masksToBounds = false
            akcell.layer.shadowColor = UIColor.black.cgColor
            akcell.layer.shadowOpacity = 0.2
            akcell.layer.shadowRadius = 2
            akcell.layer.shadowOffset = CGSize(width: 2, height: 2)
            akView.backgroundColor = .white
            akView.layer.cornerRadius = 10
            akView.layer.masksToBounds = true
            
            return akcell
            
        } else if collectionView == categoryList {
            let accell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCategory", for: indexPath)
            guard let acLabel = accell.viewWithTag(1) as? UILabel,
                  let acView = accell.viewWithTag(2) else { return accell }
            
            categorys = ["主食", "主菜", "副菜", "スープ", "デザート", "その他"]
            let category = categorys[indexPath.row]
            acLabel.text = category
            if category == selectCategory {
                categoryList.selectItem(at: indexPath, animated: true, scrollPosition: [])
            }
            
            accell.backgroundColor = .white
            accell.layer.cornerRadius = 10
            accell.layer.masksToBounds = false
            accell.layer.shadowColor = UIColor.black.cgColor
            accell.layer.shadowOpacity = 0.2
            accell.layer.shadowRadius = 2
            accell.layer.shadowOffset = CGSize(width: 2, height: 2)
            acView.backgroundColor = .white
            acView.layer.cornerRadius = 10
            acView.layer.masksToBounds = true
            
            return accell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
            return cell
        }
    }
    
    //cellを選択した時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == kindList {
            let akcell = collectionView.dequeueReusableCell(withReuseIdentifier: "addKind", for: indexPath)
            akcell.layer.borderColor = UIColor(red: 255/255, green: 201/255, blue: 101/255, alpha: 1.0).cgColor
            akcell.layer.borderWidth = 7
            let selected = kinds[indexPath.row]
            selectKind = selected
        } else if collectionView == categoryList {
            let accell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCategory", for: indexPath)
            accell.layer.borderColor = UIColor(red: 255/255, green: 201/255, blue: 101/255, alpha: 1.0).cgColor
            accell.layer.borderWidth = 7
            let selected = categorys[indexPath.row]
            selectCategory = selected
        }
    }
}

extension MenuAddViewController: UICollectionViewDelegateFlowLayout {
    // Cellのサイズを設定するデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth: CGFloat = foodList.frame.width - 20
        let widthSize = availableWidth / 2
        return CGSize(width: widthSize, height: 70)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }
}


