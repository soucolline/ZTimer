//
//  HelpViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 7/30/21.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit

class HelpViewController: UITableViewController {
    private let helps = [
        R.string.localizable.one_finger_long_press(),
        R.string.localizable.swipe_right(),
        R.string.localizable.swipe_left(),
        R.string.localizable.one_finger_double_tap(),
        R.string.localizable.two_fingers_two_tap(),
        R.string.localizable.two_fingers_swipe_up(),
        R.string.localizable.swipe_down()
    ]

    private let helpsTodo = [
        R.string.localizable.start_timer(),
        R.string.localizable.new_scramble(),
        R.string.localizable.delete_last_solve(),
        R.string.localizable.choose_penalty(),
        R.string.localizable.reset_session(),
        R.string.localizable.choose_scramble_type(),
        R.string.localizable.manually_add_solve()
    ]

    private let helpsImage = [
        R.image.onehold(),
        R.image.onefr(),
        R.image.onefl(),
        R.image.onef2t(),
        R.image.twof2t(),
        R.image.twofup(),
        R.image.onefd()
    ]

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = R.string.localizable.gesture_help()
        self.tabBarController?.tabBar.items?[2].badgeValue = nil
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
        cell.textLabel?.font = R.font.regular(size: 19)
        cell.detailTextLabel?.font = R.font.light(size: 14)
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
