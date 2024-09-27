//
//  AppsFlyer_iOSApp.swift
//  AppsFlyer_iOS
//
//  Created by Robin Kirchner on 05.09.23.
//

import SwiftUI
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport

class SDKManager: ObservableObject {
    @Published var isStarted = false
    @Published var isCreated = false
    @Published var hasGDPRConsent = false
    @Published var hasPersonalizedAdsConsent = false
    @Published var canShowBanner = false
    @Published var attStatus = ATTrackingManager.trackingAuthorizationStatus
    @Published var idfa = "nil" // not best practice to store the IDFA

    func retrieveIDFA() -> String {
        // Check whether advertising tracking is enabled
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus != ATTrackingManager.AuthorizationStatus.authorized  {
                idfa = "nil"
                return "nil"
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled == false {
                idfa = "nil"
                return "nil"
            }
        }
        idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    func requestATT() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                self.attStatus = status
                switch status {
                case .denied:
                    print("ATT status is denied")
                case .notDetermined:
                    print("ATT status is notDetermined")
                case .restricted:
                    print("ATT status is restricted")
                case .authorized:
                    print("ATT status is authorized")
                @unknown default:
                    fatalError("Invalid authorization status")
                }
                print("To show this again, the app needs to be uninstalled!")
            }
        }
        print("IDFA:", retrieveIDFA())
    }
    
    func updateAttStatus() {
        attStatus = ATTrackingManager.trackingAuthorizationStatus
        idfa = retrieveIDFA()
    }
    
    func gdprConsentStatusView() -> AnyView? {
        if hasGDPRConsent {
            return AnyView(
                HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                Text("GDPR Consent")
                }
            )
            
        }
        return AnyView(
            HStack {
            Image(systemName: "xmark.circle")
                .foregroundColor(.red)
            Text("No GDPR Consent")
            }
        )
    }
    
    func personalizedAdsStatusView() -> AnyView? {
        if hasPersonalizedAdsConsent {
            return AnyView(
                HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                Text("GDPR Consent")
                }
            )
            
        }
        return AnyView(
            HStack {
            Image(systemName: "xmark.circle")
                .foregroundColor(.red)
            Text("No GDPR Consent")
            }
        )
    }
    
    func idfaMessage() -> AnyView? {
        return AnyView(Text(idfa))
    }
    
    func attStatusMessage() -> AnyView? {
        if #available(iOS 14, *) {
            switch attStatus {
            case .denied:
                return AnyView(
                        HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                        Text("ATT is denied")
                        }
                    )
            case .notDetermined:
                return AnyView(
                    HStack {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.purple)
                    Text("ATT is not determined")
                    }
                )
            case .restricted:
                return AnyView(
                    HStack {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.yellow)
                    Text("ATT is restricted")
                    }
                )
            case .authorized:
                return AnyView(
                    HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("ATT is authorized")
                    }
                )
            @unknown default:
                return AnyView(
                    HStack {
                    Image(systemName: "checkmark.xmark.circle")
                        .foregroundColor(.red)
                    Text("invalid ATT authorization status")
                    }
                )
            }
        }
    }
    
    func createSdkObject() {
        guard !isCreated else {
            print("AppsFlyer object is already created. Skipping.")
            return
        }
        
        AppsFlyerLib.shared()
    }
    
    func configureSdk() {
        //AppsFlyerLib.shared().disableAdvertisingIdentifier(true);
        //AppsFlyerLib.shared().disableCollectASA(true); // Opt-out of Apple Search Ads attributions.
        
        // https://support.appsflyer.com/hc/en-us/articles/4411620895505-Opting-out-users-for-developers
        // https://support.appsflyer.com/hc/en-us/articles/360001422989-User-opt-in-opt-out-in-the-AppsFlyer-SDK
        // AppsFlyerTracker.shared().isStopTracking = true
        // AppsFlyerLib.shared().isStopped = true
        
        // more disable options:
        // https://dev.appsflyer.com/hc/docs/ios-sdk-reference-appsflyerlib#disablecollectasa
        // https://support.appsflyer.com/hc/en-us/articles/4408735106193#user-privacy
        
        AppsFlyerLib.shared().appsFlyerDevKey = "<confidential>"
        AppsFlyerLib.shared().appleAppID = "<confidential>"
        AppsFlyerLib.shared().isDebug = false // optionally set debug mode
        
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 240)
        
        // set custom user ID
        // AppsFlyerLib.shared().customerUserID = "customUserId"
        
        // for iOS 15 we can also "Configure your app to send postback copies to AppsFlyer"
        // https://dev.appsflyer.com/hc/docs/integrate-ios-sdk#sending-skan-postback-copies-to-appsflyer
        print("AppsFlyer.configure()")
    }
    
    func giveGDPRAndPersonalizedAdsConsent() {
        hasGDPRConsent = true
        hasPersonalizedAdsConsent = true
        let gdprConsent = AppsFlyerConsent(forGDPRUserWithHasConsentForDataUsage: hasGDPRConsent, hasConsentForAdsPersonalization: hasPersonalizedAdsConsent)
        AppsFlyerLib.shared().setConsentData(gdprConsent)
        
        startSdk()
    }
    
    func revokeGDPRAndPersonalizedAdsConsent() {
        hasGDPRConsent = false
        hasPersonalizedAdsConsent = false
        let gdprConsent = AppsFlyerConsent(forGDPRUserWithHasConsentForDataUsage: hasGDPRConsent, hasConsentForAdsPersonalization: hasPersonalizedAdsConsent)
        AppsFlyerLib.shared().setConsentData(gdprConsent)
        
        startSdk()
    }
    
    func startSdk() {
        guard !isStarted else {
            print("AppsFlyer is already started. Skipping.")
            return
        }

        AppsFlyerLib.shared().start()
        isStarted = true
        
    }

    func extendedFunctionality() {
        print("logExtended()")
        AppsFlyerLib.shared().logEvent(name: AFEventAddToWishlist,
          values: [
             AFEventParamPrice: 20,
             AFEventParamContentId: "1234567"
          ],
          completionHandler: { (response: [String : Any]?, error: Error?) in
            if let response = response {
              print("In app event callback Success: ", response)
            }
            if let error = error {
              print("In app event callback ERROR:", error)
            }
          });
    }
    
    func statusMessage() -> some View {
        if isStarted {
            return AnyView(
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("AppsFlyer (SDK) is started")
                }
            )
        } else {
            return AnyView(
                HStack {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                    Text("AppsFlyer (SDK) is not started")
                }
            )
        }
    }
}

