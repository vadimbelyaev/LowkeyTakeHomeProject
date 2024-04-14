//
//  ImageService.swift
//  LowkeyTakeHome
//
//  Created by Vadim Belyaev on 14.04.2024.
//

import UIKit

final class ImageService {
    private let imageCache = NSCache<NSURL, UIImage>()

    func loadImage(from url: URL) async throws -> UIImage {
        let nsUrl = url as NSURL
        if let cachedImage = imageCache.object(forKey: url as NSURL) {
            return cachedImage
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw Error.invalidResponse
        }
        guard let image = UIImage(data: data) else {
            throw Error.nonImageData
        }
        imageCache.setObject(image, forKey: nsUrl)
        return image
    }
}

extension ImageService {
    enum Error: Swift.Error {
        case invalidResponse
        case nonImageData
    }
}
