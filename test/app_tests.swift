import XCTest

class GIPHY_Anywhere_UI_Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        // XCUIApplication().menuBars.children(matching: .statusItem).element.click()
    }

    override func tearDown() {
    }

    func testInitialState() {
        let statusItem = XCUIApplication().menuBars.children(matching: .statusItem).element
        // statusItem.click()
        
        XCTAssert(statusItem.menuItems["Copy GIF URL"].isEnabled == false)
        XCTAssert(statusItem.menuItems["Copy GIF URL (GitHub Markdown)"].isEnabled == false)
        
        let quitItem = statusItem.menuItems["Quit"]
        XCTAssert(quitItem.isEnabled == true)
        quitItem.click()
    }
    
}
