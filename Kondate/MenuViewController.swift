//
//  MenuViewController.swift
//  Kondate
//
//  Created by 石川愛海 on 2022/06/13.
//

import UIKit
import RealmSwift


class MenuViewController: UIViewController {

    @IBOutlet var FrameView: UIView!
    @IBOutlet var MenuImage: UIImageView!
    @IBOutlet var MenuLabel: UILabel!
    @IBOutlet var MenuFoodList: UITableView!
    @IBOutlet weak var foodListHeight: NSLayoutConstraint!
    var fromMenuList = false
    
    var thisMenu = ""
    let realm = try! Realm()
    var kondate = [Kondate]()
    var kondateFoods = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 254/255, green: 247/255, blue: 219/255, alpha: 1.0)
        MyNavigationSet()
        AppearanceSet()
        kondateSet()
        // Do any additional setup after loading the view.
    }
    
    //foodListを任意の高さに設定
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
            foodListHeight.constant = CGFloat(kondateFoods.count * 70)
    }
    
    //Menuを設定するメソッド
    func kondateSet() {
        MenuFoodList.backgroundColor = UIColor(red: 254/255, green: 247/255, blue: 219/255, alpha: 1.0)
        let kondate = realm.objects(Kondate.self).filter("name = %@", thisMenu)
        MenuLabel.text = kondate[0].name
        if  kondate[0].isOriginal {
            let imageFileName = kondate[0].imgUrl
            let path = getImageURL(fileName: imageFileName!).path // 画像のパスを取得
            if FileManager.default.fileExists(atPath: path) { // pathにファイルが存在しているかチェック
                if let imageData = UIImage(contentsOfFile: path) { // pathに保存されている画像を取得
                    MenuImage.image = imageData
                } else {
                    print("Failed to load the image. path = ", path)
                }
            }
        } else {
            MenuImage.image = UIImage(named: kondate[0].imgUrl!)
        }
        kondateFoods = Array(kondate[0].ingredient.value(forKey: "name"))
    }
    
    // URLを取得するメソッド
    func getImageURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }

    //見た目を整えるためのメソッド
    func MyNavigationSet() {
        if fromMenuList == true {
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 255/255, green: 201/255, blue: 101/255, alpha: 1.0);
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
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
    func AppearanceSet() {
        FrameView.layer.cornerRadius = 22
        FrameView.layer.shadowColor = UIColor.black.cgColor
        FrameView.layer.shadowOpacity = 0.3
        FrameView.layer.shadowRadius = 3
        FrameView.layer.shadowOffset = CGSize(width: 3, height: 3)
        MenuImage.layer.cornerRadius = 22
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    // CollectionViewが何個のCellを表示するのか設定するメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        kondateFoods.count
    }
    // Cellの中身を設定するメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuFoodCell", for: indexPath)
        guard let mfImageView = cell.viewWithTag(1) as? UIImageView,
              let mfLabel = cell.viewWithTag(2) as? UILabel,
              let maruView = cell.viewWithTag(3) else { return cell }
        let kondatefood = kondateFoods[indexPath.row]
        let ingredient = realm.objects(Ingredient.self).filter("name = %@", kondatefood)
        mfLabel.text = ingredient[0].name

        if ingredient[0].imgUrl != nil {
            mfImageView.image = UIImage(named: ingredient[0].imgUrl!)
        } else {
            mfImageView.image = UIImage()
        }
        // Cellの見た目をカスタマイズ
        maruView.layer.cornerRadius = 10
        maruView.layer.masksToBounds = false
        maruView.layer.shadowColor = UIColor.black.cgColor
        maruView.layer.shadowOpacity = 0.2
        maruView.layer.shadowRadius = 2
        maruView.layer.shadowOffset = CGSize(width: 2, height: 2)
        maruView.backgroundColor = UIColor.white
        maruView.layer.cornerRadius = 10
        return cell
    }
}
