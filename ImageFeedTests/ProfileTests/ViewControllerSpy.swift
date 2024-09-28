import UIKit
import ImageFeed

final class ViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var exidButton = true
    
    func updateAvatar() { }
    
    func logout() { }
    
    func showAlert(alert: UIAlertController) { }
    
    func addSubviews() { }
    
    func addConstrains() { }
    
    func configure(_ presenter: any ImageFeed.ProfilePresenterProtocol) { }
    
    
}
