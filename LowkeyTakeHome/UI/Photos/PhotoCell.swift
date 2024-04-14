//
//  PhotoCell.swift
//  LowkeyTakeHome
//
//  Created by Vadim Belyaev on 14.04.2024.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let photographerLabel = UILabel()
    private var currentTask: Task<Void, any Error>?

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)

        photographerLabel.translatesAutoresizingMaskIntoConstraints = false
        photographerLabel.textColor = .white
        photographerLabel.font = .preferredFont(forTextStyle: .caption1)
        contentView.addSubview(photographerLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            photographerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            photographerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photographerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.layer.shadowRadius = 3
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowColor = UIColor.black.cgColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        currentTask = nil
        imageView.image = nil
    }

    func configure(with photo: PexelsPhoto, imageService: ImageService) {
        currentTask = Task {
            let image = try await imageService.loadImage(from: photo.src.large2x)
            try Task.checkCancellation()
            let preparedImage = await image.byPreparingForDisplay()
            try Task.checkCancellation()
            imageView.image = preparedImage
        }
        photographerLabel.text = photo.photographer
    }
}
