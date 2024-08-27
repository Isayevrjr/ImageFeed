import UIKit
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    let key = "Bearer Token"
    private let keychain = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychain.string(forKey: key)
        }
        set {
            guard let newValue else {
                print("Invalid token", #fileID, #function, #line)
                return
            }
            let isSuccess = keychain.set(newValue, forKey: key)
            
            guard isSuccess else {
                print("Error to save token")
                return
            }
            
        }
    }
    
}
