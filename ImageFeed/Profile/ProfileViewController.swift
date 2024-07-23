import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    @IBAction private func didTapLogoutButton(_ sender: Any) {
    }
    
  
}
