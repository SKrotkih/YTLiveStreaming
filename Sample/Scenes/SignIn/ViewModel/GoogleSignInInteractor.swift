//
//  GoogleSignInInteractor.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih
//

import UIKit
import GoogleSignIn
import YTLiveStreaming
import RxSwift

public class GoogleSignInInteractor: NSObject {
    let rxSignInResult: PublishSubject<Result<Void, LVError>> = PublishSubject()
    let rxSignOut: PublishSubject<Bool> = PublishSubject()

    var userStorage = UserStorage()
    private let worker = GoogleSignInWorker()

    fileprivate struct Auth {
        // There are needed sensitive scopes to have ability to work properly
        // Make sure they are presented in your app. Then send request on verification
        static let scope1 = "https://www.googleapis.com/auth/youtube"
        static let scope2 = "https://www.googleapis.com/auth/youtube.readonly"
        static let scope3 = "https://www.googleapis.com/auth/youtube.force-ssl"
        static let scopes = [scope1, scope2, scope3]
    }

    fileprivate var mViewController: UIViewController?

    var currentUser: GIDGoogleUser? {
        return GIDSignIn.sharedInstance().currentUser
    }

    var currentUserInfo: String? {
        if let user = currentUser {
            return user.profile.givenName
        } else {
            return nil
        }
    }

    var isConnected: Bool {
        return currentUser != nil
    }

    fileprivate var accessToken: String? {
        if let currentUser = currentUser {
            let accessToken = currentUser.authentication.accessToken
            return accessToken
        } else {
            return nil
        }
    }

    func configure() {
        GIDSignIn.sharedInstance().clientID = worker.googleClientId
        GIDSignIn.sharedInstance().delegate = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }

    func openURL(_ url: URL) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        GoogleOAuth2.sharedInstance.clearToken()
        UserStorage.user = nil
        
        // TODO: Find Out Why does not work callback, then remove it:
        rxSignOut.onNext(true)
    }

    func disconnect() {
        GIDSignIn.sharedInstance().disconnect()
    }
}

// MARK: - GIDSignInDelegate methods

extension GoogleSignInInteractor: GIDSignInDelegate {

    // [START signin_handler]
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                let message = "The user has not signed in before or he has since signed out"
                self.rxSignInResult.onNext(.failure(.systemMessage(401, message)))
            } else {
                self.rxSignInResult.onNext(.failure(.message(error.localizedDescription)))
            }
        } else if !areNeededScopesPresented(for: user) {
            /**
             I'm not sure do we have to send the request, so I escluded it for now
             self.sendRequestToAddNeededScopes(for: user)
             */
            let message = "Please add scopes to have ability to manage your YouTube videos. The app will not work properly"
            Alert.sharedInstance.showOk("Warning", message: message)
        }
        GoogleUser.save(user)
        if let accessToken = self.accessToken {
            GoogleOAuth2.sharedInstance.accessToken = accessToken
            self.rxSignInResult.onNext(.success(Void()))
        } else {
            self.rxSignInResult.onNext(.failure(.message("Internal Error. The access token is not presented")))
        }
    }
    // [END signin_handler]

    // [START disconnect_handler]
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        rxSignOut.onNext(true)
    }
    // [END disconnect_handler]
}

// MARK: - Check/Add the Scopes

extension GoogleSignInInteractor {

    private func areNeededScopesPresented(for user: GIDGoogleUser) -> Bool {
        let currentScopes = user.grantedScopes.compactMap { $0 }
        
        print("SCOPES=\(currentScopes)")
        
        return currentScopes.contains(where: { (scope) -> Bool in
            return Auth.scopes.contains(scope as! String)
        })
    }
    
    private func sendRequestToAddNeededScopes(for user: GIDGoogleUser) {
        guard let email = user.profile.email else {
            return
        }
        DispatchQueue.global().async {
            GIDSignIn.sharedInstance().scopes.append(contentsOf: Auth.scopes)
            GIDSignIn.sharedInstance().loginHint = email
            GIDSignIn.sharedInstance().signIn()
        }
    }
}
