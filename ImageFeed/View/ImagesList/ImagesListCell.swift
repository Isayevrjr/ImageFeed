import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var viewImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var gradientView: UIView!
    
    override func awakeFromNib() {
     super.awakeFromNib()
     setUpGradientBackground()
    }
    
    private func setUpGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientView.layer.insertSublayer(gradient, at: 0)
        gradient.locations = [0.03, 2.8, 1]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewImage.kf.cancelDownloadTask()
    }
}
   
     
    
     

  
