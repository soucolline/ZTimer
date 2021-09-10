//
//  ThemeViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 7/28/21.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import Foundation
import UIKit

class ThemeViewController: UITableViewController {
    private var themes: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = R.string.localizable.theme()
        self.themes = Theme.getAllTheme()
    }
}

extension ThemeViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.themes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let theme = Theme.initWithTheme(theme: ThemeValue(rawValue: self.themes[indexPath.row])!)

        cell.textLabel?.text = theme.getMyThemeName()
        cell.textLabel?.textColor = theme.textColor

        if theme.getMyTheme() == Theme.getTimerTheme().getMyTheme() {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        cell.textLabel?.font = R.font.regular(size: 18)

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Theme.getColorFromTheme(theme: ThemeValue(rawValue: self.themes[indexPath.row])!)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        R.string.localizable.select_theme()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)

        let theme = Theme.initWithTheme(theme: ThemeValue(rawValue: self.themes[indexPath.row])!)
        theme.save()
        theme.setNavigationControllerTheme()
        theme.setNavigationControllerTheme(controller: self.navigationController!)

        self.tabBarController?.tabBar.barTintColor = theme.tabBarColor
        self.tableView.reloadData()
    }
}
