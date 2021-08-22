//
//  SolveDetailViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 8/1/21.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit

class SolveDetailViewController: UITableViewController {
    @objc var solve: Solve!
    private var shareSheet: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = Utils.getLocalizedString(from: "scramble")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(displayActionSheet)
        )
    }

    @objc private func displayActionSheet() {
        self.shareSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        self.shareSheet.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "copy scramble"), style: .default, handler: { _ in
            self.copyToPaste()
        }))

        self.shareSheet.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "cancel"), style: .cancel))

        self.present(self.shareSheet, animated: true)
    }

    private func copyToPaste() {
        let textToPaste = self.solve.scramble.scramble
        let pasteboard = UIPasteboard.general
        pasteboard.string = textToPaste

        let alertController = UIAlertController(
            title: nil,
            message: Utils.getLocalizedString(from: "copy scramble success"),
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "OK"), style: .cancel))
        self.present(alertController, animated: true)
    }
}

extension SolveDetailViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.font = Theme.font(style: .bold, iphoneSize: 35.0, ipadSize: 35.0)
            cell.detailTextLabel?.font = Theme.font(style: .light, iphoneSize: 17.0, ipadSize: 17.0)
            cell.textLabel?.text = self.solve.toString()

            if self.solve.penalty != .noPenalty {
                cell.detailTextLabel?.text = String(format: "(%@)", Utils.convertTimeFromMsecondToString(msecond: Int(self.solve.timeBeforePenalty)))
            } else {
                cell.detailTextLabel?.text = ""
            }

        case 1:
            cell.textLabel?.font = Theme.font(style: .regular, iphoneSize: 20.0, ipadSize: 20.0)
            cell.detailTextLabel?.font = Theme.font(style: .light, iphoneSize: 17.0, ipadSize: 17.0)
            cell.textLabel?.text = self.solve.scramble.scrType
            cell.detailTextLabel?.text = self.solve.scramble.scrSubType

        case 2:
            cell.textLabel?.font = Theme.font(style: .regular, iphoneSize: 17.0, ipadSize: 17.0)
            cell.detailTextLabel?.font = Theme.font(style: .light, iphoneSize: 17.0, ipadSize: 17.0)
            cell.textLabel?.text = self.solve.getTimeStampString()
            cell.detailTextLabel?.text = ""

        case 3:
            cell.textLabel?.font = Theme.font(style: .regular, iphoneSize: 13.0, ipadSize: 13.0 + 4.0)
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = ""
            cell.textLabel?.text = self.solve.scramble.scramble

        default: ()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text: String

        switch indexPath.row {
        case 0: return 55.0
        case 1, 2: return 44.0
        case 3:
            text = self.solve.scramble.scramble
            return Utils().heightOfContent(content: text, font: Theme.font(style: .regular, iphoneSize: 13.0, ipadSize: 13.0 + 4))
        default: return 44.0
        }
    }
}
