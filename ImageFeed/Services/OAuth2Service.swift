import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private init() {}
    private (set) var authToken: String {
        get {
            return OAuth2TokenStorage().token ?? ""
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }

    
    // MARK: - fetchOAuthToken
    
    func fetchAuthToken(_ code: String,
                        complition: @escaping (Result<String,Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            complition(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            complition(.failure(AuthServiceError.invalidRequest))
            return
        }
     
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    complition(.success(authToken))
                    self.task = nil
                    self.lastCode = nil
                case .failure(let error):
                    print("Failed to get accessToken")
                    complition(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    
    // MARK: - makeOAuthTokenRequest
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let baseURL = URL(string: "https://unsplash.com")
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL)
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

}

