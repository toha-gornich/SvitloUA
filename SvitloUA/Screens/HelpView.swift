//
//  HelpView.swift
//  SvitloUA
//
//  Created by Assistant on 25.01.2026.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("", selection: $selectedTab) {
                    Text("Моя група").tag(0)
                    Text("Статистика").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    GroupHelpView()
                        .tag(0)
                    
                    StatisticsHelpView()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Довідка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Group Help View
struct GroupHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HelpSection(
                    icon: "map.fill",
                    title: "Як дізнатись свою групу відключень?",
                    content: """
                    Є кілька способів дізнатись вашу групу:
                    """
                )
                
                HelpStepCard(
                    number: 1,
                    title: "Через сайт Yasno",
                    description: "Перейдіть на yasno.com.ua → введіть свою адресу → система покаже вашу групу відключень"
                )
                
                HelpStepCard(
                    number: 2,
                    title: "За адресою",
                    description: "Знайдіть свій будинок у списку на сайті вашої обленерго. Там вказана група для кожної вулиці"
                )
                
                HelpStepCard(
                    number: 3,
                    title: "Через ДТЕК/Обленерго",
                    description: "Зателефонуйте до контакт-центру вашої енергокомпанії та повідомте адресу. Оператор підкаже вашу групу"
                )
                
                InfoBox(
                    icon: "lightbulb.fill",
                    title: "Корисна інформація",
                    text: "Групи позначаються як 1.1, 1.2, 2.1, 2.2 і т.д. Перша цифра - основна черга, друга - підчерга відключень",
                    color: .blue
                )
                
                InfoBox(
                    icon: "exclamationmark.triangle.fill",
                    title: "Важливо",
                    text: "Графіки можуть змінюватись! Перевіряйте актуальну інформацію на офіційних сайтах енергокомпаній",
                    color: .orange
                )
            }
            .padding()
        }
    }
}

// MARK: - Statistics Help View
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

// MARK: - Helper Components
struct HelpSection: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct HelpStepCard: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 36, height: 36)
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InfoBox: View {
    let icon: String
    let title: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    HelpView()
}
