//
//  PowerWidgetProviderTests.swift
//  SvitloUATests
//
//  Created by Горніч Антон on 10.02.2026.
//

import XCTest
import WidgetKit
@testable import SvitloWidgetExtension
@testable import SvitloUA

final class PowerWidgetProviderTests: XCTestCase {
    
    var mockService: MockYasnoService!
    
    override func setUp() {
        super.setUp()
        mockService = MockYasnoService()
    }
    
    // MockYasnoService
    func testMockServiceReturnsSchedule() async throws {
        // Given
        mockService.scheduleToReturn = GroupSchedule(
            today: DaySchedule(
                slots: [TimeSlot(start: 0, end: 480, type: .notPlanned)],
                date: "2025-02-10",
                status: "ScheduleApplies"
            ),
            tomorrow: nil,
            updatedOn: ISO8601DateFormatter().string(from: Date())
        )
        
        // When
        let schedule = try await mockService.fetchSchedule(region: "kyiv", group: "4.2")
        
        // Then
        XCTAssertTrue(mockService.fetchScheduleCalled)
        XCTAssertEqual(mockService.lastRegion, "kyiv")
        XCTAssertEqual(mockService.lastGroup, "4.2")
        XCTAssertNotNil(schedule.today)
        XCTAssertEqual(schedule.today?.slots.count, 1)
    }
    
    
    func testMockServiceThrowsError() async {
        // Given
        mockService.shouldThrowError = true
        
        // When/Then
        do {
            _ = try await mockService.fetchSchedule(region: "kyiv", group: "4.2")
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(mockService.fetchScheduleCalled)
        }
    }
}

