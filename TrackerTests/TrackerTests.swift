//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Дионисий Коневиченко on 07.06.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testTrackersViewController() {
        let vc = TrackersViewController()
        
        
        assertSnapshot(matching: vc, as: .image)
    }
}
