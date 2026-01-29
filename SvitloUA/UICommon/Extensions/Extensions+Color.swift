//
//  Extensions+Color.swift
//  SvitloUA
//
//  Created by Горніч Антон on 29.01.2026.
//

import SwiftUI

//extension Color {
//    static let appBackground = Color(red: 0.0, green: 1.0, blue: 0.0)
//}
extension Color {
    static let appBackground = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) 
        default:
            return UIColor.white
        }
    })
}
