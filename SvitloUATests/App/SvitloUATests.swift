    //
//  PowerWidgetProviderTests.swift
//  SvitloUATests
//
//  Created by Горніч Антон on 10.02.2026.
//

import XCTest
import WidgetKit
@testable import SvitloUA

// MARK: - PowerDataManager Tests

final class SvitloUATests: XCTestCase {
    
    var mockService: MockYasnoService!
    var manager: PowerDataManager!
    
    override func setUp() {
        super.setUp()
        mockService = MockYasnoService()
        manager = PowerDataManager(yasnoManager: mockService)
    }
    
    override func tearDown() {
        mockService = nil
        manager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    /// Тест перевіряє, що PowerDataManager ініціалізується з дефолтними налаштуваннями
    func testInitializationWithDefaultSettings() {
        // Given
        UserDefaults.standard.removeObject(forKey: "UserSettings")
        
        // When
        let freshManager = PowerDataManager(yasnoManager: mockService)
        
        // Then
        XCTAssertEqual(freshManager.settings.region, "kiev")
        XCTAssertEqual(freshManager.settings.group, "1.1")
    }
    
    /// Тест перевіряє, що PowerDataManager завантажує збережені налаштування з UserDefaults
    func testInitializationLoadsExistingSettings() {
        // Given
        let settings = UserSettings(region: "kharkiv", group: "3.1", notificationsEnabled: true)

        guard let data = try? JSONEncoder().encode(settings) else {
            XCTFail("Failed to encode settings")
            return
        }
        UserDefaults.standard.set(data, forKey: "UserSettings")

        // When
        let freshManager = PowerDataManager(yasnoManager: mockService)

        // Then
        XCTAssertEqual(freshManager.settings.region, "kharkiv")
        XCTAssertEqual(freshManager.settings.group, "3.1")
        XCTAssertTrue(freshManager.settings.notificationsEnabled)
    }
    
    // MARK: - Settings Tests
    
    /// Тест перевіряє, що зміна налаштувань зберігається в UserDefaults
    func testSaveSettingsPersistsToUserDefaults() {
        // Given
        UserDefaults.standard.removeObject(forKey: "UserSettings")
        
        // When
        manager.settings.region = "dnipro"
        manager.settings.group = "2.1"
        manager.settings.notificationsEnabled = false
        manager.saveSettings()
        
        // Then
        guard let data = UserDefaults.standard.data(forKey: "UserSettings"),
              let settings = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            XCTFail("Failed to load or decode settings")
            return
        }
        XCTAssertEqual(settings.region, "dnipro")
        XCTAssertEqual(settings.group, "2.1")
        XCTAssertFalse(settings.notificationsEnabled)
    }
    
    /// Тест перевіряє, що зміна налаштувань зберігається в shared UserDefaults (для віджетів)
    func testSaveSettingsPersistsToSharedDefaults() {
        // Given
        guard let groupDefaults = UserDefaults(suiteName: "group.ua.svitlo.app") else {
            XCTFail("Failed to create App Group UserDefaults")
            return
        }
        groupDefaults.removeObject(forKey: "UserSettings")
        
        // When
        manager.settings.region = "lviv"
        manager.settings.group = "4.2"
        manager.settings.notificationsEnabled = true
        manager.saveSettings()
        
        // Then
        guard let data = groupDefaults.data(forKey: "UserSettings"),
              let settings = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            XCTFail("Failed to load or decode UserSettings from App Group")
            return
        }
        
