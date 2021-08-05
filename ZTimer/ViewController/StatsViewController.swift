//
//  StatsViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 05/08/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit

class StatsViewController: UITableViewController {
    private let timerTheme = Theme.getTimerTheme()
    private var stats: [OneStat] = []

    private var session: CHTSession {
        CHTSessionManager.load().loadCurrentSession()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = Utils.getLocalizedString(from: "Stats")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "sessions.png"), style: .plain, target: self, action: #selector(presentSessionView))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.reload()
    }

    private func reload() {
        //self.session = CHTSessionManager.load().loadCurrentSession()
        let numberOfSolves = self.session.numberOfSolves
        self.tabBarController?.tabBar.items?[0].badgeValue = String(format: "%d", self.session.numberOfSolves)
        self.stats.removeAll()
        let numOfSolves = OneStat(statType: "Number of solves: ", statValue: String(format: "%d", self.session.numberOfSolves))
        self.stats.append(numOfSolves)

        if numberOfSolves > 0 {
            let bestTime = OneStat(statType: "Best time: ", statValue: self.session.bestSolve().toString())
            let worstTime = OneStat(statType: "Worst time: ", statValue: self.session.worstSolve().toString())
            let sessionAvg = OneStat(statType: "Session Average: ", statValue: self.session.sessionAvg().toString())
            let sessionMean = OneStat(statType: "Session Mean: ", statValue: self.session.sessionMean().toString())

            self.stats.append(bestTime)
            self.stats.append(worstTime)
            self.stats.append(sessionAvg)
            self.stats.append(sessionMean)

            if numberOfSolves >= 5 {
                let current5 = OneStat(statType: "Current average of 5: ", statValue: self.session.currentAvg(of: 5).toString())
                let best5 = OneStat(statType: "Best average of 5: ", statValue: self.session.bestAvg(of: 5).toString())

                self.stats.append(current5)
                self.stats.append(best5)

                if numberOfSolves >= 12 {
                    let current12 = OneStat(statType: "Current average of 12: ", statValue: self.session.currentAvg(of: 12).toString())
                    let best12 = OneStat(statType: "Best average of 12: ", statValue: self.session.bestAvg(of: 12).toString())

                    self.stats.append(current12)
                    self.stats.append(best12)

                    if numberOfSolves >= 100 {
                        let current100 = OneStat(statType: "Current average of 100: ", statValue: self.session.currentAvg(of: 100).toString())
                        let best100 = OneStat(statType: "Best average of 100: ", statValue: self.session.bestAvg(of: 100).toString())

                        self.stats.append(current100)
                        self.stats.append(best100)
                    }
                }
            }
        }

        self.tableView.reloadData()
    }

    @objc private func presentSessionView() {
        let vc = self.storyboard!.instantiateViewController(identifier: "SessionViewController")
        self.present(vc, animated: true)
    }
}

extension StatsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.stats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let oneStats = self.stats[indexPath.row]

        cell.textLabel?.text = Utils.getLocalizedString(from: oneStats.statType)
        cell.detailTextLabel?.text = oneStats.statValue

        if indexPath.row == 0 {
            cell.selectionStyle = .none
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }

        cell.detailTextLabel?.textColor = self.timerTheme.getTintColor()
        cell.textLabel?.font = Theme.font(style: .regular, iphoneSize: 18.0, ipadSize: 18.0)
        cell.detailTextLabel?.font = Theme.font(style: .light, iphoneSize: 18.0, ipadSize: 18.0)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.session.sessionName == "main session" {
            return Utils.getLocalizedString(from: "main session")
        } else {
            return self.session.sessionName
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        let row = indexPath.row

        if row != 0 {
            if row == 1 || row == 2 {
                let solveDetailViewController = self.storyboard!.instantiateViewController(identifier: "SolveDetailViewController") as! SolveDetailViewController
                solveDetailViewController.hidesBottomBarWhenPushed = true

                switch row {
                    case 1: solveDetailViewController.solve = self.session.bestSolve()
                    case 2: solveDetailViewController.solve = self.session.worstSolve()
                    default: ()
                }

                self.navigationController?.pushViewController(solveDetailViewController, animated: true)
            } else {
                let statDetailViewController = self.storyboard!.instantiateViewController(identifier: "StatDetailViewController") as! StatDetailViewController
                statDetailViewController.hidesBottomBarWhenPushed = true
                statDetailViewController.session = self.session
                statDetailViewController.stat = self.stats[row]
                statDetailViewController.row = row

                switch row {
                    case 3, 4: statDetailViewController.statDetails = self.session.getAllSolves() as! [CHTSolve]
                    case 5: statDetailViewController.statDetails = self.session.getCurrent(5) as! [CHTSolve]
                    case 6: statDetailViewController.statDetails = self.session.getBest(5) as! [CHTSolve]
                    case 7: statDetailViewController.statDetails = self.session.getCurrent(12) as! [CHTSolve]
                    case 8: statDetailViewController.statDetails = self.session.getBest(12) as! [CHTSolve]
                    case 9: statDetailViewController.statDetails = self.session.getCurrent(100) as! [CHTSolve]
                    case 10: statDetailViewController.statDetails = self.session.getBest(100) as! [CHTSolve]
                    default: ()
                }

                self.navigationController?.pushViewController(statDetailViewController, animated: true)
            }
        }
    }
}
