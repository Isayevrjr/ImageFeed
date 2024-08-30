import UIKit

//MARK: - User Result

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

//MARK: - Image

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

//MARK: - ProfileImageService
final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private init() { }
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    
    //MARK: - fetchProfileImageURL
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeImageRequest(for: username) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.profileImage.medium
                
                guard let avatarURL = self.avatarURL else {
                    print("failed to get avatarURL")
                    return
                }
                
                completion(.success(avatarURL))
                self.task = nil
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
            case .failure(let error):
                print("failed to get avatarURL: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
       
        task?.resume()
        
    }
    
    //MARK: - make request
    
    private func makeImageRequest(for username: String) -> URLRequest? {
        let baseURL = URL(string: "users/\(username)", relativeTo: Constants.defaultBaseURL)
        
        guard let url = baseURL else {
            print("Failed to create URL")
            return nil
        }
        
        guard let authToken = OAuth2TokenStorage().token else {
            assertionFailure("failed to get authToken")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
}
