//
//  GoogleConnect.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 2/11/18.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import GoogleSignIn
import YTLiveStreaming

public class GoogleConnect: NSObject  {

   var presenter: Presenter?
   var userStorage = UserStorage()

   fileprivate var mClientID: String?
   fileprivate let PlistKeyClientID = "CLIENT_ID"

   fileprivate struct Auth {
      static let Scope: NSString = "https://www.googleapis.com/auth/youtube"
   }
   
   fileprivate var mViewController: UIViewController?
   
   func configure() {
      GIDSignIn.sharedInstance().clientID = getGoogleClientId()
      GIDSignIn.sharedInstance().delegate = self
      GIDSignIn.sharedInstance().uiDelegate = self
   }
   
   func openURL(_ url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication,  annotation: annotation)
   }
   
   var currentUserInfo: String? {
      if let user: GIDGoogleUser = GIDSignIn.sharedInstance().currentUser {
         return user.profile.givenName
      } else {
         return nil
      }
   }

   var isConnected: Bool {
      if let _ = GIDSignIn.sharedInstance().currentUser {
         return true
      } else {
         return false
      }
   }
   
   fileprivate var accessToken: String? {
      if let currentUser = GIDSignIn.sharedInstance().currentUser {
         let accessToken = currentUser.authentication.accessToken
         return accessToken
      } else {
         return nil
      }
   }
}

// MARK: - Public methods

extension GoogleConnect {

   func signIn(with viewController: UIViewController) {
      if isConnected {
         presenter?.presentUserInfo()
         return
      }
      if GIDSignIn.sharedInstance().hasAuthInKeychain(){
         GIDSignIn.sharedInstance().signInSilently()
      } else {
         mViewController = viewController
         presenter?.startActivity()
         let currentScopes: NSArray = GIDSignIn.sharedInstance().scopes as NSArray
         GIDSignIn.sharedInstance().scopes = currentScopes.adding(Auth.Scope)
         GIDSignIn.sharedInstance().signIn()
      }
   }
   
   func signOut() {
      GIDSignIn.sharedInstance().signOut()
      GoogleOAuth2.sharedInstance.clearToken()
      userStorage.user = nil
   }
}

// MARK: - GIDSignInDelegate

extension GoogleConnect: GIDSignInDelegate {

   public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
      if let error = error {
         print("\(error.localizedDescription)")
      } else {
         if let userId = user.userID,
            let idToken = user.authentication.idToken,
            let fullName = user.profile.name,
            let givenName = user.profile.givenName,
            let familyName = user.profile.familyName,
            let email = user.profile.email {
            let user = User(userId: userId, idToken: idToken, fullName: fullName, givenName: givenName, familyName: familyName, email: email)
            userStorage.user = user
            if let accessToken = self.accessToken {
               GoogleOAuth2.sharedInstance.accessToken = accessToken
               presenter?.presentUserInfo()
            } else {
               print("error")
            }
         } else {
            print("error")
         }
      }
   }
   
   public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,  withError error: Error!) {
      print("The User left the app")
   }

}

// MARK: - GIDSignInUIDelegate

extension GoogleConnect: GIDSignInUIDelegate {
   
   // The sign-in flow has finished selecting how to proceed, and the UI should no longer display
   // a spinner or other "please wait" element.
   
   public func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {

      // Stop the UIActivityIndicatorView animation that was started when the user
      // pressed the Sign In button
      
      presenter?.stopActivity()
   }
   
   // If implemented, this method will be invoked when sign in needs to display a view controller.
   // The view controller should be displayed modally (via UIViewController's |presentViewController|
   // method, and not pushed unto a navigation controller's stack.

   public func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
      // Present a view that prompts the user to sign in with Google
      mViewController?.present(viewController, animated: true, completion: nil)

   }
   
   // If implemented, this method will be invoked when sign in needs to dismiss a view controller.
   // Typically, this should be implemented by calling |dismissViewController| on the passed
   // view controller.
   
   public func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
      // Dismiss the "Sign in with Google" view
      mViewController?.dismiss(animated: true, completion: nil)
   }
}

// MARK: - Utility

extension GoogleConnect {
   
   fileprivate func getGoogleClientId() -> String {
      if let clientID = self.mClientID {
         return clientID
      }
      if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
         if let plist = NSDictionary(contentsOfFile: path) as NSDictionary? {
            if let clientID = plist[PlistKeyClientID] as? String, !clientID.isEmpty {
               mClientID = clientID
            }
         }
      }
      assert(mClientID != nil, "Please put your Client ID in info.plist as GoogleAPIClientID value")
      return mClientID!
   }
}


