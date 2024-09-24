import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    
    func testViewControllerDidTapLogOut() {
        //Given
        let viewController = ViewControllerSpy()
        let presenter = PresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        presenter.logout()
        
        //Then
        XCTAssertTrue(presenter.isButtonTapped)
    }
    
    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ProfileViewController()
        let presenter = PresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        _ = viewController.view
        
        //Then
        XCTAssertTrue(presenter.isViewDidLoad)
    }
}
