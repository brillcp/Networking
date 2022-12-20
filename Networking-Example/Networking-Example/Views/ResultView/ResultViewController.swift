//
//  ResultViewController.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
//

import UIKit
import Combine

final class ResultViewController: UIViewController {

    private lazy var textView: UITextView = {
        let textView = UITextView(frame: view.frame)
        textView.font = UIFont(name: "Menlo", size: 10.0)
        textView.isSelectable = false
        textView.isEditable = false
        return textView
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

        title = "Response"
        view.addSubview(textView)

        cancel = responsePublisher
            .tryMap { try JSONSerialization.jsonObject(with: $0) }
            .tryMap { try JSONSerialization.data(withJSONObject: $0, options: [.prettyPrinted, .sortedKeys]) }
            .compactMap { String(data: $0, encoding: .utf8) }
            .compactMap { $0.replacingOccurrences(of: " :", with: ":") }
            .compactMap { $0.replacingOccurrences(of: "\\", with: "") }
            .assertNoFailure()
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: textView)
    }
}
