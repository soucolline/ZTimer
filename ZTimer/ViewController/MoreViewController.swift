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

        self.navigationItem.title = Utils.getLocalizedString(from: "More")
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
                cell.textLabel?.text = Utils.getLocalizedString(from: "version") as String
                cell.detailTextLabel?.text = version as? String
                cell.imageView?.image = UIImage(named: "version.png")
                cell.accessoryType = .none
                cell.selectionStyle = .none
            default: ()
            }

        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = Utils.getLocalizedString(from: "theme")
                cell.detailTextLabel?.text = self.timerTheme.getMyThemeName()
                cell.imageView?.image = UIImage(named: "theme.png")

            case 1:
                cell.textLabel?.text = Utils.getLocalizedString(from: "setting")
                cell.detailTextLabel?.text = ""
                cell.imageView?.image = UIImage(named: "setting.png")
            default: ()
            }

        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = Utils.getLocalizedString(from: "license")
                cell.detailTextLabel?.text = ""
                cell.imageView?.image = UIImage(named: "license.png")
            default: ()
            }
        default:()
        }

        cell.detailTextLabel?.textColor = self.timerTheme.getTintColor()
        cell.textLabel?.font = Theme.font(style: .regular, iphoneSize: 18.0, ipadSize: 18.0)
        cell.detailTextLabel?.font = Theme.font(style: .light, iphoneSize: 18.0, ipadSize: 18.0)

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
