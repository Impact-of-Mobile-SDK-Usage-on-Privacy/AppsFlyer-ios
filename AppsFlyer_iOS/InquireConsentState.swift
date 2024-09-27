//
//  InquireConsentState.swift
//  Firebase_iOS
//
//  Created by Robin Kirchner on 28.08.23.
//

import SwiftUI
import AppTrackingTransparency
import AdSupport


struct InquireConsentView: View {
    @EnvironmentObject var sdkManager: SDKManager
    
    var body: some View {
        ZStack {
            VStack {                
                Button(action: {
                    sdkManager.giveGDPRAndPersonalizedAdsConsent()
                }, label: {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Text("Accept GDPR/Ads")
                    }
                }).padding()
                
                Button(action: {
                    sdkManager.revokeGDPRAndPersonalizedAdsConsent()
                }, label: {
                    HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                        Text("Revoke/Decline GDPR/Ads")
                    }
                }).padding()
                
                Button(action: sdkManager.requestATT, label: {
                    VStack{
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Request ATT (IDFA tracking)")
                        }
                    }
                }).padding()
            }
        }
        .onAppear {
            print("InquireConsentView.onAppear")
        }
    }
}

struct InquireConsentView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview with a AppsFlyerManager instance
        let sdkManager = SDKManager()
        
        // Wrap the StartView in a NavigationView to match your app's structure
        NavigationView {
            InquireConsentView()
                .environmentObject(sdkManager)
        }
    }
}
