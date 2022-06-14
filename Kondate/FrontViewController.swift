//
//  FrontViewController.swift
//  Kondate
//
//  Created by 石川愛海 on 2022/06/06.
//

import UIKit
import RealmSwift

class FrontViewController: UIViewController {
    
    @IBOutlet var FrameView: UIView!
    @IBOutlet var ChangeButton: UIButton!
    @IBOutlet var MenuImage: UIImageView!
    @IBOutlet var MenuLabel: UILabel!
    
    let realm = try! Realm()
    var kondates = [Kondate]()
    var randomArray = [Int]()
    var arrayNum: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 254/255, green: 247/255, blue: 219/255, alpha: 1.0)
        MyNavigationSet()
        AppearanceSet()
        
        kondates = Array(realm.objects(Kondate.self))
        randomArray = [Int](1...kondates.count).shuffled()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        randomKondate()
    }
    
    //Segue準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "thisMenu" {
            let nextVC = segue.destination as! MenuViewController
            nextVC.thisMenu = MenuLabel.text!
        }
    }
    
    @IBAction func kondatesShuffle() {
        if arrayNum < randomArray.count - 1{
            arrayNum = arrayNum + 1
        } else {
            arrayNum = 0
        }
        randomKondate()
    }
    
    //ランダムに料理を表示
    func randomKondate() {
        let randomNum = randomArray[arrayNum]
        let kondate = kondates[randomNum - 1]
        MenuLabel.text = kondate.name
        if  kondate.isOriginal {
            let imageFileName = kondate.imgUrl
            let path = getImageURL(fileName: imageFileName!).path // 画像のパスを取得
            if FileManager.default.fileExists(atPath: path) { // pathにファイルが存在しているかチェック
                if let imageData = UIImage(contentsOfFile: path) { // pathに保存されている画像を取得
                    MenuImage.image = imageData
                } else {
                    print("Failed to load the image. path = ", path)
                }
            }
        } else {
            MenuImage.image = UIImage(named: kondate.imgUrl!)
        }
    }
    
    // URLを取得するメソッド
    func getImageURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
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
    func AppearanceSet() {
        FrameView.layer.cornerRadius = 22
        FrameView.layer.shadowColor = UIColor.black.cgColor
        FrameView.layer.shadowOpacity = 0.3
        FrameView.layer.shadowRadius = 3
        FrameView.layer.shadowOffset = CGSize(width: 3, height: 3)
        ChangeButton.layer.cornerRadius = 10
        ChangeButton.layer.shadowColor = UIColor.black.cgColor
        ChangeButton.layer.shadowOpacity = 0.3
        ChangeButton.layer.shadowRadius = 2
        ChangeButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        MenuImage.layer.cornerRadius = 22
    }
}
