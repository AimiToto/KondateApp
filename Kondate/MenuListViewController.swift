//
//  MenuListViewController.swift
//  Kondate
//
//  Created by 石川愛海 on 2022/06/11.
//

import UIKit
import Foundation
import RealmSwift

class MenuListViewController: UIViewController {
    
    @IBOutlet var MenuList: UICollectionView!
    let realm = try! Realm()
    var kondates = [Kondate]()
    var randomArray = [Int]()
    
    var theMenu: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 254/255, green: 247/255, blue: 219/255, alpha: 1.0)
        MyNavigationSet()
        
        MenuList.delegate = self
        MenuList.dataSource = self
        getKondatesData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getKondatesData()
        // Do any additional setup after loading the view.
    }
    
    //Segue準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "thisMenu2" {
            let nextVC = segue.destination as! MenuViewController
            nextVC.thisMenu = theMenu
            nextVC.fromMenuList = true
        }
    }
    
    //Realmから材料データを取得＆リストを更新
    func getKondatesData() {
        kondates = Array(realm.objects(Kondate.self))
        MenuList.reloadData()
        randomArray = [Int](1...kondates.count).shuffled()
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
}

extension MenuListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // CollectionViewが何個のCellを表示するのか設定するデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        kondates.count
    }
    // Cellの中身を設定するデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath)
        guard let menuImageView = cell.viewWithTag(1) as? UIImageView,
              let menuLabel = cell.viewWithTag(2) as? UILabel,
              let maruView = cell.viewWithTag(3),
              let kageView = cell.viewWithTag(4) else { return cell }

        let randomNum = randomArray[indexPath.row]
        let kondate = kondates[randomNum - 1]
        menuLabel.text = kondate.name
        if  kondate.isOriginal {
            let imageFileName = kondate.imgUrl
            let path = getImageURL(fileName: imageFileName!).path // 画像のパスを取得
            if FileManager.default.fileExists(atPath: path) { // pathにファイルが存在しているかチェック
                if let imageData = UIImage(contentsOfFile: path) { // pathに保存されている画像を取得
                    menuImageView.image = imageData
                } else {
                    print("Failed to load the image. path = ", path)
                }
            }
        } else {
            menuImageView.image = UIImage(named: kondate.imgUrl!)
        }
        // Cellの見た目をカスタマイズ
        menuImageView.layer.cornerRadius = 10
        kageView.backgroundColor = .white
        kageView.layer.cornerRadius = 10
        kageView.layer.masksToBounds = false
        kageView.layer.shadowColor = UIColor.black.cgColor
        kageView.layer.shadowOpacity = 0.2
        kageView.layer.shadowRadius = 2
        kageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        maruView.backgroundColor = .white
        maruView.layer.cornerRadius = 10
        maruView.layer.masksToBounds = true
        return cell
    }
    
    // URLを取得するメソッド
    func getImageURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }
    
    //didSelectItemAtでcellを選択した時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let randomNum = randomArray[indexPath.row]
        let kondate = kondates[randomNum - 1]
        theMenu = kondate.name
        performSegue(withIdentifier: "thisMenu2", sender: nil)
    }
}

extension MenuListViewController: UICollectionViewDelegateFlowLayout {
    // Cellのサイズを設定するデリゲートメソッド
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth: CGFloat = MenuList.frame.width - 20
        let widthSize = availableWidth / 2
        return CGSize(width: widthSize, height: widthSize + 35)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    }
}

