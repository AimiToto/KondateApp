//
//  Realm.swift
//  Kondate
//
//  Created by 石川愛海 on 2022/06/06.
//

import Foundation
import RealmSwift

class Kondate: Object {
    @objc dynamic var id : String = UUID().uuidString
    @objc dynamic var imgUrl: String?
    @objc dynamic var name: String = ""
    @objc dynamic var kind: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var isOriginal: Bool = false
    @objc dynamic var isFavorite: Bool = false
    let ingredient = List<Ingredient>()
}

class Ingredient: Object {
    @objc dynamic var id : String = UUID().uuidString
    @objc dynamic var imgUrl: String?
    @objc dynamic var name: String = ""
}


