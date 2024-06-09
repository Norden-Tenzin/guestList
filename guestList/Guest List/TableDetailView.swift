//
//  TableDetailView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/14/24.
//

import SwiftUI

struct TableDetailView: View {
    var table: String
    @Binding var presentSheet: Bool

    var body: some View {
        VStack {
            Spacer()
//            Image(tableType[table] ?? "")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
            Spacer()
        }
            .overlay(alignment: .topLeading) {
            HStack {
                Button(action: {
                    presentSheet = false
                }, label: {
                        Image(systemName: "arrowtriangle.left.circle.fill")
                            .font(.system(size: 24))
                    })
                    .padding([.leading, .top], 15)
                Spacer()
            }
        }
            .background() {
            Color(red: 0.110, green: 0.110, blue: 0.110, opacity: 1.000)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    TableDetailView(table: "Lounge: T31", presentSheet: .constant(false))
}
