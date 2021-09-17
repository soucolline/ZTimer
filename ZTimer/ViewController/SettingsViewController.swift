//
//  SettingsViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 7/31/21.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    private var fTime = UILabel(frame: CGRect(x: 16, y: 25, width: 200, height: 15))
    private var timerTheme = Theme.getTimerTheme()
    private var sensCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = R.string.localizable.setting()

        fTime.font = R.font.light(size: 13)
        fTime.backgroundColor = UIColor.clear
        fTime.textColor = UIColor.darkGray
        let time = Settings().int(forKey: "freezeTime")
        fTime.text = String(format: "%0.1f s", Double(time) * 0.01)

        if fTime.text == "0.0 s" {
            fTime.text = fTime.text?.appending(R.string.localizable.no_other_gesture())
        }
    }
}

extension SettingsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 2
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("get cell")
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = R.string.localizable.wca_inspection()
                cell.detailTextLabel?.text = R.string.localizable.fifteen_sec()
                let wcaInsSwitch = UISwitch()
                wcaInsSwitch.addTarget(self, action: #selector(wcaSwitchAction), for: .valueChanged)

                wcaInsSwitch.setOn(Settings().bool(forKey: "wcaInspection"), animated: false)
                cell.accessoryView = wcaInsSwitch
                cell.selectionStyle = .none

            case 1:
                cell.textLabel?.text = R.string.localizable.knock_to_stop()
                cell.detailTextLabel?.text = R.string.localizable.knock_to_stop_detail()
                let knockSwitch = UISwitch()
                knockSwitch.addTarget(self, action: #selector(knockSwitchAction), for: .valueChanged)

                knockSwitch.setOn(Settings().bool(forKey: "knockToStop"), animated: false)
                cell.accessoryView = knockSwitch
                cell.selectionStyle = .none

            case 2:
                cell.textLabel?.text = R.string.localizable.sensitivity()
                cell.detailTextLabel?.text = ""
                let sensSlider = UISlider(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
                sensSlider.tintColor = self.timerTheme.getTintColor()
                sensSlider.minimumValue = 0
                sensSlider.maximumValue = 110
                sensSlider.addTarget(self, action: #selector(sensSliderChanged(sender:)), for: .valueChanged)
                var sens = Settings().int(forKey: "knockSensitivity")

                if !Settings().hasObject(forKey: "knockSensitivity") {
                    sens = 60
                    Settings().save(int: sens, forKey: "knockSensitivity")
                }
                sensSlider.value = Float(sens)

                cell.addSubview(fTime)
                cell.accessoryView = sensSlider
                cell.selectionStyle = .none

                if Settings().bool(forKey: "knockToStop") == false {
                    cell.isUserInteractionEnabled = false
                    cell.textLabel?.isEnabled = false
                    (cell.accessoryView as? UISwitch)?.isEnabled = false
                } else {
                    cell.isUserInteractionEnabled = true
                    cell.textLabel?.isEnabled = true
                    (cell.accessoryView as? UISwitch)?.isEnabled = true
                }

                cell.indentationLevel = 2
                cell.indentationWidth = 10
                self.sensCell = cell

            case 3:
                cell.textLabel?.text = R.string.localizable.start_freeze()
                cell.detailTextLabel?.text = " "
                let freezeTime = UISlider(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
                freezeTime.tintColor = self.timerTheme.getTintColor()
                freezeTime.minimumValue = 10
                freezeTime.maximumValue = 100
                freezeTime.addTarget(self, action: #selector(freezeTimeSliderChanged(sender:)), for: .valueChanged)

                let time = Settings().int(forKey: "freezeTime")
                freezeTime.value = Float(time)
                cell.addSubview(fTime)
                cell.accessoryView = freezeTime
                cell.selectionStyle = .none

            default: ()
            }

        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = R.string.localizable.newest_time_on()
                let solveOrders = [
                    R.string.localizable.bottom(),
                    R.string.localizable.top()
                ]

                let solveOrderSegment = UISegmentedControl(items: solveOrders)
                solveOrderSegment.tintColor = self.timerTheme.getTintColor()

                let order = Settings().int(forKey: "solveOrder")
                solveOrderSegment.selectedSegmentIndex = order
                solveOrderSegment.addTarget(self, action: #selector(solveOrderSegmentChange(sender:)), for: .valueChanged)
                cell.accessoryView = solveOrderSegment
                cell.selectionStyle = .none
                cell.detailTextLabel?.text = ""

            case 1:
                cell.textLabel?.text = R.string.localizable.solve_subtitle()
                let solveDetails = [
                    R.string.localizable.time(),
                    R.string.localizable.scr_str(),
                    R.string.localizable.type()
                ]

                let solveDetailSegment = UISegmentedControl(items: solveDetails)
                solveDetailSegment.tintColor = self.timerTheme.getTintColor()

                let detail = Settings().int(forKey: "solveDetailDisplay")
                solveDetailSegment.selectedSegmentIndex = detail
                solveDetailSegment.addTarget(self, action: #selector(solveDetailSegmentChange(sender:)), for: .valueChanged)
                cell.accessoryView = solveDetailSegment
                cell.selectionStyle = .none
                cell.detailTextLabel?.text = ""

            default: ()
            }
        default: ()
        }

        cell.textLabel?.font = R.font.regular(size: 18)
        cell.detailTextLabel?.font = R.font.light(size: 13)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0: return R.string.localizable.timing()
            case 1: return R.string.localizable.stats()
        default: return ""
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
            case 0: return R.string.localizable.timing_footer()
            case 1: return R.string.localizable.stats_footer()
        default: return ""
        }
    }

    @objc private func wcaSwitchAction(sender: UISwitch) {
        let switchbutton = sender
        let isButtonOn = switchbutton.isOn

        if isButtonOn {
            Settings().save(bool: true, forKey: "wcaInspection")
        } else {
            Settings().save(bool: false, forKey: "wcaInspection")
        }
    }

    @objc private func knockSwitchAction(sender: UISwitch) {
        let switchButton = sender
        let isButtonOn = switchButton.isOn

        if isButtonOn {
            Settings().save(bool: true, forKey: "knockToStop")
            sensCell.isUserInteractionEnabled = true
            sensCell.textLabel?.isEnabled = true
            (sensCell.accessoryView as? UISwitch)?.isEnabled = true
        } else {
            Settings().save(bool: false, forKey: "knockToStop")
            sensCell.isUserInteractionEnabled = false
            sensCell.textLabel?.isEnabled = false
            (sensCell.accessoryView as? UISwitch)?.isEnabled = false
        }
    }

    @objc private func sensSliderChanged(sender: UISlider) {
        let slider = sender
        let progressAsInt = Int(roundf(slider.value))
        Settings().save(int: progressAsInt, forKey: "knockSensitivity")
    }

    @objc private func freezeTimeSliderChanged(sender: UISlider) {
        let slider = sender
        let progressAsInt = Int(roundf(slider.value))
        fTime.text = String(format: "%0.1f s", Double(progressAsInt) * 0.01)

        if fTime.text == "0.0 s" {
            fTime.text = fTime.text?.appending(R.string.localizable.no_other_gesture())
        }

        Settings().save(int: progressAsInt, forKey: "freezeTime")
    }

    @objc private func solveOrderSegmentChange(sender: UISegmentedControl) {
        let segCtrl = sender
        Settings().save(int: segCtrl.selectedSegmentIndex, forKey: "solveOrder")
    }

    @objc private func solveDetailSegmentChange(sender: UISegmentedControl) {
        let segCtrl = sender
        Settings().save(int: segCtrl.selectedSegmentIndex, forKey: "solveDetailDisplay")
    }
}
