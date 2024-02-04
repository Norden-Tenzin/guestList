//
//  HelperFunctions.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import Foundation

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
