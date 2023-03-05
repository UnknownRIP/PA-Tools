//
//  ContentView.swift
//  CaptionApp
//
//  Created by 39ABW/PA on 2/23/23.
//

import UIKit
import SwiftUI
import iPhoneNumberField
import Introspect
import CropViewController

let coloredNavAppearance = UINavigationBarAppearance()

struct ImagePicker: UIViewControllerRepresentable {
 
    @Binding var selectedImage: UIImage

    @Environment(\.presentationMode) private var presentationMode
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var cameraType: UIImagePickerController.CameraDevice = .front
    var flashType: UIImagePickerController.CameraFlashMode = .off
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
     
        var parent: ImagePicker
     
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
     
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

                //if let image = UIGraphicsGetImageFromCurrentImageContext() {
                    //UIGraphicsEndImageContext()
                    //END CROPPING FUNCTION
                    //parent.selectedImage = image}
                //This was a test function to autocrop the photos that were taken, not currently implimented.
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
            
        }
    }
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
 
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.cameraDevice = cameraType
        imagePicker.cameraFlashMode = flashType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

}

struct CaptionCollectorView: View {
    
    @Environment(\.managedObjectContext) var moc //lets us add and remove stuff from the managedObjectContext (our caption datamodel) manually
    @FetchRequest(sortDescriptors: []) var captions: FetchedResults<Captions>
    
    init() {
            coloredNavAppearance.configureWithOpaqueBackground()
            coloredNavAppearance.backgroundColor = .systemBlue
            coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                   
            UINavigationBar.appearance().standardAppearance = coloredNavAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance

        }
    
    @State private var isShowPhotoLibrary = false //required for photopicker
    @State private var image = UIImage() //required for photopicker
    
    @State var firstname: String = "" //create firstname variable
    @State var middlei: String = "" //create middle initial variable
    @State var lastname: String = "" //create lastname variable
    @State var text: String = "" //create phonenumber variable
    @State var emailAddress: String = "" //create emailaddress variable
    @State var isEditing: Bool = false //check to see if phonenumber is being edited
    @State var rank: String = "" //create rank variable
    @State var duty: String = "" //create duty title/afsc/mos variable
    @State var unit: String = "" //create unit and chain variable
    @State var branch = "U.S. Air Force" //create branch variable
    @State var textcolor = Color.gray //set color of text in boxes that are required
    
    @State var isTextMissing: Bool = false //create textisMissing
    
    let branches = ["U.S. Air Force", "U.S. Navy", "U.S. Marine Corps", "U.S. Army", "U.S. Space Force", "U.S. Coast Guard"] //list branches
    var selectedView : some View = AirForceRanks() //default view is AirForceRanks (not needed anymore)
    
    enum CheckoutFocusableSectionOne: Hashable {
        case firstname
        case middlei
        case lastname
        case number
    }
    enum CheckoutFocusableSectionTwo: Hashable {
        case duty
        case unit
    }
    
    @FocusState private var checkoutInFocus: CheckoutFocusableSectionOne?
    @FocusState private var checkoutInFocustwo: CheckoutFocusableSectionTwo?
    
