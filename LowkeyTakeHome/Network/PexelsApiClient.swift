//
//  PexelsApiClient.swift
//  LowkeyTakeHome
//
//  Created by Vadim Belyaev on 14.04.2024.
//

import Foundation

final class PexelsApiClient {
    private let apiKey: String
    private static let baseUrl = URL(string: "https://api.pexels.com/v1")!

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func fetchCuratedPhotos(page: Int = 1, photosPerPage: Int = 10) async throws -> PexelsCuratedPhotosResponse {
        let endpointUrl = Self.baseUrl.appendingPathComponent("curated")
        guard var components = URLComponents(url: endpointUrl, resolvingAgainstBaseURL: false) else {
            throw Error.couldNotMakeRequestUrl
        }
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(photosPerPage))
        ]
        guard let url = components.url else {
            throw Error.couldNotMakeRequestUrl
        }
        return try await loadCuratedPhotos(from: url)
    }

    func fetchCuratedPhotos(fromNextPageUrl url: URL) async throws -> PexelsCuratedPhotosResponse {
        try await loadCuratedPhotos(from: url)
    }

    private func loadCuratedPhotos(from url: URL) async throws -> PexelsCuratedPhotosResponse {
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw Error.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(PexelsCuratedPhotosResponse.self, from: data)
    }
}

extension PexelsApiClient {
    enum Error: Swift.Error {
        case couldNotMakeRequestUrl
        case invalidResponse
    }
}
