import UIKit

// MARK: - Photo Models

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlResult
    let isLiked: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case urls
        case isLiked = "liked_by_user"
    }
}

struct LikePhoto: Decodable {
    let photo: PhotoResult
}

struct UrlResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String

}

// MARK: - Service

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var taskLike: URLSessionTask?
    
    private init() {}
    
    // MARK: - fetch photos next page
    
    func fetchPhotosNextPage() {
        guard task == nil else { return }
        
        assert(Thread.isMainThread)
        task?.cancel()
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(page: nextPage) else {
            print("Failed to create request", #file, #function, #line)
            return
        }
        
        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photos):
                convertPhotos(photos: photos)
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                                object: self)
            case .failure(_):
                print("[ImagesListService: fetchPhotosNextPage]: Failed to fetch photos")
            }
            self.task = nil
            self.lastLoadedPage = nextPage
        }
        self.task = task
        task.resume()
    }
        
    // MARK: - Request to get photos
    
    func makePhotosRequest(page: Int) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            assertionFailure("Error URL")
            return nil
        }
        
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil }
        components.path = "/photos"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components.url else {
            assertionFailure("Error URL")
            return nil }
        
        guard let authToken = OAuth2TokenStorage().token else {
            assertionFailure("failed to get authToken")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
        
    }
    
    // MARK: - Convert
    
    func convertPhotos(photos: [PhotoResult]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        for photo in photos {
            let newPhoto = Photo(id: photo.id,
                                 size: CGSize(width: photo.width, height: photo.height),
                                 createdAt: dateFormatter.date(from: photo.createdAt ?? ""),
                                 welcomeDescription: photo.description,
                                 thumbImageURL: photo.urls.thumb,
                                 largeImageURL: photo.urls.full,
                                 isLiked: photo.isLiked)
            self.photos.append(newPhoto)
        }
    }
    
    // MARK: - Change Like
    
    func changeLike(photoId: String,
                    isLike: Bool, _
                    completion: @escaping (Result<Void, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        taskLike?.cancel()
        
        guard let request = makeLikeRequest(id: photoId, isLike: isLike) else {
            assertionFailure("Error to make like request")
            return
        }
        
        taskLike = urlSession.objectTask(for: request) { [weak self] (result: Result<LikePhoto, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photoResult):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                   let photo = self.photos[index]
                   let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked)
                    DispatchQueue.main.async {
                        self.photos[index] = newPhoto
                        self.taskLike = nil
                        
                        NotificationCenter.default
                            .post(
                                name: ImagesListService.didChangeNotification,
                                object: self,
                                userInfo: ["photos": self.photos]
                            )
                        
                        completion(.success(()))
                    }
                } else {
                    print("Error to find photoID", #file, #function, #line)
                }
            case .failure(let error):
                print("failed to like/dislike photo: \(error.localizedDescription)")
            }
            self.taskLike = nil
        }
        taskLike?.resume()
    }
    
    // MARK: - Like Request
    
    func makeLikeRequest(id: String, isLike: Bool) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            assertionFailure("Error URL")
            return nil
        }
        
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        components.path = "/photos/\(id)/like"
        
        guard let url = components.url else {
            assertionFailure("Error to create URL")
            return nil
        }
        
        guard let authToken = OAuth2TokenStorage().token else {
            assertionFailure("Error authToken")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
}
