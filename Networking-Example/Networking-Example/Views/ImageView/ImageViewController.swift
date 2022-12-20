//
//  ImageViewController.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-20.
//

import UIKit
import Combine

final class ImageViewController: UIViewController {

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.center = view.center
        return spinner
    }()

    private let responsePublisher: AnyPublisher<Data, Error>
    private var cancel: AnyCancellable?

    // MARK: - Init
    init(publisher: AnyPublisher<Data, Error>) {
        self.responsePublisher = publisher
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Image"
        view.backgroundColor = .systemBackground
        view.addSubview(spinner)
        view.addSubview(imageView)

        spinner.startAnimating()

        cancel = responsePublisher
            .compactMap { UIImage(data: $0) }
            .assertNoFailure()
            .receive(on: RunLoop.main)
            .assign(to: \.image, on: imageView)
    }
}
