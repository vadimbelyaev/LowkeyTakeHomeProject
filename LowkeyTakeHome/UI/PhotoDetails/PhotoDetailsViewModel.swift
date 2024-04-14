//
//  PhotoDetailsViewModel.swift
//  LowkeyTakeHome
//
//  Created by Vadim Belyaev on 14.04.2024.
//

import UIKit

@MainActor
final class PhotoDetailsViewModel {
    private let imageService: ImageService
    private let photo: PexelsPhoto
    @Published var image: UIImage?

    init(imageService: ImageService, photo: PexelsPhoto) {
        self.imageService = imageService
        self.photo = photo
    }

    func loadImage() {
        Task {
            image = try await imageService.loadImage(from: photo.src.original)
        }
    }

    func getTitle() -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("Photo by %@", comment: "Title of the photo details screen"),
            photo.photographer
        )
    }
}
