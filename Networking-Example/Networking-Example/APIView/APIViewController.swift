//
//  ViewController.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-13.
//

import UIKit

final class APIViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: view.frame)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = 60.0
        table.delegate = self
        return table
    }()

    private var dataSource: UITableViewDiffableDataSource<String, APIData>!

    private let data: [APIData] = [
        APIData(name: "Github API", url: ""),
        APIData(name: "PokeAPI", url: ""),
        APIData(name: "MovieAPI", url: ""),
        APIData(name: "Other", url: ""),
    ]

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "APIs"
        view.addSubview(tableView)
        setupData()
    }

    // MARK: - Private functions
    private func setupData() {
        dataSource = UITableViewDiffableDataSource<String, APIData>(tableView: tableView) { tableView, _, data in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.text = data.name
            return cell
        }

        var snap = NSDiffableDataSourceSnapshot<String, APIData>()
        snap.appendSections(["main"])
        snap.appendItems(data)
        dataSource.apply(snap, animatingDifferences: true)
    }
}

// MARK: -
extension APIViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let data: [APIData] = [
            APIData(name: "Github API", url: ""),
            APIData(name: "PokeAPI", url: ""),
            APIData(name: "MovieAPI", url: ""),
            APIData(name: "Other", url: ""),
        ]
        let view = ResourceViewController(data: data)
        navigationController?.pushViewController(view, animated: true)
    }
}
