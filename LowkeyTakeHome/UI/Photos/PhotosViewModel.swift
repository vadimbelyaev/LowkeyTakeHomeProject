//
//  PhotosViewModel.swift
//  LowkeyTakeHome
//
//  Created by Vadim Belyaev on 14.04.2024.
//

import Foundation
import UIKit

typealias PhotosSnapshot = NSDiffableDataSourceSnapshot<CuratedPhotosSection, PexelsPhoto>

@MainActor
final class PhotosViewModel {
    @Published var photosSnapshot: PhotosSnapshot = .empty()
    let imageService: ImageService
    weak var navigationController: UINavigationController?

    private let pexelsApiClient: PexelsApiClient
    private var photos: [PexelsPhoto] = []
    private var nextPageUrl: URL?
    private var currentTask: Task<Void, any Error>?

    init(pexelsApiClient: PexelsApiClient, imageService: ImageService) {
        self.pexelsApiClient = pexelsApiClient
        self.imageService = imageService
    }

    func loadFirstPageIfNeeded() {
        guard currentTask == nil, photos.isEmpty else { return }
        currentTask = Task {
            let response = try await pexelsApiClient.fetchCuratedPhotos()
            process(response: response)
            currentTask = nil
        }
    }

    func willDisplayCell(at indexPath: IndexPath) {
        guard currentTask == nil else { return }
        let itemIndex = indexPath.item
        if itemIndex == photos.count - 5 {
            loadNextPageIfPossible()
        }
    }

    func routeToDetails(ofPhotoAt indexPath: IndexPath) {
        let photo = photos[indexPath.item]
        let photoDetailsVM = PhotoDetailsViewModel(imageService: imageService, photo: photo)
        let photoDetailsVC = PhotoDetailsViewController(model: photoDetailsVM)
        navigationController?.pushViewController(photoDetailsVC, animated: true)
    }

    private func loadNextPageIfPossible() {
        guard let nextPageUrl else { return }
        currentTask = Task {
            let response = try await pexelsApiClient.fetchCuratedPhotos(fromNextPageUrl: nextPageUrl)
            process(response: response)
            currentTask = nil
        }
    }

    private func process(response: PexelsCuratedPhotosResponse) {
        nextPageUrl = response.nextPage
        photos.append(contentsOf: response.photos)
        var newSnapshot = PhotosSnapshot()
        newSnapshot.appendSections([.main])
        newSnapshot.appendItems(photos, toSection: .main)
        photosSnapshot = newSnapshot
    }
}

private extension PhotosSnapshot {
    static func empty() -> Self {
        var snapshot = PhotosSnapshot()
        snapshot.appendSections([.main])
        return snapshot
    }
}
