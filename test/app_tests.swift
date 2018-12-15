import XCTest

class GIPHY_Anywhere_UI_Tests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDown() {
    }

    func testInitialState() {
        XCUIApplication().activate()
        let menuBarsQuery = XCUIApplication().menuBars
        XCTAssert(menuBarsQuery.menuItems["Copy GIF URL"].isEnabled == false)
        XCTAssert(menuBarsQuery.menuItems["Copy GIF URL (GitHub Markdown)"].isEnabled == false)
        let quitItem = menuBarsQuery.menuItems["Quit"]
        XCTAssert(quitItem.isEnabled == true)
        quitItem.click()
    }
    
}
