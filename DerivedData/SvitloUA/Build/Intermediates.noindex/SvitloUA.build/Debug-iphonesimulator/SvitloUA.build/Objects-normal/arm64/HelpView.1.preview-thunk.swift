import func SwiftUI.__designTimeFloat
import func SwiftUI.__designTimeString
import func SwiftUI.__designTimeInteger
import func SwiftUI.__designTimeBoolean

#sourceLocation(file: "/Users/call_the_ha/Desktop/Development/SvitloUA/SvitloUA/Screens/HelpView.swift", line: 1)
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
            VStack(spacing: __designTimeInteger("#4602_0", fallback: 0)) {
                // Tab Selector
                Picker(__designTimeString("#4602_1", fallback: ""), selection: $selectedTab) {
                    Text(__designTimeString("#4602_2", fallback: "Моя група")).tag(__designTimeInteger("#4602_3", fallback: 0))
                    Text(__designTimeString("#4602_4", fallback: "Статистика")).tag(__designTimeInteger("#4602_5", fallback: 1))
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    GroupHelpView()
                        .tag(__designTimeInteger("#4602_6", fallback: 0))
                    
                    StatisticsHelpView()
                        .tag(__designTimeInteger("#4602_7", fallback: 1))
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle(__designTimeString("#4602_8", fallback: "Довідка"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(__designTimeString("#4602_9", fallback: "Готово")) {
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
            VStack(alignment: .leading, spacing: __designTimeInteger("#4602_10", fallback: 20)) {
                HelpSection(
                    icon: __designTimeString("#4602_11", fallback: "map.fill"),
                    title: __designTimeString("#4602_12", fallback: "Як дізнатись свою групу відключень?"),
                    content: __designTimeString("#4602_13", fallback: """
                    Є кілька способів дізнатись вашу групу:
                    """)
                )
                
                HelpStepCard(
                    number: __designTimeInteger("#4602_14", fallback: 1),
                    title: __designTimeString("#4602_15", fallback: "Через сайт Yasno"),
                    description: __designTimeString("#4602_16", fallback: "Перейдіть на yasno.com.ua → введіть свою адресу → система покаже вашу групу відключень")
                )
                
                HelpStepCard(
                    number: __designTimeInteger("#4602_17", fallback: 2),
                    title: __designTimeString("#4602_18", fallback: "За адресою"),
                    description: __designTimeString("#4602_19", fallback: "Знайдіть свій будинок у списку на сайті вашої обленерго. Там вказана група для кожної вулиці")
                )
                
                HelpStepCard(
                    number: __designTimeInteger("#4602_20", fallback: 3),
                    title: __designTimeString("#4602_21", fallback: "Через ДТЕК/Обленерго"),
                    description: __designTimeString("#4602_22", fallback: "Зателефонуйте до контакт-центру вашої енергокомпанії та повідомте адресу. Оператор підкаже вашу групу")
                )
                
                InfoBox(
                    icon: __designTimeString("#4602_23", fallback: "lightbulb.fill"),
                    title: __designTimeString("#4602_24", fallback: "Корисна інформація"),
                    text: __designTimeString("#4602_25", fallback: "Групи позначаються як 1.1, 1.2, 2.1, 2.2 і т.д. Перша цифра - основна черга, друга - підчерга відключень"),
                    color: .blue
                )
                
                InfoBox(
                    icon: __designTimeString("#4602_26", fallback: "exclamationmark.triangle.fill"),
                    title: __designTimeString("#4602_27", fallback: "Важливо"),
                    text: __designTimeString("#4602_28", fallback: "Графіки можуть змінюватись! Перевіряйте актуальну інформацію на офіційних сайтах енергокомпаній"),
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
            VStack(alignment: .leading, spacing: __designTimeInteger("#4602_29", fallback: 20)) {
                HelpSection(
                    icon: __designTimeString("#4602_30", fallback: "chart.bar.fill"),
                    title: __designTimeString("#4602_31", fallback: "Як вести статистику відключень?"),
                    content: __designTimeString("#4602_32", fallback: """
                    SvitloUA автоматично веде статистику ваших відключень:
                    """)
                )
                
                HelpStepCard(
                    number: __designTimeInteger("#4602_33", fallback: 1),
                    title: __designTimeString("#4602_34", fallback: "Автоматичне відстеження"),
                    description: __designTimeString("#4602_35", fallback: "Додаток автоматично записує всі події відключень на основі графіку для вашої групи")
                )
                
                HelpStepCard(
                    number: __designTimeInteger("#4602_36", fallback: 2),
                    title: __designTimeString("#4602_37", fallback: "Ручне додавання"),
                    description: __designTimeString("#4602_38", fallback: "Ви можете вручну додати подію відключення, якщо воно відбулось поза графіком (функція буде додана)")
                )
                
                HelpStepCard(
                    number: __designTimeInteger("#4602_39", fallback: 3),
                    title: __designTimeString("#4602_40", fallback: "Перегляд статистики"),
                    description: "У вкладці 'Статистика' ви побачите:\n• Кількість відключень за день/тиждень/місяць\n• Графік відключень за останні 7 днів\n• Історію всіх подій"
                )
                
                InfoBox(
                    icon: __designTimeString("#4602_41", fallback: "clock.fill"),
                    title: __designTimeString("#4602_42", fallback: "Зберігання даних"),
                    text: __designTimeString("#4602_43", fallback: "Додаток зберігає до 1000 останніх подій. Старіші записи автоматично видаляються"),
                    color: .purple
                )
                
                InfoBox(
                    icon: __designTimeString("#4602_44", fallback: "arrow.clockwise"),
                    title: __designTimeString("#4602_45", fallback: "Оновлення графіку"),
                    text: __designTimeString("#4602_46", fallback: "Натисніть кнопку оновлення у вкладці 'Графік', щоб отримати актуальну інформацію з серверу"),
                    color: .green
                )
                
                VStack(alignment: .leading, spacing: __designTimeInteger("#4602_47", fallback: 12)) {
                    Text(__designTimeString("#4602_48", fallback: "Що означають кольори:"))
                        .font(.headline)
                    
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: __designTimeInteger("#4602_49", fallback: 12), height: __designTimeInteger("#4602_50", fallback: 12))
                        Text(__designTimeString("#4602_51", fallback: "Світло є / Увімкнення"))
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: __designTimeInteger("#4602_52", fallback: 12), height: __designTimeInteger("#4602_53", fallback: 12))
                        Text(__designTimeString("#4602_54", fallback: "Відключення"))
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: __designTimeInteger("#4602_55", fallback: 12), height: __designTimeInteger("#4602_56", fallback: 12))
                        Text(__designTimeString("#4602_57", fallback: "Невідомий статус"))
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(__designTimeInteger("#4602_58", fallback: 12))
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
        VStack(alignment: .leading, spacing: __designTimeInteger("#4602_59", fallback: 12)) {
            HStack(spacing: __designTimeInteger("#4602_60", fallback: 12)) {
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
        HStack(alignment: .top, spacing: __designTimeInteger("#4602_61", fallback: 16)) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: __designTimeInteger("#4602_62", fallback: 36), height: __designTimeInteger("#4602_63", fallback: 36))
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: __designTimeInteger("#4602_64", fallback: 6)) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: __designTimeBoolean("#4602_65", fallback: false), vertical: __designTimeBoolean("#4602_66", fallback: true))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(__designTimeInteger("#4602_67", fallback: 12))
    }
}

struct InfoBox: View {
    let icon: String
    let title: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: __designTimeInteger("#4602_68", fallback: 12)) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: __designTimeInteger("#4602_69", fallback: 4)) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: __designTimeBoolean("#4602_70", fallback: false), vertical: __designTimeBoolean("#4602_71", fallback: true))
            }
        }
        .padding()
        .background(color.opacity(__designTimeFloat("#4602_72", fallback: 0.1)))
        .cornerRadius(__designTimeInteger("#4602_73", fallback: 12))
    }
}

// MARK: - Preview
#Preview {
    HelpView()
}
