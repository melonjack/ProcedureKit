//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKit
import TestingProcedureKit
@testable import ProcedureKitMobile

class AlertProcedureTests: ProcedureKitTestCase {

    var title: String!
    var message: String!
    var presenting: TestablePresentingController!
    var alert: AlertProcedure!

    override func setUp() {
        super.setUp()
        title = "This is the alert title"
        message = "This is the alert message"
        presenting = TestablePresentingController()
        alert = AlertProcedure(from: presenting)
    }

    override func tearDown() {
        title = nil
        message = nil
        presenting = nil
        alert = nil
        super.tearDown()
    }

    func test__alert_style_set_default() {
        XCTAssertEqual(alert.preferredStyle, .alert)
    }

    func test__alert_style_actionSheet() {
        let style: UIAlertControllerStyle = .actionSheet
        alert = AlertProcedure(style: style, from: presenting)
        XCTAssertEqual(alert.preferredStyle, style)
    }

    func test__alert_title() {
        alert.title = title
        XCTAssertEqual(alert.title, title)
    }

    func test__alert_message() {
        alert.message = message
        XCTAssertEqual(alert.message, message)
    }

    func test__alert_add_textfield() {
        alert.addTextField(configurationHandler: nil)
        XCTAssertNotNil(alert.textFields)
    }

    func test__alert_actions() {
        alert.add(actionWithTitle: "OK")
        XCTAssertEqual(alert.actions.count, 1)
    }

    func test__alert_preferred_action() {
        let action = alert.add(actionWithTitle: "OK", style: .default, isPreferred: true)
        alert.add(actionWithTitle: "Cancel", style: .cancel)
        XCTAssertEqual(alert.preferredAction?.title ?? "Epic Fail", action.title ?? "Hello")
        XCTAssertNotNil(alert.preferredAction)
    }

    func test__alert_presents_alert_controller() {
        alert = AlertProcedure(title: title, message: message, from: presenting, waitForDismissal: false)
        presenting.check = { [unowned self] received in
            guard let alertController = received as? UIAlertController else {
                XCTFail("Did not receive an alert controller")
                return
            }
            XCTAssertEqual(alertController.title, self.title)
            XCTAssertEqual(alertController.message, self.message)
        }

        wait(for: alert)
        PKAssertProcedureFinished(alert)
    }
}
