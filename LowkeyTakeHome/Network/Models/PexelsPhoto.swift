//
//  PexelsPhoto.swift
//  LowkeyTakeHome
//
//  Created by Vadim Belyaev on 14.04.2024.
//

import Foundation

struct PexelsPhoto: Decodable, Hashable {
    let id: Int
    let width: Double
    let height: Double
    let url: URL
    let photographer: String
    let src: Sources
    let avgColor: String

}

extension PexelsPhoto {
    struct Sources: Decodable, Hashable {
        let original: URL
        let large2x: URL
    }
}
