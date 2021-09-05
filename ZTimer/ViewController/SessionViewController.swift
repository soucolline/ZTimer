//
//  SessionViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 8/1/21.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit

class SessionViewController: UITableViewController {
    private var sessionManager: SessionManager!
    private var buttons: [UIBarButtonItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = Utils.getLocalizedString(from: "session")

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(backToStatsView))

        self.navigationController?.setToolbarHidden(false, animated: false)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.editButtonItem.action = #selector(editBtnPressed)
        self.buttons.append(self.editButtonItem)
        self.buttons.append(flexibleSpace)
        let newButton = UIBarButtonItem(
            title: Utils.getLocalizedString(from: "new session"),
            style: .plain,
            target: self,
            action: #selector(addNewSession)
        )
        self.buttons.append(newButton)
        self.setToolbarItems(self.buttons, animated: false)
        self.tableView.allowsSelectionDuringEditing = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.sessionManager = SessionManager.loadd()

        self.tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sessionManager?.save()
    }

    @objc private func addNewSession() {
        let newSessionViewController = self.storyboard!.instantiateViewController(identifier: "EditSessionViewController") as! EditSessionViewController
        newSessionViewController.navigationItem.title = Utils.getLocalizedString(from: "new session")
        newSessionViewController.isNew = true
        self.navigationController?.pushViewController(newSessionViewController, animated: true)
    }

    func editSession(indexPath: IndexPath) {
        let newSessionViewController = self.storyboard!.instantiateViewController(identifier: "EditSessionViewController") as! EditSessionViewController
        newSessionViewController.navigationItem.title = Utils.getLocalizedString(from: "rename session")
        newSessionViewController.isNew = false

        if indexPath.section == 0 {
            newSessionViewController.oldSessionName = self.sessionManager?.stickySessionArray[indexPath.row]
        } else {
            newSessionViewController.oldSessionName = self.sessionManager?.sessionArray[indexPath.row]
        }

        self.navigationController?.pushViewController(newSessionViewController, animated: true)
    }

    @objc private func editBtnPressed() {
        if self.isEditing {
            self.setEditing(false, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.tableView.reloadData()
            }
        } else {
            self.setEditing(true, animated: true)
        }
    }

    @objc private func backToStatsView() {
        self.dismiss(animated: true)
    }
}

extension SessionViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return Int(self.sessionManager!.stickySessionNum())
        case 1: return Int(self.sessionManager!.normalSessionNum())
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.accessoryType = .none
        cell.editingAccessoryType = .disclosureIndicator

        switch indexPath.section {
        case 0:
            let title = self.sessionManager?.stickySessionArray[indexPath.row]
            let session = SessionManager.loadSessionWithName(name: title!)
            let subTitle = String(format: "%@%d", Utils.getLocalizedString(from: "Number of solves: "), session.numberOfSolves())

            if indexPath.row == 0 {
                cell.textLabel?.text = Utils.getLocalizedString(from: title!)
                cell.detailTextLabel?.text = subTitle
                cell.imageView?.image = UIImage(named: "mainSession.png")
            } else {
                cell.textLabel?.text = title!
                cell.detailTextLabel?.text = subTitle
                cell.imageView?.image = UIImage(named: "sticky.png")
            }

            if title == self.sessionManager?.currentSessionName {
                cell.accessoryType = .checkmark
            }

        case 1:
            let title = self.sessionManager?.sessionArray[indexPath.row]
            let session = SessionManager.loadSessionWithName(name: title!)
            let subTitle = String(format: "%@%d", Utils.getLocalizedString(from: "Number of solves: "), session.numberOfSolves())
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = subTitle
            cell.imageView?.image = UIImage(named: "session.png")

            if title == self.sessionManager?.currentSessionName {
                cell.accessoryType = .checkmark
            }

        default: ()
        }

        cell.textLabel?.font = Theme.font(style: .regular, iphoneSize: 18.0, ipadSize: 18.0)
        cell.detailTextLabel?.font = Theme.font(style: .light, iphoneSize: 12.0, ipadSize: 12.0)
        cell.detailTextLabel?.textColor = .darkGray

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return false
            } else {
                return true
            }
        default: return true
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                let deleteSession = self.sessionManager?.stickySessionArray[indexPath.row]
                if deleteSession == self.sessionManager?.currentSessionName {
                    self.sessionManager?.currentSessionName = "main session"
                }
                self.sessionManager?.removeStickySession(at: indexPath.row)

            case 1:
                let deleteSession = self.sessionManager?.sessionArray[indexPath.row]
                if deleteSession == self.sessionManager?.currentSessionName {
                    self.sessionManager?.currentSessionName = "main session"
                }
                self.sessionManager?.removeNormalSession(at: indexPath.row)

            default: ()
            }

            tableView.deleteRows(at: [indexPath], with: .right)
            self.sessionManager?.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // TODO : check what to do with move 
        //self.sessionManager?.moveObject(from: sourceIndexPath, to: destinationIndexPath)
        self.sessionManager?.save()
    }

    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (sourceIndexPath.section == 0 && sourceIndexPath.row == 0) || (proposedDestinationIndexPath.section == 0 && proposedDestinationIndexPath.row == 0) {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return false
            } else {
                return true
            }

        default: return true
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tableView.isEditing {
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.selectionStyle = .none

            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    self.tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
                default: self.editSession(indexPath: indexPath)
                }
            default: self.editSession(indexPath: indexPath)
            }
        } else {
            var session = "main session"

            switch indexPath.section {
            case 0:
                session = self.sessionManager!.stickySessionArray[indexPath.row]
            case 1:
                session = self.sessionManager!.sessionArray[indexPath.row]
            default: ()
            }

            self.sessionManager?.currentSessionName = session
            self.tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
            self.sessionManager?.save()
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return Utils.getLocalizedString(from: "stickySessions")
        case 1: return Utils.getLocalizedString(from: "mySessions")
        default: return ""
        }
    }

}
