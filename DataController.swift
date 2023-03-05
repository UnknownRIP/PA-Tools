//
//  DataController.swift
//  CaptionApp
//
//  Created by 39ABW/PA on 2/27/23.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "phonebook") //This is initializing the actual data being loading to the device for the phonebook
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
