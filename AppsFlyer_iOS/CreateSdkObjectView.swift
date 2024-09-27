//
//  CreateSdkObjectView.swift
//  Firebase_iOS
//
//  Created by Robin Kirchner on 29.08.23.
//

import SwiftUI

struct CreateSdkObjectView: View {
    @EnvironmentObject var sdkManager: SDKManager
    
    var body: some View {
        ZStack {
            Text("SDK object has been created.")
        }
        .onAppear {
            sdkManager.createSdkObject()
            print("CreateSdkObjectView.onAppear")
        }
    }
}

struct CreateSdkObjectView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview with a AppsFlyerManager instance
        let sdkManager = SDKManager()
        
        // Wrap the StartView in a NavigationView to match your app's structure
        NavigationView {
            CreateSdkObjectView()
                .environmentObject(sdkManager)
        }
    }
}
