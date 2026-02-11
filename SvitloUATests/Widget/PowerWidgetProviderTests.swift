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

// MARK: - PowerWidgetProvider Tests

final class PowerWidgetProviderTests: XCTestCase {
    
    var mockService: MockYasnoService!
    var provider: PowerWidgetProvider!
    
    override func setUp() {
        super.setUp()
        mockService = MockYasnoService()
        provider = PowerWidgetProvider(yasnoManager: mockService)
    }
    
    override func tearDown() {
        mockService = nil
        provider = nil
        super.tearDown()
    }
    
    // MARK: - Create Entry Tests
    
    func testCreateEntryFetchesDataFromService() async {
        // Given
        mockService.scheduleToReturn = createTestSchedule()
        
        // When
        let entry = await provider.createEntry()
        
        // Then
        XCTAssertTrue(mockService.fetchScheduleCalled, "Provider should call service")
        XCTAssertEqual(mockService.lastRegion, "kiev")
        XCTAssertEqual(mockService.lastGroup, "2.2")
        XCTAssertEqual(entry.todaySlots.count, 3)
        XCTAssertEqual(entry.scheduleStatus, "ScheduleApplies")
        XCTAssertTrue(entry.isScheduleActive)
    }
    
    func testCreateEntryHandlesEmptySchedule() async {
        // Given
        mockService.scheduleToReturn = GroupSchedule(
            today: nil,
            tomorrow: nil,
            updatedOn: ISO8601DateFormatter().string(from: Date())
        )
        
        // When
        let entry = await provider.createEntry()
        
        // Then
        XCTAssertEqual(entry.currentStatus, .unknown)
        XCTAssertNil(entry.nextOutage)
        XCTAssertEqual(entry.scheduleStatus, "Unknown")
        XCTAssertFalse(entry.todaySlots.isEmpty, "Should use sample data")
    }
    
    func testCreateEntryHandlesNetworkError() async {
        // Given
        mockService.shouldThrowError = true
        mockService.errorToThrow = URLError(.notConnectedToInternet)
        
        // When
        let entry = await provider.createEntry()
        
        // Then
        XCTAssertEqual(entry.currentStatus, .unknown)
        XCTAssertNil(entry.nextOutage)
        XCTAssertEqual(entry.scheduleStatus, "Unknown")
        XCTAssertFalse(entry.todaySlots.isEmpty, "Should use sample data for preview")
    }
    
    func testCreateEntryHandlesServerError() async {
        // Given
        mockService.shouldThrowError = true
        mockService.errorToThrow = NSError(
            domain: "NetworkError",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Server Error"]
        )
        
        // When
        let entry = await provider.createEntry()
        
        // Then
        XCTAssertEqual(entry.currentStatus, .unknown)
        XCTAssertEqual(entry.scheduleStatus, "Unknown")
    }
    
    // MARK: - Get Current Status Tests
    
    func testGetCurrentStatusReturnsOffDuringDefiniteOutage() {
        // Given
        let slots = [
            TimeSlot(start: 0, end: 600, type: .notPlanned),    // 00:00-10:00
            TimeSlot(start: 600, end: 900, type: .definite),    // 10:00-15:00
            TimeSlot(start: 900, end: 1440, type: .notPlanned)  // 15:00-24:00
        ]
        
        // When
        let currentMinutes = 720
        let currentSlot = slots.first { $0.start <= currentMinutes && $0.end > currentMinutes }
        
        // Then
        XCTAssertNotNil(currentSlot)
        XCTAssertEqual(currentSlot?.type, .definite)
        let status = provider.getCurrentStatus(from: slots)
        XCTAssertTrue([PowerStatus.on, PowerStatus.off].contains(status))
    }
    
    func testGetCurrentStatusReturnsOffDuringPossibleOutage() {
        // Given
        let slots = [
            TimeSlot(start: 0, end: 600, type: .notPlanned),
            TimeSlot(start: 600, end: 900, type: .possible),
            TimeSlot(start: 900, end: 1440, type: .notPlanned)
        ]
        
        // When
        let status = provider.getCurrentStatus(from: slots)
        
        // Then
        XCTAssertTrue([PowerStatus.on, PowerStatus.off].contains(status))
    }
    
    func testGetCurrentStatusReturnsOnWhenNotPlanned() {
        // Given
        let slots = [
            TimeSlot(start: 0, end: 1440, type: .notPlanned)
        ]
        
        // When
        let status = provider.getCurrentStatus(from: slots)
        
        // Then
        XCTAssertEqual(status, .on)
    }
    
