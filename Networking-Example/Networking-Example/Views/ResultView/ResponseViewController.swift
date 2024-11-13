//
//  ResponseViewController.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
//

import UIKit
import Combine

final class ResponseViewController: UIViewController {

    private lazy var textView: UITextView = {
        let textView = UITextView(frame: view.frame)
        textView.font = UIFont(name: "Menlo", size: 12.0)
        textView.isSelectable = false
        textView.isEditable = false
        return textView
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

        title = "Response"
        view.addSubview(textView)

        textView.text = String(data: responseData, encoding: .utf8)
    }
}