struct NamedView {
    let name: String
    let view: AnyView
}

// AppsFlyer: Create, Init, Consent, Util
let views: [NamedView] = [
    NamedView(name: "Start", view: AnyView(ContentView())),
    NamedView(name: "Create SDK Object", view: AnyView(CreateSdkObjectView())),
    NamedView(name: "Initialize SDK", view: AnyView(InitializeSDKView())),
    NamedView(name: "Inquire Consent", view: AnyView(InquireConsentView())),
    NamedView(name: "Basic Functionality", view: AnyView(BasicFunctionalityView())),
]

@main
struct AppsFlyer_iOSApp: App {
    @StateObject var sdkManager = SDKManager()
    @State private var currentViewIndex = 0
        
    @ViewBuilder
    func debugStatusMessage() -> some View {
        #if DEBUG
            AnyView(
                HStack {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.orange)
                    Text("running in DEBUG mode.")
                }
            )
        #else
            AnyView(
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("running in release mode.")
                }
            )
        #endif
    }
    
    func advanceViewIndex() -> AnyView {
        if currentViewIndex < views.count - 1 {
            return AnyView(
                Button(action: {
                    currentViewIndex += 1
                }, label: {
                    HStack {
                        Text("Go to \(views[currentViewIndex + 1].name)")
                        Image(systemName: "chevron.right")
                    }
                })
                .padding()
            )
        }
        return AnyView(
            Text("Final View reached.")
                .padding()
        )
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    VStack {
                        Text("AppsFlyer iOS")
                            .font(.system(size: 40))
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.center)
                            .padding()
                        Text("\(views[currentViewIndex].name)")
                            .font(.system(size: 36))
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
      
                        VStack {
                            debugStatusMessage()
                            sdkManager.statusMessage()
                            sdkManager.attStatusMessage()
                            sdkManager.personalizedAdsStatusView()
                        }.padding()
                        
                        // Display the current view
                        views[currentViewIndex].view
                            .environmentObject(sdkManager)
                        Spacer()
                        // Display "Next View" button
                        advanceViewIndex()
                    }
                    Spacer()
                    VStack {
                        HStack {
                            Image(systemName: "number")
                            sdkManager.idfaMessage()
                        }.font(.system(size: 12))
                    }
                    .frame(height: 75)
                }
                .environmentObject(sdkManager)
            }.onAppear{
                print("sdkManager.updateAttStatus")
                sdkManager.updateAttStatus()
            }
        }
    }
}
