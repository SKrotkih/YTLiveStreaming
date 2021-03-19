//
//  GoogleSignInInteractor.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih
//

import Foundation
import GoogleSignIn
import YTLiveStreaming
import RxSwift

public class GoogleSignInInteractor: NSObject, SignInObservable {
    let rxSignInResult: PublishSubject<Result<Void, LVError>> = PublishSubject()
    let rxSignOut: PublishSubject<Bool> = PublishSubject()

    private let worker = GoogleClientId()

    fileprivate struct Auth {
        // There are needed sensitive scopes to have ability to work properly
        // Make sure they are presented in your app. Then send request on verification
        static let scope1 = "https://www.googleapis.com/auth/youtube"
        static let scope2 = "https://www.googleapis.com/auth/youtube.readonly"
        static let scope3 = "https://www.googleapis.com/auth/youtube.force-ssl"
        static let scopes = [scope1, scope2, scope3]
    }

    var currentUser: GIDGoogleUser? {
        return GIDSignIn.sharedInstance().currentUser
    }

    var isConnected: Bool {
        return currentUser != nil
    }

    var currentUserInfo: String? {
        if let currentUser = currentUser {
            return currentUser.profile.givenName
        } else {
            return nil
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

    func openURL(_ url: URL) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        GoogleOAuth2.sharedInstance.clearToken()
        GoogleUser.signOut()

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
    public func sign(_ signIn: GIDSignIn, didSignInFor user: GIDGoogleUser?, withError error: Error?) {
        if let error = error {
            errorSigedIn(error: error)
        } else if user == nil {
            errorUserIsUndefined()
        } else if self.accessToken == nil {
            errorAccessToken()
        } else {
            userDidSignIn(user: user!)
        }
    }
    // [END signin_handler]

    // [START disconnect_handler]
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        userDidSignOut()
    }
    // [END disconnect_handler]

    // Handle the user sign in

    private func errorSigedIn(error: Error) {
        if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            let message = "The user has not signed in before or he has since signed out"
            self.rxSignInResult.onNext(.failure(.systemMessage(401, message)))
        } else {
            self.rxSignInResult.onNext(.failure(.message(error.localizedDescription)))
        }
    }

    private func errorUserIsUndefined() {
        let message = "The user has not signed in before or he has since signed out"
        self.rxSignInResult.onNext(.failure(.systemMessage(401, message)))
    }

    private func errorAccessToken() {
        self.rxSignInResult.onNext(.failure(.message("Internal Error. The access token is not presented")))
    }

    private func userDidSignIn(user: GIDGoogleUser) {
        checkYoutubePermissionScopes(for: user)
        if GoogleUser.signIn(as: user) {
            GoogleOAuth2.sharedInstance.accessToken = accessToken
            self.rxSignInResult.onNext(.success(Void()))
        }
    }

    @discardableResult
    private func checkYoutubePermissionScopes(for user: GIDGoogleUser) -> Bool {
        let currentScopes = user.grantedScopes.compactMap { $0 }

        print("SCOPES=\(currentScopes)")

        if currentScopes.contains(where: {
            if let scope = $0 as? String {
                return Auth.scopes.contains(scope)
            } else {
                return false
            }
        }) {
            return true
        } else {
            /**
             I'm not sure do we have to send the request, so I escluded it for now
             self.sendRequestToAddNeededScopes(for: user)
             */
            let message = "Please add scopes to have ability to manage your YouTube videos. The app will not work properly"
            Alert.showOk("Warning", message: message)
            return false
        }
    }

    private func userDidSignOut() {
        rxSignOut.onNext(true)
    }
}

// MARK: - Check/Add the Scopes

extension GoogleSignInInteractor {

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
