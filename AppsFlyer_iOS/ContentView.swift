//
//  ContentView.swift
//  AdMob_iOS
//
//  Created by Robin Kirchner on 29.08.23.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var sdkManager: SDKManager
    
    var body: some View {
        ZStack {
            
        }
        .onAppear {
            print("ContentView.onAppear")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview with a AppsFlyerManager instance
        let sdkManager = SDKManager()
        
        // Wrap the StartView in a NavigationView to match your app's structure
        NavigationView {
            ContentView()
                .environmentObject(sdkManager)
        }
    }
}
