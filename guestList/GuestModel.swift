//
//  Guest.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import FirebaseFirestore
import Foundation

struct Guest: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var uid: String
    var dateCreated: Date
    var name: String
    var guestCount: Int
    var tableSelection: String
    var isVip: Bool
    var isFreeEntry: Bool
    var isDiscount: Bool
    var isArchived: Bool
    var additionalInfo: String

//    init(uid: String, name: String, guestCount: Int, tableSelection: TableType, isVip: Bool, isFreeEntry: Bool, isDiscount: Bool) {
//        self.uid = uid
//        self.name = name
//        self.guestCount = guestCount
//        self.tableSelection = tableSelection
//        self.isVip = isVip
//        self.isFreeEntry = isFreeEntry
//        self.isDiscount = isDiscount
//    }
}
