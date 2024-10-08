import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var viewImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var gradientView: UIView!
    
    weak var delegate: ImagesListCellDelegate?
  
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewImage.kf.cancelDownloadTask()
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "Like_button_on") : UIImage(named: "Like_button_off")
        likeButton.setImage(likeImage, for: .normal)
        likeButton.accessibilityIdentifier = "likeButton"
    }
    
    @IBAction private func likeButtinClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
}
   

     
    
     

  
