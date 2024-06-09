//
//  HelperFunctions.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import Foundation
import SwiftUI

//  Returns Current Date from Date selection
//  "Today" / "10 Jan 2019"
//  returns: String
func getTitleFromDate(selection: Date) -> String {
    if getDate(date: selection) == getDate(date: Date.now) {
        return "Today"
    } else {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM YYYY"
        return dateFormatter.string(from: selection)
    }
}

//  Formats Date in the "month/date/year" format
//  returns: String
func getDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: date)
}

// Protocol to implement Multiple Sheets
protocol MultipleSheetDisplaying where Self: Equatable {
    associatedtype SheetContent: View

    // This the none displaying modal enum case. Should always be present
    static var none: Self { get }

    // This is the binding boolean used to toggle the sheet display
    var shouldDisplay: Bool { get set }

    // This function will help display the wanted modal. This could be removed and add to the view.
    func display() -> SheetContent
}

extension MultipleSheetDisplaying {
    var shouldDisplay: Bool {
        get {
            switch self {
            case .none:
                return false
            default:
                return true
            }
        }
        set(newValue) {
            self = newValue ? self : .none
        }
    }
}
