// Copyright © 2021 Roger Oba. All rights reserved.

import XCTest
@testable import SwiftttCamera

final class UIViewControllerSwiftttCameraTests : XCTestCase {
    private var childVC: UIViewController!
    private var parentVC: UIViewController!
    private var siblingView: UIView!

    override func setUp() {
        super.setUp()
        childVC = UIViewController()
        parentVC = UIViewController()
        siblingView = UIView()
        parentVC.loadView()
        parentVC.view.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        parentVC.beginAppearanceTransition(true, animated: false)
        parentVC.endAppearanceTransition()
    }

    override func tearDown() {
        siblingView = nil
        parentVC = nil
        childVC = nil
        super.tearDown()
    }

    func testAddChildViewController_shouldAddChildViewToParentViewController() {
        parentVC.swiftttAddChild(childVC)
        childVC.view.frame = parentVC.view.bounds
        XCTAssert(parentVC.view.subviews.contains(childVC.view))
    }

    func testAddChildViewController_shouldAddChildAsChildOfParentViewController() {
        parentVC.swiftttAddChild(childVC)
        XCTAssert(parentVC.children.contains(childVC))
    }

    func testAddChildViewControllerBelowSubview_shouldAddChildsViewToParentViewController() {
        parentVC.view.addSubview(siblingView)
        parentVC.swiftttAddChild(childVC, belowSubview: siblingView)
        childVC.view.frame = parentVC.view.bounds
        XCTAssert(parentVC.view.subviews.contains(childVC.view))

        siblingView = nil
    }

    func testAddChildViewControllerBelowSubview_shouldAddChildsViewToParentViewControllerBelowSiblingView() {
        parentVC.view.addSubview(siblingView)
        parentVC.swiftttAddChild(childVC, belowSubview: siblingView)
        childVC.view.frame = parentVC.view.bounds
        guard let indexOfSiblingView = parentVC.view.subviews.firstIndex(of: siblingView) else { return XCTFail("Index of sibling view couldn't be found") }
        guard let indexOfChildVCView = parentVC.view.subviews.firstIndex(of: childVC.view) else { return XCTFail("Index of child view controller's view couldn't be found") }
        XCTAssertGreaterThan(indexOfSiblingView, indexOfChildVCView)
    }

    func testAddChildViewControllerBelowSubview_shouldAddChildAsChildOfParentViewController() {
        parentVC.view.addSubview(siblingView)
        parentVC.swiftttAddChild(childVC, belowSubview: siblingView)
        XCTAssert(parentVC.children.contains(childVC))
    }

    func testRemovingChildViewController_shouldRemoveChildsViewFromParentViewController() {
        parentVC.swiftttAddChild(childVC)
        parentVC.swiftttRemoveChild(childVC)
        XCTAssertFalse(parentVC.view.subviews.contains(childVC.view))
    }

    func testRemovingChildViewController_shouldRemoveChildViewControllerFromParentViewControllersChildren() {
        parentVC.swiftttAddChild(childVC)
        parentVC.swiftttRemoveChild(childVC)
        XCTAssertFalse(parentVC.children.contains(childVC))
    }
}