    var body: some View{
        NavigationView{
            ZStack {
                Form {
                    Section(header: Text("Contact Information")) {
                        Group {
                            TextField("First Name", text: $firstname).textInputAutocapitalization(.words).padding(5).background(firstname.isEmpty ? textColorItems : nil).focused($checkoutInFocus, equals: .firstname)
                            TextField("Middle Initial", text: $middlei).autocorrectionDisabled(true).textInputAutocapitalization(.characters).padding(5).focused($checkoutInFocus, equals: .middlei)
                            TextField("Last Name", text: $lastname).textInputAutocapitalization(.words).padding(5).background(lastname.isEmpty ? textColorItems : nil).focused($checkoutInFocus, equals: .lastname)
                        }/*.onTapGesture {self.hideKeyboard()}*/.submitLabel(.next)
                        iPhoneNumberField("Contact Number", text: $text, isEditing: $isEditing)
                            .flagHidden(false)
                            .flagSelectable(true)
                            .maximumDigits(10)
                            .foregroundColor(Color.white)
                            .clearButtonMode(.whileEditing)
                            .onClear { _ in isEditing.toggle() }
                            .cornerRadius(10)
                            .focused($checkoutInFocus, equals: .number)
                        TextField("Email Address", text: $emailAddress)
                            .textContentType(.emailAddress).keyboardType(.emailAddress).autocorrectionDisabled(true).textInputAutocapitalization(.never).padding(5)
                            /*.onTapGesture {self.hideKeyboard()}*/
                    }.accentColor(Color.gray).shadow(color: isEditing ? .gray : .white, radius: 0.9).introspectTextField(customize: addToolbar).cornerRadius(10).frame(maxWidth: .infinity, alignment: .center)
                        .onSubmit { //change focus
                        if checkoutInFocus == .firstname {
                          checkoutInFocus = .middlei
                        } else if checkoutInFocus == .middlei {
                          checkoutInFocus = .lastname
                        } else if checkoutInFocus == .lastname {
                            checkoutInFocus = .number
                        } else if checkoutInFocus == .number {
                            checkoutInFocus = nil
                        }
                    }
                    Section(header: Text("Rank and Unit Information"), footer: Text("*Spell out any acronyms please*")) {
                        Picker("Branch", selection: $branch) {
                            ForEach(branches, id: \.self) {
                                Text($0).tag($0) //creates branch selections per all the options above
                            }
                        }.padding(.horizontal, 5)
                        if (branch == "U.S. Air Force"){
                            AirForceRanks()
                            TextField("Duty Title/AFSC", text: $duty).padding(5).background(duty.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .duty).submitLabel(.next)
                            TextField("Unit, Squadron and Wing", text: $unit).padding(5).background(unit.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .unit)
                        }else if(branch == "U.S. Navy"){
                            NavyRanks()
                            TextField("Duty Title/MOS", text: $duty).padding(5).background(duty.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .duty).submitLabel(.next)
                            TextField("Unit & Chain", text: $unit).padding(5).background(unit.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .unit)
                        }else if(branch == "U.S. Marine Corps"){
                            MarineRanks()
                            TextField("Duty Title/MOS", text: $duty).padding(5).background(duty.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .duty).submitLabel(.next)
                            TextField("Unit & Chain", text: $unit).padding(5).background(unit.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .unit)
                        }else if(branch == "U.S. Army"){
                            ArmyRanks()
                            TextField("Duty Title/MOS", text: $duty).padding(5).background(duty.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .duty).submitLabel(.next)
                            TextField("Unit & Chain", text: $unit).padding(5).background(unit.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .unit)
                        }else if(branch == "U.S. Space Force"){
                            SpaceForceRanks()
                            TextField("Duty Title/SFSC", text: $duty).padding(5).background(duty.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .duty).submitLabel(.next)
                            TextField("Unit & Chain", text: $unit).padding(5).background(unit.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .unit)
                        }else if(branch == "U.S. Coast Guard"){
                            CoastGuardRanks()
                            TextField("Duty Title/MOS", text: $duty).padding(5).background(duty.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .duty).submitLabel(.next)
                            TextField("Unit & Chain", text: $unit).padding(5).background(unit.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .unit)
                        }else{
                            AirForceRanks()
                            TextField("Duty Title/AFSC", text: $duty).padding(5).background(duty.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .duty).submitLabel(.next)
                            TextField("Unit, Squadron and Wing", text: $unit).padding(5).background(unit.isEmpty ? textColorItems : nil)/*.onTapGesture {self.hideKeyboard()}*/.focused($checkoutInFocustwo, equals: .unit)
                        }
                    }.accentColor(Color.gray).shadow(color: isEditing ? .gray : .white, radius: 1).introspectTextField(customize: addToolbar).autocorrectionDisabled(true).cornerRadius(10).frame(maxWidth: .infinity, alignment: .center)
                        .onSubmit { //change focus
                            if checkoutInFocustwo == .duty {
                                checkoutInFocustwo = .unit
                            } else if checkoutInFocustwo == .unit {
                                checkoutInFocustwo = nil
                            }
                        }
                    Section(header: Text("*Red = Required*")){ //section for photo picker
                        VStack { //beginning of photo section
                         
                            Image(uiImage: self.image)
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .edgesIgnoringSafeArea(.all)
                         
                            Button(action: {
                                self.isShowPhotoLibrary = true
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 20))
                         
                                    Text("Take a selfie")
                                        .font(.headline)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .padding(.horizontal)
                            }
                        }.sheet(isPresented: $isShowPhotoLibrary) {
                            ImagePicker(selectedImage: self.$image, sourceType: .camera) //have user take photo (use .photolibrary for sourceType if wanting photo library instead)
                        } //end of photo section
                        .padding(.bottom, 15)
                    }.frame(maxWidth: .infinity, alignment: .center)
                }.padding(.horizontal, -12).padding(.bottom, 45)
                VStack{
                    Button("Save".uppercased()){
                        if formisfilled() {
                            let Captions = Captions(context: moc)
                            Captions.id = UUID()
                            Captions.first = "\(firstname)"
                            Captions.middlei = "\(middlei)"
                            Captions.last = "\(lastname)"
                            Captions.phonenumber = "\(text)"
                            Captions.email = "\(emailAddress)"
                            Captions.branch = "\(branch)"
                            Captions.rank = "\(rank)"
                            Captions.mos = "\(duty)"
                            Captions.unit = "\(unit)"
                            //Captions.photo = ""
                            try? moc.save()
                        }
                    }.padding(20)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                        .background(formisfilled() ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 25)
                        .disabled(!formisfilled())
                }.frame(maxHeight: .infinity, alignment: .bottom).padding(.bottom, 5)
            }.padding(.horizontal, -10)
            .navigationBarTitle("Caption Collector", displayMode: .inline)
        }.scrollDismissesKeyboard(.immediately)
    }
    
    func formisfilled() -> Bool{
        if firstname.count > 1 && lastname.count > 1 && duty.count > 1 && unit.count > 1 {
            return true
        }
        return false
    }
    

    
    struct AirForceRanks: View{
        @State private var AFrank = "Airman Basic"
        let AFranks = ["Airman Basic", "Airman", "Airman 1st Class", "Senior Airman", "Staff Sergeant", "Technical Sergeant", "Master Sergeant", "Senior Master Sergeant", "Chief Master Sergeant", "2nd Lieutenant", "1st Lieutenant", "Captain", "Major", "Lieutenant Colonel", "Colonel", "Brigadier General", "Major General", "Lieutenant General", "General"]
        var body: some View{
            Picker("Rank", selection: $AFrank) {
                ForEach(AFranks, id: \.self) {
                    Text($0)
                }
            }.padding(.horizontal, 5)
        }
    }
    struct NavyRanks: View{
        @State private var Nrank = "Seaman Recruit"
        let Nranks = ["Seaman Recruit", "Seaman Apprentice", "Seaman", "Petty Officer Third Class", "Petty Officer Second Class", "Petty Officer First Class", "Chief Petty Officer", "Senior Chief Petty Officer", "Master Chief Petty Officer", "Warrant Officer 1", "Warrant Officer 2", "Warrant Officer 3", "Warrant Officer 4", "Master Warrant Officer", "Ensign", "Lieutenant, Junior Grade", "Lieutenant", "Lieutenant Commander", "Commander", "Captain", "Rear Admiral (Commodore)", "Rear Admiral (Upper Half)", "Vice Admiral", "Admiral"]
        var body: some View{
            Picker("Rank", selection: $Nrank) {
                ForEach(Nranks, id: \.self) {
                    Text($0)
                }
            }.padding(.horizontal, 5)
        }
    }
    struct MarineRanks: View{
        @State private var Mrank = "Private"
        let Mranks = ["Private", "Private First Class", "Lance Corporal", "Corporal", "Sergeant", "Staff Sergeant", "Gunnery Sergeant", "First Sergeant/Master Sergeant", "Sergeant Major/Master Gunnery Sergeant", "Warrant Officer 1", "Chief Warrant Officer 2", "Chief Warrant Officer 3", "Chief Warrant Officer 4", "Chief Warrant Officer 5", "2nd Lieutenant", "1st Lieutenant", "Captain", "Major", "Lieutenant Colonel", "Colonel", "Brigadier General", "Major General", "Lieutenant General", "General"]
        var body: some View{
            Picker("Rank", selection: $Mrank) {
                ForEach(Mranks, id: \.self) {
                    Text($0)
                }
            }.padding(.horizontal, 5)
        }
    }
    struct ArmyRanks: View{
        @State private var Arank = "Private (Recruit)"
        let Aranks = ["Private (Recruit)", "Private", "Private First Class", "Specialist", "Corporal", "Sergeant", "Staff Sergeant", "Sergeant First Class", "First Sergeant/Master Sergeant", "Command Sergeant Major/Sergeant Major", "Warrant Officer 1", "Warrant Officer 2", "Warrant Officer 3", "Warrant Officer 4", "Master Warrant Officer 5", "2nd Lieutenant", "1st Lieutenant", "Captain", "Major", "Lieutenant Colonel", "Colonel", "Brigadier General", "Major General", "Lieutenant General", "General"]
        var body: some View{
            Picker("Rank", selection: $Arank) {
                ForEach(Aranks, id: \.self) {
                    Text($0)
                }
            }.padding(.horizontal, 5)
        }
    }
    struct SpaceForceRanks: View{
        @State private var SFrank = "Specialist 1"
        let SFranks = ["Specialist 1", "Specialist 2", "Specialist 3", "Specialist 4", "Sergeant", "Technical Sergeant", "Master Sergeant", "Senior Master Sergeant", "Chief Master Sergeant", "Space Force 2nd Lieutenant", "1st Lieutenant", "Captain", "Major", "Lieutenant Colonel", "Colonel", "Brigadier General", "Major General", "Lieutenant General", "General"]
        var body: some View{
            Picker("Rank", selection: $SFrank) {
                ForEach(SFranks, id: \.self) {
                    Text($0)
                }
            }.padding(.horizontal, 5)
        }
    }
    struct CoastGuardRanks: View{
        @State private var CGrank = "Seaman Recruit"
        let CGranks = ["Seaman Recruit", "Seaman Apprentice", "Seaman", "Petty Officer Third Class", "Petty Officer Second Class", "Petty Officer First Class", "Chief Petty Officer", "Senior Chief Petty Officer", "Master Chief Petty Officer", "Warrant Officer 1", "Warrant Officer 2", "Warrant Officer 3", "Warrant Officer 4", "Master Warrant Officer", "Ensign", "Lieutenant, Junior Grade", "Lieutenant", "Lieutenant Commander", "Commander", "Captain", "Rear Admiral (Commodore)", "Rear Admiral (Upper Half)", "Vice Admiral", "Admiral"]
        var body: some View{
            Picker("Rank", selection: $CGrank) {
                ForEach(CGranks, id: \.self) {
                    Text($0)
                }
            }.padding(.horizontal, 5)
        }
    }
    
    @ViewBuilder //section to change background to red if field is empty
    var textColorItems: some View {
        //if isTextMissing {
            LinearGradient(colors: [.red.opacity(0.2), .red.opacity(0.0)], startPoint: .topLeading, endPoint: .bottomTrailing)
        //} else {
            //Leave background empty
        //}
    }
    
}

