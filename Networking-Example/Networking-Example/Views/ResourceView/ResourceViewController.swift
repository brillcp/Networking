//
//  ResourceViewController.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
//

import UIKit
import Combine
import Networking_Swift

protocol Titleable {
    var title: String { get }
}

final class ResourceViewController: UIViewController, UITableViewDelegate {

    // MARK: Private properties
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: view.frame)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = 60.0
        table.delegate = self
        return table
    }()

    private var dataSource: UITableViewDiffableDataSource<String, AnyHashable>!
    private let service: Network.Service
    private let apiData: APIListData

    // MARK: - Init
    init(apiData: APIListData) {
        self.apiData = apiData
        self.service = Network.Service(server: ServerConfig(baseURL: apiData.url))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = apiData.name
        view.addSubview(tableView)
        setupData()
    }

    // MARK: - Private functions
    private func setupData() {
        dataSource = UITableViewDiffableDataSource<String, AnyHashable>(tableView: tableView) { tableView, _, data in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.accessoryType = .disclosureIndicator

            if let request = data as? Titleable {
                cell?.textLabel?.text = request.title
            }
            return cell
        }

        var snap = NSDiffableDataSourceSnapshot<String, AnyHashable>()
        snap.appendSections(["main"])
        snap.appendItems(apiData.endpoints)
        dataSource.apply(snap, animatingDifferences: true)
    }

    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let request = dataSource.itemIdentifier(for: indexPath) as? Requestable else { return }

        do {
            let resultView = ResultViewController(publisher: try service.dataPublisher(request))
            navigationController?.pushViewController(resultView, animated: true)
        } catch {
            fatalError("Something bad happened :(")
        }
    }
}
