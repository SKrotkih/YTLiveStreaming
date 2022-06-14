//
//  GoogleSignInInteractor.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh
//

import Foundation
import GoogleSignIn
import YTLiveStreaming
import RxSwift

public class GoogleSignInInteractor: NSObject, SignInSupportable {
    let rxSignInResult: PublishSubject<Result<Void, LVError>> = PublishSubject()
    let rxSignOut: PublishSubject<Bool> = PublishSubject()

    @Lateinit var configurator: SignInConfigurator
    @Lateinit var presenter: UIViewController
    @Lateinit var model: SignInStorage

    enum SignInError: Error {
        case signInError(Error)
        case userIsUndefined
        case permissionsError
    }

    // Retrieving user information
    func signIn() {
        // https://developers.google.com/identity/sign-in/ios/people#retrieving_user_information
        GIDSignIn.sharedInstance.signIn(with: configurator.signInConfig,
                                        presenting: presenter) { [weak self] user, error in
            guard let `self` = self else { return }
            do {
                try self.parseSignInResult(user, error)
                self.rxSignInResult.onNext(.success(Void()))
            } catch SignInError.signInError(let error) {
                if (error as NSError).code == GIDSignInError.hasNoAuthInKeychain.rawValue {
                    self.rxSignInResult.onNext(.failure(.systemMessage(401, "The user has not signed in before or he has since signed out")))
                } else {
                    self.rxSignInResult.onNext(.failure(.message(error.localizedDescription)))
                }
            } catch SignInError.userIsUndefined {
                self.rxSignInResult.onNext(.failure(.systemMessage(401, "The user has not signed in before or he has since signed out")))
            } catch SignInError.permissionsError {
                // I'm not sure do we have to send the request, so I escluded it for now
                // self.sendRequestToAddNeededScopes(for: user)
                self.rxSignInResult.onNext(.failure(.message("Please add scopes to have ability to manage your YouTube videos. The app will not work properly")))
            } catch {
                fatalError("Unexpected exception")
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        GoogleOAuth2.sharedInstance.clearToken()
        model.didUserSignOut()
        rxSignOut.onNext(true)
    }

    // It is highly recommended that you provide users that signed in with Google the
    // ability to disconnect their Google account from your app. If the user deletes their account,
    // you must delete the information that your app obtained from the Google APIs.
    func disconnect() {
        GIDSignIn.sharedInstance.disconnect { error in
            guard error == nil else { return }

            // Google Account disconnected from your app.
            // Perform clean-up actions, such as deleting data associated with the
            //   disconnected account.
        }
    }
}

// MARK: - Deprecated

extension GoogleSignInInteractor {
    fileprivate struct Auth {
        // There are needed sensitive scopes to have ability to work properly
        // Make sure they are presented in your app. Then send request on verification
        static let scope1 = "https://www.googleapis.com/auth/youtube"
        static let scope2 = "https://www.googleapis.com/auth/youtube.readonly"
        static let scope3 = "https://www.googleapis.com/auth/youtube.force-ssl"
        static let scopes = [scope1, scope2, scope3]
    }
}

// MARK: - Google Sign In Handler

extension GoogleSignInInteractor {
    // [START signin_handler]
    private func parseSignInResult(_ user: GIDGoogleUser?, _ error: Error?) throws {
        if let error = error {
            throw SignInError.signInError(error)
        } else if user == nil {
            throw SignInError.userIsUndefined
        } else if let user = user, checkYoutubePermissionScopes(for: user) {
            if model.didUserSignIn(as: user) {
                // GoogleOAuth2.sharedInstance.accessToken = model.authAccessToken
            }
        } else {
            throw SignInError.permissionsError
        }
    }
    // [END signin_handler]

    private func checkYoutubePermissionScopes(for user: GIDGoogleUser) -> Bool {
        guard let grantedScopes = user.grantedScopes else { return false }
        let currentScopes = grantedScopes.compactMap { $0 }
        let havePermissions = currentScopes.contains(where: { Auth.scopes.contains($0) })
        return havePermissions
    }
}

// MARK: - Check/Add the Scopes

extension GoogleSignInInteractor {

    private func sendRequestToAddNeededScopes(for user: GIDGoogleUser) {
        // guard let email = user.profile?.email else { return }
        DispatchQueue.global().async {
            GIDSignIn.sharedInstance.addScopes(Auth.scopes, presenting: self.presenter)
            // GIDSignIn.sharedInstance.loginHint = email
            self.signIn()
        }
    }
}
