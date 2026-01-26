//
//  GroupHelpView.swift
//  SvitloUA
//
//  Created by Горніч Антон on 26.01.2026.
//


import SwiftUI

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