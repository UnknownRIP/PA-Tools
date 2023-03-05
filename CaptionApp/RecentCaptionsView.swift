//
//  RecentCaptionsView.swift
//  CaptionApp
//
//  Created by 39ABW/PA on 2/26/23.
//

import SwiftUI

struct RecentCaptionsView: View {
    var body: some View {
        NavigationView{
            ZStack {
                Color.gray
            }
            .navigationBarTitle("Recents", displayMode: .inline)
        }
    }
}

struct RecentCaptionsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentCaptionsView()
    }
}