extension View {
    
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
//                                        to: nil, from: nil, for: nil)
//    }
    
    func addToolbar(to textField: UITextField) { //added for the done button
        let toolBar = UIToolbar(
          frame: CGRect(
            origin: .zero,
            size: CGSize(width: textField.frame.size.width, height: 44)
          )
        )
        let flexButton = UIBarButtonItem(
          barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
          target: nil,
          action: nil
        )
        let doneButton = UIBarButtonItem(
          title: "Done",
          style: .done,
          target: self,
          action: #selector(textField.didTapDoneButton(_:))
        )
        toolBar.setItems([flexButton, doneButton], animated: true)
        textField.inputAccessoryView = toolBar
      } //end done button section
}

extension  UITextField { //added for the done button
    @objc func didTapDoneButton(_ button: UIBarButtonItem) -> Void {
    resignFirstResponder()
  }
}

struct ContentView: View { //Section for the Tabs
    
    var body: some View {
        TabView{
         CaptionCollectorView()
                .tabItem{
                    Image(systemName: "character.textbox")
                    Text("Caption Collector")
                }
         RecentCaptionsView()
                .tabItem{
                    Image(systemName: "list.bullet.clipboard")
                    Text("Recents")
                }
         PhonebookView()
                .tabItem{
                    Image(systemName: "phone")
                    Text("Phonebook")
                }
        }
        
    }
} //End Section for the Tabs

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
