//
//  Extensions+URL.swift
//  SvitloUA
//
//  Created by Горніч Антон on 24.01.2026.
//

import Foundation


extension URL{
    func appendingPathComponentRaw(_ pathComponent: String) -> URL {
            let baseString = self.absoluteString
            let separator = baseString.hasSuffix("/") ? "" : "/"
            return URL(string: baseString + separator + pathComponent)!
        }
}


