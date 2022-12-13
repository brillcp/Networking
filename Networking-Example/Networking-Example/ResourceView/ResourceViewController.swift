//
//  ResourceViewController.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-14.
//

import UIKit

final class ResourceViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: view.frame)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = 60.0
        table.delegate = self
        return table
    }()

    private var dataSource: UITableViewDiffableDataSource<String, AnyHashable>!
    private let data: [AnyHashable]

    // MARK: - Init
    init(data: [AnyHashable]) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "navTitle"
        view.addSubview(tableView)
        setupData()
    }

    // MARK: - Private functions
    private func setupData() {
        dataSource = UITableViewDiffableDataSource<String, AnyHashable>(tableView: tableView) { tableView, _, data in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.accessoryType = .disclosureIndicator

            switch data {
            case let data as APIData:
                cell?.textLabel?.text = data.name
                
            case let data as Endpoints:
                cell?.textLabel?.text = data.rawValue
            default:
                break
            }
            return cell
        }

        var snap = NSDiffableDataSourceSnapshot<String, AnyHashable>()
        snap.appendSections(["main"])
        snap.appendItems(data)
        dataSource.apply(snap, animatingDifferences: true)
    }
}

// MARK: -
extension ResourceViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let data = dataSource.itemIdentifier(for: indexPath) else { return }
        switch data {
        case _ as APIData:
            let items: [Endpoints] = [.git, .user]
            let view = ResourceViewController(data: items)
            navigationController?.pushViewController(view, animated: true)
            
        case let endpoints as Endpoints:
            print(endpoints.rawValue)
        default:
            break
        }
    }
}

enum Endpoints: String, CaseIterable {
    typealias RawValue = String
    
    case git
    case user
    case home
}
