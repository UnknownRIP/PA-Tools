//
//  PhonebookView.swift
//  CaptionApp
//
//  Created by 39ABW/PA on 2/26/23.
//

import SwiftUI

struct PhonebookView: View {
    @Environment(\.managedObjectContext) var moc //lets us add and remove stuff from the managedObjectContext (our phonebook datamodel) manually
    @FetchRequest(sortDescriptors: []) var contacts: FetchedResults<Contact>
    
    var body: some View {
        NavigationView{
            ZStack {
                Color.gray
                VStack {
                    
                    List {
                        ForEach(contacts) { Contact in
                            NavigationLink {
                                Text("1").foregroundColor(.white)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(Contact.first ?? "")
                                            .font(.headline)
                                        Text(Contact.last ?? "")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }.foregroundColor(.white)

                    //List(contacts) { Contact in
                    //   Text(Contact.first ?? "BLANK")
                    //}
                    Button("Add"){
                        let firstNames = ["Test1", "Test2"]
                        let lastNames = ["TestLast1", "TestLast2"]
                        
                        let chosenFirstName = firstNames.randomElement()!
                        let chosenLastName = lastNames.randomElement()!
                        
                        let Contact = Contact(context: moc)
                        Contact.id = UUID()
                        Contact.first = "\(chosenFirstName)"
                        Contact.last = "\(chosenLastName)"
                        
                        try? moc.save()
                        
                    }.padding(20)
                    Button("Reset"){
                        moc.reset()
                    }.padding(20)
                }
            }
            .navigationBarTitle("Phonebook", displayMode: .inline)
        }
    }
    
    func deleteContacts(at offsets: IndexSet) {
        for offset in offsets {
            // find this book in our fetch request
            let contactlist = contacts[offset]

            // delete it from the context
            moc.delete(contactlist)
        }

        // save the context
        try? moc.save()
    }
    
}

struct PhonebookView_Previews: PreviewProvider {
    static var previews: some View {
        PhonebookView()
    }
}
