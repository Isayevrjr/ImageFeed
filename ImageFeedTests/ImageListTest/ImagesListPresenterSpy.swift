@testable import ImageFeed
import UIKit

final class ImagesListPresenterSpy: ImageListPresenterProtocol {
    
    
    var imagesListService = ImagesListService.shared
    var view: ImageListViewControllerProtocol?
    var photos: [Photo] = []
    var isViewDidLoadCall: Bool = false
    
    func viewDidLoad() { isViewDidLoadCall = true }
    func getCellHeight(indexPath: IndexPath, tableView: UITableView) -> CGFloat { return 0 }
    func updateTableViewAnimated() { }
}
