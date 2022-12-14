//
//  APIListViewController.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
//

import UIKit

final class APIListViewController: UIViewController {

    // MARK: Private properties
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: view.frame)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = 60.0
        table.delegate = self
        return table
    }()

    private var dataSource: UITableViewDiffableDataSource<String, APIListData>!
    private let data: [APIListData]

    // MARK: - Init
    init(data: [APIListData]) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "APIs"
        view.addSubview(tableView)
        setupData()
    }

    // MARK: - Private functions
    private func setupData() {
        dataSource = UITableViewDiffableDataSource<String, APIListData>(tableView: tableView) { tableView, _, data in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.text = data.name
            return cell
        }

        var snap = NSDiffableDataSourceSnapshot<String, APIListData>()
        snap.appendSections(["main"])
        snap.appendItems(data)
        dataSource.apply(snap, animatingDifferences: true)
    }
}

// MARK: -
extension APIListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let apiData = dataSource.itemIdentifier(for: indexPath) else { return }

        let view = ResourceViewController(apiData: apiData)
        navigationController?.pushViewController(view, animated: true)
    }
}