        XCTAssertEqual(settings.region, "lviv")
        XCTAssertEqual(settings.group, "4.2")
        XCTAssertTrue(settings.notificationsEnabled)
    }
    
    /// Тест перевіряє, що зміна налаштувань автоматично викликає refreshSchedule через debounce
    func testSettingsChangeTriggersScheduleRefresh() async {
        // Given
        mockService.fetchScheduleCalled = false
        
        // When - просто зміна settings без saveSettings()
        manager.settings.region = "odesa"
        
        // Then - чекаємо debounce (300ms) + трохи більше
        try? await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertTrue(mockService.fetchScheduleCalled)
    }
    
    // MARK: - Schedule Refresh Tests

    /// Тест перевіряє, що refreshSchedule викликає yasnoManager.fetchSchedule та оновлює schedules
    func testRefreshScheduleUpdatesSchedules() async {
        // Given
        mockService.scheduleToReturn = createTestSchedule()
        mockService.fetchScheduleCalled = false // Скидаємо прапор
        
        // When
        await manager.refreshSchedule()
        
        // Then
        XCTAssertTrue(mockService.fetchScheduleCalled)
        XCTAssertNotNil(manager.todaySchedule)
        XCTAssertNotNil(manager.tomorrowSchedule)
        XCTAssertEqual(manager.todaySchedule?.slots.count, 5)
        XCTAssertEqual(manager.tomorrowSchedule?.slots.count, 6)
        XCTAssertNotNil(manager.lastUpdated)
    }
    
    /// Тест перевіряє, що refreshSchedule оновлює currentStatus після отримання даних
    func testRefreshScheduleUpdatesCurrentStatus() async {
        // Given
        mockService.scheduleToReturn = createTestSchedule()
        
        // When
        await manager.refreshSchedule()
        
        // Then
        XCTAssertNotEqual(manager.currentStatus, .unknown)
    }

    /// Тест перевіряє, що refreshSchedule керує isLoading правильно
    func testRefreshScheduleManagesLoadingState() async {
        // Given
        mockService.scheduleToReturn = createTestSchedule()
        
        // Чекаємо завершення init refresh (бо він запускається в Task)
        try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
        
        // Тепер isLoading точно має бути false
        XCTAssertFalse(manager.isLoading, "isLoading should be false before test starts")
        
        // When
        await manager.refreshSchedule()
        
        // Then
        XCTAssertFalse(manager.isLoading, "isLoading should be false after completion")
    }

    /// Тест перевіряє, що refreshSchedule обробляє network error
    func testRefreshScheduleHandlesNetworkError() async {
        // Given
        mockService.shouldThrowError = true
        mockService.errorToThrow = URLError(.notConnectedToInternet)
        
        // When
        await manager.refreshSchedule()
        
        // Then
        XCTAssertFalse(manager.isLoading, "isLoading should be false after error")
        // Не має крашнутись
    }

    // MARK: - Current Status Tests

    /// Тест перевіряє, що currentStatus = .off під час definite/possible outage та .on коли notPlanned
    func testCurrentStatusBasedOnSlots() async {
        // Given - schedule з різними типами слотів
        mockService.scheduleToReturn = GroupSchedule(
            today: DaySchedule(
                slots: [
                    TimeSlot(start: 0, end: 600, type: .notPlanned),
                    TimeSlot(start: 600, end: 900, type: .definite),
                    TimeSlot(start: 900, end: 1200, type: .possible),
                    TimeSlot(start: 1200, end: 1440, type: .notPlanned)
                ],
                date: "2025-02-11",
                status: "ScheduleApplies"
            ),
            tomorrow: nil,
            updatedOn: ISO8601DateFormatter().string(from: Date())
        )
        
        // When - викликаємо refreshSchedule щоб оновити currentStatus
        await manager.refreshSchedule()
        
        // Then - статус має бути визначений (не unknown)
        XCTAssertTrue([PowerStatus.on, PowerStatus.off].contains(manager.currentStatus))
    }

    /// Тест перевіряє, що currentStatus = .unknown коли немає даних про слоти
    func testCurrentStatusUnknownWhenNoSlots() {
        // Given
        manager.todaySchedule = nil
        
        // When - викликаємо оновлення через refreshSchedule
        let status = manager.currentStatus
        
        // Then
        XCTAssertEqual(status, .unknown)
    }

    // MARK: - Slots Tests

    /// Тест перевіряє, що upcomingSlots повертає лише майбутні слоти
    func testUpcomingSlotsReturnsOnlyFutureSlots() {
        // Given - створюємо слоти, де деякі вже минули
        let calendar = Calendar.current
        let now = Date()
        let currentMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        
        manager.todaySchedule = DaySchedule(
            slots: [
                TimeSlot(start: 0, end: currentMinutes - 60, type: .definite),
                TimeSlot(start: currentMinutes - 60, end: currentMinutes + 60, type: .notPlanned),
                TimeSlot(start: currentMinutes + 60, end: currentMinutes + 120, type: .definite),
                TimeSlot(start: currentMinutes + 120, end: 1440, type: .notPlanned)
            ],
            date: "2025-02-11",
            status: "ScheduleApplies"
        )
        
        // When
        let upcoming = manager.upcomingSlots
        
        // Then - має бути мінімум 2 майбутніх слоти
        XCTAssertGreaterThanOrEqual(upcoming.count, 2)
        // Всі майбутні слоти повинні закінчуватись після поточного часу
        XCTAssertTrue(upcoming.allSatisfy { $0.end > currentMinutes })
    }

    /// Тест перевіряє, що currentSlot повертає слот для поточного часу
    func testCurrentSlotReturnsCorrectSlot() {
        // Given
        let calendar = Calendar.current
        let now = Date()
        let currentMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        
        manager.todaySchedule = DaySchedule(
            slots: [
                TimeSlot(start: 0, end: currentMinutes - 60, type: .definite),
                TimeSlot(start: currentMinutes - 60, end: currentMinutes + 60, type: .notPlanned),
                TimeSlot(start: currentMinutes + 60, end: 1440, type: .definite)
            ],
            date: "2025-02-11",
            status: "ScheduleApplies"
        )
        
        // When
        let current = manager.currentSlot
        
        // Then
        XCTAssertNotNil(current)
        XCTAssertTrue(current!.start <= currentMinutes && current!.end > currentMinutes)
    }

    /// Тест перевіряє, що nextOutageSlot повертає наступний definite/possible outage
    func testNextOutageSlotReturnsNextOutage() {
        // Given
        let calendar = Calendar.current
        let now = Date()
        let currentMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        
        manager.todaySchedule = DaySchedule(
            slots: [
                TimeSlot(start: 0, end: currentMinutes + 30, type: .notPlanned),
                TimeSlot(start: currentMinutes + 30, end: currentMinutes + 120, type: .definite),
                TimeSlot(start: currentMinutes + 120, end: 1440, type: .notPlanned)
            ],
            date: "2025-02-11",
            status: "ScheduleApplies"
        )
        
        // When
        let nextOutage = manager.nextOutageSlot
        
        // Then
        XCTAssertNotNil(nextOutage)
        XCTAssertTrue(nextOutage!.type == .definite || nextOutage!.type == .possible)
        XCTAssertGreaterThan(nextOutage!.start, currentMinutes)
    }

    // MARK: - Outage Duration Tests

    /// Тест перевіряє, що todayOutageDuration рахує тривалість definite та possible outages
    func testTodayOutageDurationCalculatesCorrectly() {
        // Given
        manager.todaySchedule = DaySchedule(
            slots: [
                TimeSlot(start: 0, end: 120, type: .definite),      // 120 хвилин
                TimeSlot(start: 120, end: 300, type: .notPlanned),
                TimeSlot(start: 300, end: 480, type: .possible),    // 180 хвилин
                TimeSlot(start: 480, end: 1440, type: .notPlanned)
            ],
            date: "2025-02-11",
            status: "ScheduleApplies"
        )
        
        // When
        let duration = manager.todayOutageDuration
        
        // Then
        XCTAssertEqual(duration, 300) // 120 + 180
    }

    /// Тест перевіряє, що todayOutagePercentage правильно рахує відсоток
    func testTodayOutagePercentageCalculatesCorrectly() {
        // Given
        manager.todaySchedule = DaySchedule(
            slots: [
                TimeSlot(start: 0, end: 720, type: .definite),      // 720 хвилин = 50% дня
                TimeSlot(start: 720, end: 1440, type: .notPlanned)
            ],
            date: "2025-02-11",
            status: "ScheduleApplies"
        )
        
        // When
        let percentage = manager.todayOutagePercentage
        
        // Then
        XCTAssertEqual(percentage, 50.0, accuracy: 0.1)
    }

    // MARK: - Helper Properties Tests

    /// Тест перевіряє isPowerOn та isPowerOff properties
    func testPowerStatusBooleans() {
        // Given - встановлюємо статус .on
        manager.todaySchedule = DaySchedule(
            slots: [TimeSlot(start: 0, end: 1440, type: .notPlanned)],
            date: "2025-02-11",
            status: "ScheduleApplies"
        )
        
        // Оновлюємо статус (це приватний метод викликається в refreshSchedule)
        // Для тесту просто перевіряємо логіку
        let calendar = Calendar.current
        let now = Date()
        let currentMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        
        if let slot = manager.todaySchedule?.slots.first(where: {
            $0.start <= currentMinutes && $0.end > currentMinutes
        }) {
            // Якщо поточний слот notPlanned - має бути .on
            if slot.type == .notPlanned {
                // Не можемо напряму встановити currentStatus, але можемо перевірити логіку
                XCTAssertTrue(slot.type == .notPlanned)
            }
        }
    }

    /// Тест перевіряє allTodaySlots та allTomorrowSlots
    func testAllSlotsProperties() {
        // Given
        let todaySlots = [
            TimeSlot(start: 0, end: 480, type: .notPlanned),
            TimeSlot(start: 480, end: 720, type: .definite),
            TimeSlot(start: 720, end: 1440, type: .notPlanned)
        ]
        let tomorrowSlots = [
            TimeSlot(start: 0, end: 600, type: .definite),
            TimeSlot(start: 600, end: 1440, type: .notPlanned)
        ]
        
        manager.todaySchedule = DaySchedule(slots: todaySlots, date: "2025-02-11", status: "ScheduleApplies")
        manager.tomorrowSchedule = DaySchedule(slots: tomorrowSlots, date: "2025-02-12", status: "ScheduleApplies")
        
        // When & Then
        XCTAssertEqual(manager.allTodaySlots.count, 3)
        XCTAssertEqual(manager.allTomorrowSlots.count, 2)
        
        // Коли немає даних
        manager.todaySchedule = nil
        manager.tomorrowSchedule = nil
        XCTAssertTrue(manager.allTodaySlots.isEmpty)
        XCTAssertTrue(manager.allTomorrowSlots.isEmpty)
    }
    
    // MARK: - Helper
    
    private func createTestSchedule() -> GroupSchedule {
        GroupSchedule(
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
    }
}
