//
//  StatisticsHelpView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 26.01.2026.
//


import SwiftUI

struct StatisticsHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HelpSection(
                    icon: "chart.bar.fill",
                    title: "Як вести статистику відключень?",
                    content: """
                    SvitloUA автоматично веде статистику ваших відключень:
                    """
                )
                
                HelpStepCard(
                    number: 1,
                    title: "Автоматичне відстеження",
                    description: "Додаток автоматично записує всі події відключень на основі графіку для вашої групи"
                )
                
                HelpStepCard(
                    number: 2,
                    title: "Ручне додавання",
                    description: "Ви можете вручну додати подію відключення, якщо воно відбулось поза графіком (функція буде додана)"
                )
                
                HelpStepCard(
                    number: 3,
                    title: "Перегляд статистики",
                    description: "У вкладці 'Статистика' ви побачите:\n• Кількість відключень за день/тиждень/місяць\n• Графік відключень за останні 7 днів\n• Історію всіх подій"
                )
                
                InfoBox(
                    icon: "clock.fill",
                    title: "Зберігання даних",
                    text: "Додаток зберігає до 1000 останніх подій. Старіші записи автоматично видаляються",
                    color: .purple
                )
                
                InfoBox(
                    icon: "arrow.clockwise",
                    title: "Оновлення графіку",
                    text: "Натисніть кнопку оновлення у вкладці 'Графік', щоб отримати актуальну інформацію з серверу",
                    color: .green
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Що означають кольори:")
                        .font(.headline)
                    
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                        Text("Світло є / Увімкнення")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                        Text("Відключення")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 12, height: 12)
                        Text("Невідомий статус")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}