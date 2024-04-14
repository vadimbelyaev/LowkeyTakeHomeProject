//
//  PexelsCuratedPhotosResponse.swift
//  LowkeyTakeHome
//
//  Created by Vadim Belyaev on 14.04.2024.
//

import Foundation

struct PexelsCuratedPhotosResponse: Decodable {
    let page: Int
    let perPage: Int
    let photos: [PexelsPhoto]
    let nextPage: URL?
}
