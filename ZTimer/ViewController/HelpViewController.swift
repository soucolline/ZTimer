//
//  HelpViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 7/30/21.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit

class HelpViewController: UITableViewController {
    private var timerTheme: Theme?

    private let helps = [
        Utils.getLocalizedString(from: "1fhold"),
        Utils.getLocalizedString(from: "sr"),
        Utils.getLocalizedString(from: "sl"),
        Utils.getLocalizedString(from: "1f2t"),
        Utils.getLocalizedString(from: "2f2t"),
        Utils.getLocalizedString(from: "2fup"),
        Utils.getLocalizedString(from: "1fd")
    ]

    private let helpsTodo = [
        Utils.getLocalizedString(from: "1fholdto"),
        Utils.getLocalizedString(from: "srto"),
        Utils.getLocalizedString(from: "slto"),
        Utils.getLocalizedString(from: "1f2tto"),
        Utils.getLocalizedString(from: "2f2tto"),
        Utils.getLocalizedString(from: "2fupto"),
        Utils.getLocalizedString(from: "1fdto")
    ]

    private let helpsImage = [
        UIImage(named: "1hold.png"),
        UIImage(named: "1fr.png"),
        UIImage(named: "1fl.png"),
        UIImage(named: "1f2t.png"),
        UIImage(named: "2f2t.png"),
        UIImage(named: "2fup.png"),
        UIImage(named: "1fd.png")
    ]

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = Utils.getLocalizedString(from: "Gestures Help")
        self.tabBarController?.tabBar.items?[2].badgeValue = nil
        self.timerTheme = Theme.getTimerTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.becomeFirstResponder()
        let myApp = UIApplication.shared

        if self.timerTheme?.getMyTheme() == .white {
            myApp.setStatusBarStyle(.default, animated: true)
        } else {
            myApp.setStatusBarStyle(.lightContent, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.resignFirstResponder()
        super.viewWillDisappear(animated)
    }
}

extension HelpViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.helps.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = self.helpsTodo[indexPath.row]
        cell.detailTextLabel?.text = self.helps[indexPath.row]
        cell.imageView?.image = self.helpsImage[indexPath.row]
        cell.textLabel?.font = Theme.font(style: .regular, iphoneSize: 19.0, ipadSize: 22.0)
        cell.detailTextLabel?.font = Theme.font(style: .light, iphoneSize: 14.0, ipadSize: 15.0)
        cell.detailTextLabel?.textColor = .darkGray

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        indexPath.row
    }
}
