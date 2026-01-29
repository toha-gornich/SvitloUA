//
//  Extensions+View.swift
//  SvitloUA
//
//  Created by Горніч Антон on 29.01.2026.
//

import SwiftUI

extension View{
    func appBackground() -> some View{
        ZStack{
            Color.appBackground.ignoresSafeArea()
            self
        }
    }
}
