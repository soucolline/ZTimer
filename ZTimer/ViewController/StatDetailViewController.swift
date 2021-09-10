//
//  StatDetailViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 8/1/21.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit

class StatDetailViewController: UITableViewController {
    private var best: Solve!
    private var worst: Solve!
    private var timerTheme = Theme.getTimerTheme()
    @objc var session: Session!
    @objc var stat: OneStat!
    @objc var row: Int = 0
    @objc var statDetails: [Solve] = []
    private var solveDetailDisplay: Int!

    private var solveOrder: Int {
        Settings().int(forKey: "solveOrder")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = R.string.localizable.detail()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.getBestAndWorst()
        self.tableView.reloadData()
        self.solveDetailDisplay = Settings().int(forKey: "solveDetailDisplay")
    }

    private func reload() {
        self.statDetails.removeAll()

        switch self.row {
        case 3:
            if self.session.numberOfSolves() == 0 {
                self.navigationController?.popViewController(animated: true)
                return
            }

            self.statDetails = self.session.getAllSolves()
            self.stat.statValue = self.session.sessionAvg().toString()

        case 4:
            if self.session.numberOfSolves() == 0 {
                self.navigationController?.popViewController(animated: true)
                return
            }

            self.statDetails = self.session.getAllSolves()
            self.stat.statValue = self.session.sessionMean().toString()

        case 5:
            if self.session.numberOfSolves() < 5 {
                self.navigationController?.popViewController(animated: true)
                return
            }

            self.statDetails = self.session.getCurrent(solves: 5)
            self.stat.statValue = self.session.currentAvgOf(num: 5).toString()

        case 6:
            if self.session.numberOfSolves() < 5 {
                self.navigationController?.popViewController(animated: true)
                return
            }

            self.statDetails = self.session.getBest(solves: 5)
            self.stat.statValue = self.session.bestAvgOf(num: 5).toString()

        case 7:
            if self.session.numberOfSolves() < 12 {
                self.navigationController?.popViewController(animated: true)
                return
            }

            self.statDetails = self.session.getCurrent(solves: 12)
            self.stat.statValue = self.session.currentAvgOf(num: 12).toString()

        case 8:
            if self.session.numberOfSolves() < 12 {
                self.navigationController?.popViewController(animated: true)
                return
            }

            self.statDetails = self.session.getBest(solves: 12)
            self.stat.statValue = self.session.bestAvgOf(num: 12).toString()

        case 9:
            if self.session.numberOfSolves() < 100 {
                self.navigationController?.popViewController(animated: true)
                return
            }

            self.statDetails = self.session.getCurrent(solves: 100)
            self.stat.statValue = self.session.currentAvgOf(num: 100).toString()

        case 10:
            if self.session.numberOfSolves() < 100 {
                self.navigationController?.popViewController(animated: true)
                return
            }

            self.statDetails = self.session.getBest(solves: 100)
            self.stat.statValue = self.session.bestAvgOf(num: 100).toString()

        default: self.navigationController?.popViewController(animated: true)
        }

        self.getBestAndWorst()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.reloadData()
        }
    }

    private func getBestAndWorst() {
        self.best = self.statDetails.last
        self.worst = self.statDetails.last

        for time in self.statDetails {
            if time.timeAfterPenalty() > self.worst.timeAfterPenalty() {
                self.worst = time
            }

            if time.timeAfterPenalty() < self.best.timeAfterPenalty() {
                self.best = time
            }
        }
    }

    @objc private func solveOrderSegmentChange(sender: UISegmentedControl) {
        let segCtrl = sender
        Settings().save(int: segCtrl.selectedSegmentIndex, forKey: "solveOrder")
        self.reload()
    }
}

extension StatDetailViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return self.statDetails.count
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.textLabel?.text = self.stat.localizedStatType()
                cell.detailTextLabel?.text = self.stat.statValue
                cell.selectionStyle = .none
                let solveOrders = ["↓", "↑"]

                let solveOrderSegment = UISegmentedControl(items: solveOrders)
                solveOrderSegment.tintColor = self.timerTheme.getTintColor()
                let order = Settings().int(forKey: "solveOrder")
                solveOrderSegment.selectedSegmentIndex = order
                solveOrderSegment.addTarget(self, action: #selector(solveOrderSegmentChange(sender:)), for: .valueChanged)
                cell.accessoryView = solveOrderSegment
                cell.selectionStyle = .none
            } else {
                cell.accessoryView = nil
                cell.accessoryType = .none
            }

        case 1:
            let solve: Solve

            if self.solveOrder == 1 {
                solve = self.statDetails[self.statDetails.count - 1 - indexPath.row]
            } else {
                solve = self.statDetails[indexPath.row]
            }

            if solve == self.best || solve == self.worst {
                cell.textLabel?.text = String(format: "( %@ )", solve.toString())
            } else {
                cell.textLabel?.text = solve.toString()
            }

            switch solveDetailDisplay {
            case 0:
                cell.detailTextLabel?.text = solve.getTimeStampString()
            case 1:
                cell.detailTextLabel?.text = solve.scramble.scramble
            case 2:
                cell.detailTextLabel?.text = String(format: "%@ %@", solve.scramble.scrType, solve.scramble.scrSubType)
            default:
                cell.detailTextLabel?.text = solve.getTimeStampString()
            }

            cell.selectionStyle = .gray
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator

        default: ()
        }

        cell.textLabel?.font = R.font.regular(size: 18)
        cell.detailTextLabel?.font = R.font.light(size: 12)
        cell.detailTextLabel?.textColor = .darkGray

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row % 2 == 1 {
                cell.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            } else {
                cell.backgroundColor = .white
            }
        } else {
            cell.backgroundColor = .white
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if self.session.sessionName == "main session" {
                return R.string.localizable.main_session()
            } else {
                return self.session.sessionName
            }

        case 1:
            return R.string.localizable.solve_list()

        default: return ""
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let solve: Solve

        if self.solveOrder == 1 {
            solve = statDetails[self.statDetails.count - 1 - indexPath.row]
        } else {
            solve = self.statDetails[indexPath.row]
        }

        self.session.removeSolve(aSolve: solve)
        self.statDetails.remove(at: indexPath.row)
        SessionManager.saveSession(session: self.session)
        tableView.deleteRows(at: [indexPath], with: .middle)

        self.tabBarController?.tabBar.items?[0].badgeValue = String(format: "%d", self.session.numberOfSolves())
        self.reload()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)

        if indexPath.section == 1 {
            let solve: Solve

            if self.solveOrder == 1 {
                solve = self.statDetails[self.statDetails.count - 1 - indexPath.row]
            } else {
                solve = self.statDetails[indexPath.row]
            }

            let solveDetailViewController = self.storyboard!.instantiateViewController(identifier: "SolveDetailViewController") as! SolveDetailViewController
            solveDetailViewController.hidesBottomBarWhenPushed = true
            solveDetailViewController.solve = solve

            self.navigationController?.pushViewController(solveDetailViewController, animated: true)
        }
    }
}
