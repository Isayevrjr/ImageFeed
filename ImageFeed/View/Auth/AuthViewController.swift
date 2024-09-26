import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
    func showAlert()
}


final class AuthViewController: UIViewController {
    private let oauth2Service = OAuth2Service.shared
    let showWebViewSegueIdentifier = "ShowWebView"
    var delegate: AuthViewControllerDelegate?
    
    
    @IBOutlet var inButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        inButton.accessibilityIdentifier = "Authenticate"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
           
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.deleagte = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
}

// MARK: - extension web view delegate

extension AuthViewController: WebViewViewControllerDelegate {
   func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true)
        UIBlockingProgressHUD.show()
        oauth2Service.fetchAuthToken(code) { [weak self] result in
           UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let accessToken):
                let tokenStorage = OAuth2TokenStorage()
                tokenStorage.token = accessToken
                delegate?.didAuthenticate(self)
            case .failure(let error):
                print("Failed to fetch OAuthToken: \(error.localizedDescription)")
                delegate?.showAlert()
            }
        }
        
    }
    
    func ViewViewControllerDidCancle(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
}
