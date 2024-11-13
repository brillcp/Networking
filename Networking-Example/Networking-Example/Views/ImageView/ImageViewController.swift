//
//  ImageViewController.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
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

    private let responseData: Data
    private var cancel: AnyCancellable?

    // MARK: - Init
    init(data: Data) {
        self.responseData = data
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

        imageView.image = UIImage(data: responseData)
    }
}
