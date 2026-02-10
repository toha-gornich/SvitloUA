//
//  MockYasnoService.swift
//  SvitloUATests
//
//  Created by Горніч Антон on 10.02.2026.
//

import Foundation
@testable import SvitloUA

class MockYasnoService: YasnoServiceProtocol {
    var scheduleToReturn: GroupSchedule?
    var slotsToReturn: [TimeSlot] = []
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "test", code: -1)
    
    // Track calls for verification
    var fetchScheduleCalled = false
    var getScheduleForRegionAndGroupCalled = false
    var lastRegion: String?
    var lastGroup: String?
    
    func fetchSchedule(region: String, group: String) async throws -> GroupSchedule {
        fetchScheduleCalled = true
        lastRegion = region
        lastGroup = group
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        if let schedule = scheduleToReturn {
            return schedule
        }
        
        // Default fallback
        return GroupSchedule(
            today: nil,
            tomorrow: nil,
            updatedOn: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    func getScheduleForRegionAndGroup(region: String, group: String) async throws -> [TimeSlot] {
        getScheduleForRegionAndGroupCalled = true
        lastRegion = region
        lastGroup = group
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return slotsToReturn
    }
    
    // Helper to reset state between tests
    func reset() {
        scheduleToReturn = nil
        slotsToReturn = []
        shouldThrowError = false
        fetchScheduleCalled = false
        getScheduleForRegionAndGroupCalled = false
        lastRegion = nil
        lastGroup = nil
    }
}
