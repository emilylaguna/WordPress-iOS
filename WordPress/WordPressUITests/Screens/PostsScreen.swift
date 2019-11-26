import Foundation
import XCTest

private struct ElementStringIDs {
    static let draftsButton = "drafts"
}

class PostsScreen: BaseScreen {

    enum PostStatus{
        case drafts
    }

    init() {
        super.init(element: XCUIApplication().tables["PostsTable"])
    }

    @discardableResult
    func showOnly(_ status: PostStatus) -> PostsScreen {

        switch status {
            case .drafts: XCUIApplication().buttons[ElementStringIDs.draftsButton].tap()
        }

        return self
    }

    func selectPost(withSlug slug: String) -> EditorScreen {
        tapStatusBarToScrollToTop()

        let cell = expectedElement.cells[slug]
        waitForElementToExist(element: cell)

        scrollElementIntoView(element: cell, within: expectedElement)
        cell.tap()

        let editorScreen = EditorScreen()
        editorScreen.dismissDialogsIfNeeded()

        return EditorScreen()
    }
}

struct EditorScreen {

    var isGutenbergEditor: Bool {
        let blockEditorElement = "Add block"
        return XCUIApplication().otherElements[blockEditorElement].exists
    }

    var isAztecEditor: Bool {
        let aztecEditorElement = "Azctec Editor Navigation Bar"
        return XCUIApplication().navigationBars[aztecEditorElement].exists
    }

    private var blockEditor: BlockEditorScreen {
        return BlockEditorScreen()
    }

    private var aztecEditor: AztecEditorScreen {
        return AztecEditorScreen(mode: .rich)
    }

    func dismissDialogsIfNeeded() {
        if self.isGutenbergEditor {
            blockEditor.dismissBlockEditorEnabledDialog()
        }
    }

    func close() {
        if isGutenbergEditor {
            self.blockEditor.closeEditor()
        }

        if isAztecEditor {
            self.aztecEditor.closeEditor()
        }
    }
}
