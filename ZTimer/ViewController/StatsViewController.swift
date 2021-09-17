//
//  StatsViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 05/08/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit

class StatsViewController: UITableViewController {
    private var stats: [OneStat] = []

    private var session: Session {
        SessionManager.loadd().loadCurrentSession()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = R.string.localizable.stats()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.sessions(), style: .plain, target: self, action: #selector(presentSessionView))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.reload()
    }

    private func reload() {
        //self.session = CHTSessionManager.load().loadCurrentSession()
        let numberOfSolves = self.session.numberOfSolves()
        self.tabBarController?.tabBar.items?[0].badgeValue = String(format: "%d", self.session.numberOfSolves())
        self.stats.removeAll()
        let numOfSolves = OneStat(statType: .numberOfSolves, statValue: String(format: "%d", self.session.numberOfSolves()))
        self.stats.append(numOfSolves)

        if numberOfSolves > 0 {
            let bestTime = OneStat(statType: .bestTime, statValue: self.session.bestSolve().toString())
            let worstTime = OneStat(statType: .worstTime, statValue: self.session.worstSolve().toString())
            let sessionAvg = OneStat(statType: .sessionAverage, statValue: self.session.sessionAvg().toString())
            let sessionMean = OneStat(statType: .sessionMean, statValue: self.session.sessionMean().toString())

            self.stats.append(bestTime)
            self.stats.append(worstTime)
            self.stats.append(sessionAvg)
            self.stats.append(sessionMean)

            if numberOfSolves >= 5 {
                let current5 = OneStat(statType: .currentAvg5, statValue: self.session.currentAvgOf(num: 5).toString())
                let best5 = OneStat(statType: .bestAvg5, statValue: self.session.bestAvgOf(num: 5).toString())

                self.stats.append(current5)
                self.stats.append(best5)

                if numberOfSolves >= 12 {
                    let current12 = OneStat(statType: .currentAvg12, statValue: self.session.currentAvgOf(num: 12).toString())
                    let best12 = OneStat(statType: .bestAvg12, statValue: self.session.bestAvgOf(num: 12).toString())

                    self.stats.append(current12)
                    self.stats.append(best12)

                    if numberOfSolves >= 100 {
                        let current100 = OneStat(statType: .currentAvg100, statValue: self.session.currentAvgOf(num: 100).toString())
                        let best100 = OneStat(statType: .bestAvg100, statValue: self.session.bestAvgOf(num: 100).toString())

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

        cell.textLabel?.text = oneStats.localizedStatType()
        cell.detailTextLabel?.text = oneStats.statValue

        if indexPath.row == 0 {
            cell.selectionStyle = .none
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }

        cell.textLabel?.font = R.font.regular(size: 18)
        cell.detailTextLabel?.font = R.font.light(size: 18)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.session.sessionName == "main session" {
            return R.string.localizable.main_session()
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
                    case 3, 4: statDetailViewController.statDetails = self.session.getAllSolves()
                    case 5: statDetailViewController.statDetails = self.session.getCurrent(solves: 5)
                    case 6: statDetailViewController.statDetails = self.session.getBest(solves: 5)
                    case 7: statDetailViewController.statDetails = self.session.getCurrent(solves: 12)
                    case 8: statDetailViewController.statDetails = self.session.getBest(solves: 12)
                    case 9: statDetailViewController.statDetails = self.session.getCurrent(solves: 100)
                    case 10: statDetailViewController.statDetails = self.session.getBest(solves: 100)
                    default: ()
                }

                self.navigationController?.pushViewController(statDetailViewController, animated: true)
            }
        }
    }
}
