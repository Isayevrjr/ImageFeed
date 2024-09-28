import UIKit

// MARK: - ProfileResult

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

// MARK: - Profile

public struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(result: ProfileResult) {
        self.username = result.username
        self.name = ("\(result.firstName) \(result.lastName ?? "")")
        self.loginName = ("@\(result.username)")
        self.bio = result.bio ?? ""
    }
}

// MARK: - ProfileServiceError

enum ProfileServiceError: Error {
    case invalidRequest
}



// MARK: - ProfileService

final class ProfileService {
    
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    private init() { }
    
    // MARK: - Fetch Profile
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeBaseRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let result):
                self.profile = Profile(result: result)
                guard let profileData = self.profile else {
                    print("Error: profileData")
                    return
                }
                completion(.success(profileData))
                self.task = nil
                
            case .failure(let error):
                print("failed to get profileData: \(error.localizedDescription)")
                completion(.failure(error))
                
            }
            
        }
        task?.resume()
    }
    
    //MARK: - Make URLRequest
    
    private func makeBaseRequest(token: String) -> URLRequest? {
        let baseURL = URL(string: "/me", relativeTo: Constants.defaultBaseURL)
        
        guard let url = baseURL else {
            print("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
}
