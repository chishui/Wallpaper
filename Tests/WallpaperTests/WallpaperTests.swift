import XCTest
@testable import Wallpaper

final class WallpaperTests: XCTestCase {
    var wp: Wallpaper!
    
    override func setUp() {
        super.setUp()
        wp = Wallpaper()
    }
    
    func testInvalidFilePath() {
        let expect = expectation(description: "lalala")
        let result = wp.setWallpaper(with: "")
        switch result {
        case .success:
            print("we have an image!")
        case .failure(let error):
            XCTAssertEqual(error, SetWallpaperError.fileNotExist)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 5)
    }
}
