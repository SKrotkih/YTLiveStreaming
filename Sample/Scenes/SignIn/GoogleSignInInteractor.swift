//
//  GoogleSignInInteractor.swift
//  YTLiveStreaming
//

import UIKit
import GoogleSignIn
import YTLiveStreaming
import RxSwift

public class GoogleSignInInteractor: NSObject  {
    
    let rxSignInResult: PublishSubject<Result<Void, LVError>> = PublishSubject()
    let rxSignOut: PublishSubject<Bool> = PublishSubject()
    
    var userStorage = UserStorage()
    private let worker = GoogleSignInWorker()
    
    fileprivate struct Auth {
        static let Scope: NSString = "https://www.googleapis.com/auth/youtube"
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
        if let _ = currentUser {
            return true
        } else {
            return false
        }
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
    
    func openURL(_ url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        GoogleOAuth2.sharedInstance.clearToken()
        UserStorage.user = nil
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
                self.rxSignInResult.onNext(.failure(.systemMessage(401, "The user has not signed in before or they have since signed out.")))
            } else {
                self.rxSignInResult.onNext(.failure(.message(error.localizedDescription)))
            }
        } else {
            GoogleUser.save(user)
            if let accessToken = self.accessToken {
                GoogleOAuth2.sharedInstance.accessToken = accessToken
                self.rxSignInResult.onNext(.success(Void()))
            } else {
                self.rxSignInResult.onNext(.failure(.message("access token is not presented")))
            }
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
