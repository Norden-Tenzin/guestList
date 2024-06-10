//
//  WeekBarView.swift
//  CaloriesTracker
//
//  Created by Tenzin Norden on 11/25/23.
//

import SwiftUI

//  MARK: - WEEK BAR VIEW

struct WeekBarView: View {
    @State var today: Date = Date()
    @State var week: [Date] = []
    @Binding var selection: Date
    @State var presentAlert: Bool = false

    var body: some View {
        HStack {
            ForEach(week, id: \.self) { date in
                if let last = week.last {
//                    if date <= today {
//                        WeekBarItem(date: date, selection: $selection, today: today)
//                            .onTapGesture {
//                            selection = date
//                        }
//                    } else {
//                        WeekBarItem(date: date, selection: $selection, today: today)
//                            .onTapGesture {
//                            presentAlert = true
//                        }
//                    }
                    WeekBarItem(date: date, selection: $selection, today: today)
                        .onTapGesture {
                            selection = date
                        }
                    if last != date {
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            today = Date.now
            print(Date())
            print(today)

            let calendar = Calendar(identifier: .gregorian)
            let currentDate = Date()
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss:Z"
            df.timeZone = calendar.timeZone
            print(df.string(from: currentDate))

            week = []
            let dayNames = [
                "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
                "Saturday",
                "Sunday",
            ]

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "eeee"
            let todaysDay = dateFormatter.string(from: today)
            print(todaysDay)

            for index in [0, 1, 2, 3, 4, 5, 6] {
                let calendar = Calendar.current
                var dateComponents = DateComponents()
                var aditionalCheck = false

                // Define the date components to subtract
                let todayIndex = dayNames.firstIndex(of: todaysDay)!

                let components = calendar.dateComponents([.hour, .minute], from: today)
                if let hour = components.hour {
                    // Check if the current hour is less than 5
                    if hour < 5 {
                        if todayIndex == 0 {
                            aditionalCheck = true
                            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
                            selection = yesterday
                        } else {
                            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
                            selection = yesterday
                        }
                    }
                }

                dateComponents.day = index - todayIndex - (aditionalCheck ? 7 : 0)

                // Subtract days from the current date
                week.append(calendar.date(byAdding: dateComponents, to: today)!)
            }
        }
    }
}

//  MARK: - WEEK BAR ITEM VIEW

struct WeekBarItem: View {
    @State var date: Date
    @Binding var selection: Date
    @State var weekDay: String = ""
    @State var dateNum: String = ""
    let today: Date

    var body: some View {
        VStack {
            if getDate(date: date) == getDate(date: selection) {
                Text(weekDay)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(.bg))
            } else if date > today {
                Text(weekDay)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(.customGray))
            } else {
                Text(weekDay)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white)
            }
            Text(dateNum)
                .fontWeight(.bold)
                .padding(6)
                .foregroundStyle(date > today ? Color(.customGray) : Color.white)
                .background {
                    Circle()
                        .fill(getDate(date: date) == getDate(date: selection) ? Color(.bg) : Color.clear)
                }
        }
        .padding(.top, 5)
        .padding(5)
        .background {
            if getDate(date: date) == getDate(date: selection) {
                Capsule()
                    .fill(Color(.accent))
            }
        }
        .onAppear {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "eee"
            weekDay = dateFormatter.string(from: date)

            dateFormatter.dateFormat = "dd"
            dateNum = dateFormatter.string(from: date)
        }
    }
}

#Preview(body: {
    @State var selection: Date = Date.now
    return WeekBarView(selection: $selection)
})
