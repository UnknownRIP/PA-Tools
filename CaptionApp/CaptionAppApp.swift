//
//  CaptionAppApp.swift
//  CaptionApp
//
//  Created by 39ABW/PA on 2/23/23.
//

import SwiftUI

@main
struct CaptionAppApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(\.managedObjectContext, dataController.container.viewContext) //lets you work with the phonebook data in memory
        }
    }
}
