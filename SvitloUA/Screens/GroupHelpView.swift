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
                    title: NSLocalizedString("Як дізнатись свою групу відключень?", comment: "How to find your outage group"),
                    content: NSLocalizedString("Є кілька способів дізнатись вашу групу:", comment: "There are several ways to find your group")
                )
                
                HelpStepCard(
                    number: 1,
                    title: NSLocalizedString("Через сайт Yasno", comment: "Via Yasno website"),
                    description: NSLocalizedString("Перейдіть на yasno.com.ua → введіть свою адресу → система покаже вашу групу відключень", comment: "Go to yasno.com.ua → enter your address → system will show your outage group")
                )
                
                HelpStepCard(
                    number: 2,
                    title: NSLocalizedString("За адресою", comment: "By address"),
                    description: NSLocalizedString("Знайдіть свій будинок у списку на сайті вашої обленерго. Там вказана група для кожної вулиці", comment: "Find your building in the list on your regional energy company website. The group is specified for each street")
                )
                
                HelpStepCard(
                    number: 3,
                    title: NSLocalizedString("Через ДТЕК/Обленерго", comment: "Via DTEK/Regional energy company"),
                    description: NSLocalizedString("Зателефонуйте до контакт-центру вашої енергокомпанії та повідомте адресу. Оператор підкаже вашу групу", comment: "Call your energy company contact center and provide your address. Operator will tell you your group")
                )
                
                InfoBox(
                    icon: "lightbulb.fill",
                    title: NSLocalizedString("Корисна інформація", comment: "Useful information"),
                    text: NSLocalizedString("Групи позначаються як 1.1, 1.2, 2.1, 2.2 і т.д. Перша цифра - основна черга, друга - підчерга відключень", comment: "Groups are marked as 1.1, 1.2, 2.1, 2.2 etc. First digit is main queue, second is sub-queue of outages"),
                    color: .blue
                )
                
                InfoBox(
                    icon: "exclamationmark.triangle.fill",
                    title: NSLocalizedString("Важливо", comment: "Important"),
                    text: NSLocalizedString("Графіки можуть змінюватись! Перевіряйте актуальну інформацію на офіційних сайтах енергокомпаній", comment: "Schedules can change! Check current information on official energy company websites"),
                    color: .orange
                )
            }
            .padding()
        }
    }
}
