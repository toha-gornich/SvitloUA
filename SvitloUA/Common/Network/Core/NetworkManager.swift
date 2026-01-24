//
//  NetworkManager.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//

import SwiftUI

final class NetworkManager {
    
    // MARK: - Singleton
    static let shared = NetworkManager()
    
    // MARK: - Properties
    let cache = NSCache<NSString, UIImage>()
    
    private let session: URLSession
    
    // MARK: - Initialization
    private init(session: URLSession = .shared) {
        self.session = session
    }
}
