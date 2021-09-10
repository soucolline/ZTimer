//
//  MoreViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 7/30/21.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit

class MoreViewController: UITableViewController {

    private let timerTheme = Theme.getTimerTheme()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = R.string.localizable.more()
    }
}

extension MoreViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 1
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let infoDictionnary = Bundle.main.infoDictionary!
                let version = infoDictionnary["CFBundleShortVersionString"]
                cell.textLabel?.text = R.string.localizable.version()
                cell.detailTextLabel?.text = version as? String
                cell.imageView?.image = R.image.version()
                cell.accessoryType = .none
                cell.selectionStyle = .none
            default: ()
            }

        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = R.string.localizable.theme()
                cell.detailTextLabel?.text = self.timerTheme.getMyThemeName()
                cell.imageView?.image = R.image.theme()

            case 1:
                cell.textLabel?.text = R.string.localizable.setting()
                cell.detailTextLabel?.text = ""
                cell.imageView?.image = R.image.setting()
            default: ()
            }

        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = R.string.localizable.license()
                cell.detailTextLabel?.text = ""
                cell.imageView?.image = R.image.license()
            default: ()
            }
        default:()
        }

        cell.detailTextLabel?.textColor = self.timerTheme.getTintColor()
        cell.textLabel?.font = R.font.regular(size: 18)
        cell.detailTextLabel?.font = R.font.light(size: 18)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)

        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0: self.pushToThemeView()
            case 1: self.pushToSettingView()
            default: ()
            }
        case 2:
            switch indexPath.row {
            case 0: self.pushToLicenseView()
            default: ()
            }
        default: ()
        }
    }

    private func pushToThemeView() {
        let themeViewController = self.storyboard!.instantiateViewController(identifier: "ThemeViewController")
        themeViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(themeViewController, animated: true)
    }

    private func pushToSettingView() {
        let settingViewController = self.storyboard!.instantiateViewController(identifier: "setting")
        settingViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(settingViewController, animated: true)
    }

    private func pushToLicenseView() {
        let licenseViewController = self.storyboard!.instantiateViewController(identifier: "LicenseViewController")
        licenseViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(licenseViewController, animated: true)
    }
}