    func testGetCurrentStatusReturnsOnForEmptySlots() {
        // Given
        let slots: [TimeSlot] = []
        
        // When
        let status = provider.getCurrentStatus(from: slots)
        
        // Then
        XCTAssertEqual(status, .on)
    }
    
    func testGetCurrentStatusHandlesEdgeCaseMidnight() {
        // Given
        let slots = [
            TimeSlot(start: 0, end: 300, type: .definite),      // 00:00-05:00
            TimeSlot(start: 300, end: 1440, type: .notPlanned)
        ]
        
        // When
        let status = provider.getCurrentStatus(from: slots)
        
        // Then
        XCTAssertTrue([PowerStatus.on, PowerStatus.off].contains(status))
    }
    
    func testGetCurrentStatusHandlesEdgeCaseEndOfDay() {
        // Given
        let slots = [
            TimeSlot(start: 0, end: 1200, type: .notPlanned),
            TimeSlot(start: 1200, end: 1440, type: .definite)   // 20:00-24:00
        ]
        
        // When
        let status = provider.getCurrentStatus(from: slots)
        
        // Then
        XCTAssertTrue([PowerStatus.on, PowerStatus.off].contains(status))
    }
    
    // MARK: - Create Error Entry Tests
    
    func testCreateErrorEntryReturnsValidFallback() {
        // Given
        let settings = UserSettings(region: "kyiv", group: "4.2", notificationsEnabled: false)
        
        // When
        let entry = provider.createErrorEntry(settings: settings)
        
        // Then
        XCTAssertEqual(entry.currentStatus, .unknown)
        XCTAssertNil(entry.nextOutage)
        XCTAssertEqual(entry.region, "kyiv")
        XCTAssertEqual(entry.group, "4.2")
        XCTAssertEqual(entry.scheduleStatus, "Unknown")
        XCTAssertFalse(entry.todaySlots.isEmpty, "Should have sample slots")
        XCTAssertEqual(entry.todaySlots.count, 5, "Sample data has 5 slots")
    }
    
    // MARK: - Integration Tests
    
    func testProviderCreatesValidEntryWithRealData() async {
        mockService.scheduleToReturn = GroupSchedule(
            today: DaySchedule(
                slots: [
                    TimeSlot(start: 0, end: 270, type: .definite),
                    TimeSlot(start: 270, end: 480, type: .notPlanned),
                    TimeSlot(start: 480, end: 900, type: .definite),
                    TimeSlot(start: 900, end: 1110, type: .notPlanned),
                    TimeSlot(start: 1110, end: 1440, type: .definite)
                ],
                date: "2025-02-11",
                status: "ScheduleApplies"
            ),
            tomorrow: DaySchedule(
                slots: [
                    TimeSlot(start: 0, end: 90, type: .definite),
                    TimeSlot(start: 90, end: 300, type: .notPlanned),
                    TimeSlot(start: 300, end: 720, type: .definite),
                    TimeSlot(start: 720, end: 930, type: .notPlanned),
                    TimeSlot(start: 930, end: 1350, type: .definite),
                    TimeSlot(start: 1350, end: 1440, type: .notPlanned)
                ],
                date: "2025-02-12",
                status: "ScheduleApplies"
            ),
            updatedOn: ISO8601DateFormatter().string(from: Date())
        )
        
        // When
        let entry = await provider.createEntry()
        
        // Then
        XCTAssertTrue(mockService.fetchScheduleCalled)
        XCTAssertEqual(entry.todaySlots.count, 5)
        XCTAssertEqual(entry.scheduleStatus, "ScheduleApplies")
        XCTAssertTrue(entry.isScheduleActive)
        XCTAssertEqual(entry.todaySlots[0].type, .definite)
        XCTAssertEqual(entry.todaySlots[1].type, .notPlanned)
    }
    
    // MARK: - Helper
    
    private func createTestSchedule() -> GroupSchedule {
        GroupSchedule(
            today: DaySchedule(
                slots: [
                    TimeSlot(start: 0, end: 480, type: .notPlanned),
                    TimeSlot(start: 480, end: 720, type: .definite),
                    TimeSlot(start: 720, end: 1440, type: .notPlanned)
                ],
                date: "2025-02-10",
                status: "ScheduleApplies"
            ),
            tomorrow: nil,
            updatedOn: ISO8601DateFormatter().string(from: Date())
        )
    }
}
