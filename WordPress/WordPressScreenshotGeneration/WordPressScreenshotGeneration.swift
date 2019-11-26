import UIKit
import XCTest
import SimulatorStatusMagic

class WordPressScreenshotGeneration: XCTestCase {
    let imagesWaitTime: UInt32 = 10

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        SDStatusBarManager.sharedInstance()?.enableOverrides()

        // This does the shared setup including injecting mocks and launching the app
        setUpTestSuite()

        // The app is already launched so we can set it up for screenshots here
        let app = XCUIApplication()
        setupSnapshot(app)

        if isIpad {
            XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
        } else {
            XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        }

        LoginFlow.login(siteUrl: "WordPress.com", username: ScreenshotCredentials.username, password: ScreenshotCredentials.password)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        SDStatusBarManager.sharedInstance()?.disableOverrides()

        super.tearDown()
    }

    func testThatScreenshotGenerationCompiles() {
        XCTAssertTrue(true, "Compilation Succeeded")
    }

    func testScrollToTop() {
        let app = XCUIApplication()
        debugPrint(app.tables.count)
    }

    func testGenerateScreenshots() {
        let app = XCUIApplication()

        let mySite = MySiteScreen()
            .switchSite()
            .switchToSite(withTitle: "infocusphotographers.com")

        let postList = mySite
            .gotoPostsScreen()
            .showOnly(.drafts)

        let firstPostEditorScreenshot = postList.selectPost(withSlug: "summer-band-jam")
        snapshot("1-PostEditor")
        firstPostEditorScreenshot.close()

        // Get a screenshot of the drafts feature
        let secondPostEditorScreenshot = postList.selectPost(withSlug: "ideas")
        snapshot("5-DraftEditor")
        secondPostEditorScreenshot.close()

        // Get a screenshot of the full-screen editor
        if isIpad {
            let ipadScreenshot = postList.selectPost(withSlug:  "now-booking-summer-sessions")
            snapshot("6-No-Keyboard-Editor")
            ipadScreenshot.close()
        }

        if !isIpad {
            postList.pop()
        }

        mySite.gotoMediaScreen()
        sleep(imagesWaitTime) // wait for post images to load
        snapshot("4-Media")

        if !isIpad {
            postList.pop()
        }
        // Get Stats screenshot
        let statsScreen = mySite.gotoStatsScreen()
        statsScreen.dismissCustomizeInsightsNotice()
            .switchTo(mode: .years)

        // This line is for stats v2
        // app.buttons["insights"].tap()

        // Wait for stats to be loaded
//        waitForElementToExist(element: app.otherElements["visitorsViewsGraph"])
//        waitForElementToNotExist(element: app.progressIndicators.firstMatch)

        snapshot("2-Stats")

        // Get Notifications screenshot
        app.tabBars["Main Navigation"].buttons["notificationsTabButton"].tap()
        XCTAssert(app.tables["Notifications Table"].exists, "Notifications Table not found")

        //Tap the "Not Now" button to dismiss the notifications prompt
        let notNowButton = app.buttons["no-button"]
        if notNowButton.exists {
            notNowButton.tap()
        }

        snapshot("3-Notifications")
    }
}
