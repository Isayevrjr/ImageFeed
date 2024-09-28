import ImageFeed
import UIKit

final class PresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    var isButtonTapped = false
    var isViewDidLoad = false
    
    func viewDidLoad() { isViewDidLoad = true }
    
    func logout() { isButtonTapped = true }
    
    func getProfile() -> ImageFeed.Profile? { return nil }
    
    func getAvatarUrl() -> URL? { return nil }
    
}

