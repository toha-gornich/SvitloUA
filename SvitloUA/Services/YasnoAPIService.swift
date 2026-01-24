//
//  YasnoAPIService.swift
//  SvitloUA
//
//  Created by Горніч Антон on 23.01.2026.
//
import Foundation
import os.log

class YasnoAPIService {
    static let shared = YasnoAPIService()
    
    private let baseURL = "https://api.yasno.com.ua/api/v1/pages/home/schedule-turn-off-electricity"
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "YasnoApp", category: "YasnoAPIService")
    
    func fetchSchedule() async throws -> YasnoScheduleResponse {
        logger.info("Починаємо завантаження розкладу з API")
        
        guard let url = URL(string: baseURL) else {
            logger.error("Невалідний URL: \(self.baseURL)")
            throw URLError(.badURL)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.info("Отримано відповідь з кодом: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    logger.warning("Неочікуваний статус код: \(httpResponse.statusCode)")
                }
            }
            
            logger.debug("Розмір отриманих даних: \(data.count) байт")
            
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let components = jsonObject["components"] as? [[String: Any]] {
                logger.debug("Знайдено \(components.count) компонентів у JSON")
                for (index, component) in components.enumerated() {
                    if let templateName = component["template_name"] as? String {
                        let keys = component.keys.joined(separator: ", ")
                        logger.debug("Компонент \(index): '\(templateName)', ключі: \(keys)")
                        
                        
                        if templateName == "electricity-outages-daily-schedule",
                           let schedule = component["schedule"] as? [String: Any] {
                            logger.debug("Структура schedule містить регіони: \(schedule.keys.joined(separator: ", "))")
                            
                            
                            if let firstRegion = schedule.keys.first,
                               let regionData = schedule[firstRegion] as? [String: Any] {
                                logger.debug("Структура регіону '\(firstRegion)': \(regionData.keys.joined(separator: ", "))")
                                
                                
                                if let firstGroup = regionData.keys.first,
                                   let groupData = regionData[firstGroup] {
                                    logger.debug("Структура групи '\(firstGroup)': \(type(of: groupData))")
                                    if let groupArray = groupData as? [[String: Any]] {
                                        logger.debug("Група - це масив з \(groupArray.count) елементів")
                                        if let firstItem = groupArray.first {
                                            logger.debug("Перший елемент масиву: \(firstItem.keys.joined(separator: ", "))")
                                            let startValue = String(describing: firstItem["start"] ?? "nil")
                                            let endValue = String(describing: firstItem["end"] ?? "nil")
                                            let typeValue = String(describing: firstItem["type"] ?? "nil")
                                            logger.debug("Приклад слоту: start=\(startValue), end=\(endValue), type=\(typeValue)")
                                        }
                                    } else if let groupArray = groupData as? [Any] {
                                        logger.debug("Група - це масив Any з \(groupArray.count) елементів")
                                        if let firstItem = groupArray.first {
                                            logger.debug("Тип першого елемента: \(type(of: firstItem))")
                                            logger.debug("Значення: \(String(describing: firstItem))")
                                        }
                                    }
                                }
                            }
                            
                            
                            if let scheduleData = try? JSONSerialization.data(withJSONObject: schedule, options: .prettyPrinted),
                               let scheduleString = String(data: scheduleData, encoding: .utf8) {
                                logger.debug("=== SCHEDULE JSON (перші 3000 символів) ===")
                                logger.debug("\(String(scheduleString.prefix(3000)))")
                            }
                        }
                    }
                }
                
                
                if let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let prettyString = String(data: prettyData, encoding: .utf8) {
                    logger.debug("=== ПОВНИЙ JSON (перші 2000 символів) ===")
                    logger.debug("\(String(prettyString.prefix(2000)))")
                }
            }
            
            let decoder = JSONDecoder()
            let scheduleResponse = try decoder.decode(YasnoScheduleResponse.self, from: data)
            
            logger.info("Розклад успішно декодовано, компонентів: \(scheduleResponse.components.count)")
            
            
            for (index, component) in scheduleResponse.components.enumerated() {
                logger.debug("Компонент \(index): templateName='\(component.templateName)', має schedule=\(component.schedule != nil)")
            }
            
            return scheduleResponse
            
        } catch let decodingError as DecodingError {
            logger.error("Помилка декодування JSON: \(decodingError.localizedDescription)")
            switch decodingError {
            case .keyNotFound(let key, let context):
                logger.error("Відсутній ключ '\(key.stringValue)' в контексті: \(context.debugDescription)")
                logger.error("Шлях до ключа: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            case .typeMismatch(let type, let context):
                logger.error("Невідповідність типу \(String(describing: type)) в контексті: \(context.debugDescription)")
                logger.error("Шлях: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            case .valueNotFound(let type, let context):
                logger.error("Відсутнє значення типу \(String(describing: type)) в контексті: \(context.debugDescription)")
                logger.error("Шлях: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            case .dataCorrupted(let context):
                logger.error("Пошкоджені дані в контексті: \(context.debugDescription)")
                logger.error("Шлях: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            @unknown default:
                logger.error("Невідома помилка декодування")
            }
            throw decodingError
            
        } catch let urlError as URLError {
            logger.error("Помилка мережі: \(urlError.localizedDescription), код: \(urlError.code.rawValue)")
            throw urlError
            
        } catch {
            logger.error("Невідома помилка при завантаженні розкладу: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getScheduleForRegionAndGroup(region: String, group: String) async throws -> [TimeSlot] {
        logger.info("Запит розкладу для регіону '\(region)', групи '\(group)'")
        
        do {
            let response = try await fetchSchedule()
            
            guard let component = response.components.first(where: { $0.templateName == "electricity-outages-daily-schedule" }) else {
                logger.error("Компонент 'electricity-outages-daily-schedule' не знайдено у відповіді")
                logger.debug("Доступні компоненти: \(response.components.map { $0.templateName }.joined(separator: ", "))")
                throw NSError(domain: "YasnoAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Schedule component not found"])
            }
            
            guard let scheduleData = component.schedule else {
                logger.error("schedule відсутній у компоненті")
                throw NSError(domain: "YasnoAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Schedule data is missing"])
            }
            
            guard let regionSchedule = scheduleData[region] else {
                let availableRegions = scheduleData.regions.keys.sorted().joined(separator: ", ")
                logger.error("Розклад для регіону '\(region)' не знайдено. Доступні регіони: \(availableRegions)")
                throw NSError(domain: "YasnoAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Schedule for region '\(region)' not found"])
            }
            
            // Формуємо ключ групи у форматі "group_X.Y"
            let groupKey = "group_\(group)"
            
            guard let weekSchedule = regionSchedule.groups[groupKey] else {
                let availableGroups = regionSchedule.groups.keys.sorted().joined(separator: ", ")
                logger.error("Група '\(groupKey)' не знайдена. Доступні групи: \(availableGroups)")
                throw NSError(domain: "YasnoAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group '\(group)' not found"])
            }
            
            // Визначаємо поточний день тижня (0 = неділя, 1 = понеділок, ...)
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: Date())
            // Конвертуємо в індекс масиву (0 = понеділок, 6 = неділя)
            let dayIndex = weekday == 1 ? 6 : weekday - 2
            
            guard dayIndex < weekSchedule.count else {
                logger.error("Індекс дня \(dayIndex) виходить за межі масиву розкладу (\(weekSchedule.count) днів)")
                throw NSError(domain: "YasnoAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid day index"])
            }
            
            let todaySlots = weekSchedule[dayIndex]
            
            logger.info("Успішно отримано розклад: \(todaySlots.count) слотів для групи '\(group)' на день \(dayIndex)")
            
            return todaySlots
            
        } catch {
            logger.error("Помилка при отриманні розкладу для регіону/групи: \(error.localizedDescription)")
            throw error
        }
    }
}
