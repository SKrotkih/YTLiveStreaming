//
//  GoogleSignInInteractor.swift
//  YTLiveStreaming
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
        static let scope1: NSString = "https://www.googleapis.com/auth/youtube"
        static let scope2: NSString = "https://www.googleapis.com/auth/youtube.readonly"
        static let scope3: NSString = "https://www.googleapis.com/auth/youtube.force-ssl"
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

    func requestAdditionalScopes() -> Bool {
        guard let currentUser = GIDSignIn.sharedInstance()?.currentUser, let email = UserStorage.user?.email else {
            return false
        }
        if currentUser.grantedScopes.contains(where: { (object) -> Bool in
            guard let scope = object as? String else {
                return false
            }
            return scope == String(Auth.scope1) || scope == String(Auth.scope2) || scope == String(Auth.scope3)
        }) {
            return true
        } else {
            GIDSignIn.sharedInstance().scopes.append(contentsOf: [Auth.scope1, Auth.scope2, Auth.scope3])
            GIDSignIn.sharedInstance().loginHint = email
            GIDSignIn.sharedInstance().signIn()
            return false
        }
    }
}

// MARK: - GIDSignInDelegate methods

extension GoogleSignInInteractor: GIDSignInDelegate {

    // [START signin_handler]
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                self.rxSignInResult.onNext(.failure(.systemMessage(401,
                                                                   "The user has not signed in before or they have since signed out."
                    )))
            } else {
                self.rxSignInResult.onNext(.failure(.message(error.localizedDescription)))
            }
        } else {
            GoogleUser.save(user)
            if let accessToken = self.accessToken {

                print("SCOPES=\(GIDSignIn.sharedInstance().scopes ?? [])")

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
