//
//  SplashScreenView.swift
//  CaptionApp
//
//  Created by 39ABW/PA on 2/23/23.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                LinearGradient(colors: [.purple, .indigo],
                                       startPoint: .top,
                                       endPoint: .bottom)
                //Color.blue
                    //.ignoresSafeArea()
                VStack {
                    VStack {
                        
                        Image("AFCaption")
                            .font(.system(size: 80))
                        Text("Public Affairs Tools")
                            .font(Font.custom("Noteworthy", size: 26))
                            .foregroundColor(Color(uiColor: .white).opacity(0.80))
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 0.5)) {
                            self.size = 0.9
                            self.opacity = 1.0
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
