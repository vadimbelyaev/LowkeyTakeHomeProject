//
//  ViewController.swift
//  LowkeyTakeHome
//
//  Created by Vadim Belyaev on 14.04.2024.
//

import Combine
import UIKit

class PhotosViewController: UIViewController {

    private let collectionView: UICollectionView
    private let model: PhotosViewModel
    private var dataSource: CuratedPhotosDataSource!
    private var cancellables: Set<AnyCancellable> = []
    private static let cellIdentifier = String(describing: PhotoCell.self)

    init(model: PhotosViewModel) {
        self.model = model
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeCollectionViewLayout())
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Curated Photos", comment: "Title of the Curated Photos screen")
        configureCollectionView()
        setUpSubscriptions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        model.loadFirstPageIfNeeded()
    }

    private func configureCollectionView() {
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: Self.cellIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        dataSource = CuratedPhotosDataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
                self?.makeCell(for: collectionView, at: indexPath, photo: itemIdentifier)
            }
        )
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }

    private func setUpSubscriptions() {
        model.$photosSnapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot)
            }
            .store(in: &cancellables)
    }

    private func makeCell(for collectionView: UICollectionView, at indexPath: IndexPath, photo: PexelsPhoto) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.cellIdentifier,
            for: indexPath
        ) as? PhotoCell else {
            fatalError("Unexpected cell class")
        }
        cell.configure(with: photo, imageService: model.imageService)
        return cell
    }

    private static func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        model.willDisplayCell(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model.routeToDetails(ofPhotoAt: indexPath)
    }
}

enum CuratedPhotosSection {
    case main
}

final class CuratedPhotosDataSource: UICollectionViewDiffableDataSource<CuratedPhotosSection, PexelsPhoto> {}


