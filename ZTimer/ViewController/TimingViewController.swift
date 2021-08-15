//
//  TimingViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 06/08/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit
import CoreMotion

class TimingViewController: UIViewController {
    @IBOutlet private var scrambleLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!

    enum TimerStatus: Int {
        case idle = 0
        case freeze
        case ready
        case timing
        case inspect
    }

    private var myTimer: Timer!
    private var timerStatus: TimerStatus!
    private var time: Int!
    private var longPressGesture: UILongPressGestureRecognizer!
    private var timeWhenTimerStart: Int!
    private var session: CHTSession = SessionManager.loadd().loadCurrentSession()
    private var timerTheme = Theme.getTimerTheme()
    private let scrambler = CHTScrambler()
    private var thisScramble: Scramble!
    private var nextScramble: Scramble!
    private var inspectionTimer: Timer?
    private var inspectionOverTimeTimer: Timer!
    private var motionManager: CMMotionManager!

    private var wcaInspection: Bool!
    private var inspectionBegin: Bool!
    private var plus2 = false
    private var scrType: Int!
    private var scrSubType: Int!
    private var oldScrType: Int!
    private var oldScrSubType: Int!
    private var solvedTimes: Int!
    private var threshold: Int!
    private var knockToStop: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()

        let myApp = UIApplication.shared
        myApp.isIdleTimerDisabled = true
        myApp.setStatusBarHidden(false, with: .none)

        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(startTimer(sender:)))
        self.longPressGesture.allowableMovement = 50
        self.longPressGesture.minimumPressDuration = Double(Settings().getFreezeTime()) * 0.01
        self.view.addGestureRecognizer(self.longPressGesture)
        self.setupGestures()
        self.timerStatus = .idle

        self.tabBarController?.tabBar.items?[0].title = Utils.getLocalizedString(from: "Timing")
        self.tabBarController?.tabBar.items?[1].title = Utils.getLocalizedString(from: "Stats")
        self.tabBarController?.tabBar.items?[2].title = Utils.getLocalizedString(from: "Help")
        self.tabBarController?.tabBar.items?[3].title = Utils.getLocalizedString(from: "More")

        scrType = Int(self.session.currentType)
        scrSubType = Int(self.session.currentSubType)
        oldScrType = scrType
        oldScrSubType = scrSubType

        print("Current scramble type \(String(describing: scrType)) \(String(describing: scrSubType))")
        self.scrambler.initSq1()
        self.changeScramble()
        self.scrambleLabel.font = Theme.font(style: .light, iphoneSize: 20.0, ipadSize: 40.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTheme()
        self.session = SessionManager.loadd().loadCurrentSession()
        self.tabBarItem.badgeValue = String(format: "%d", self.session.numberOfSolves)

        if self.session.currentType != oldScrType || self.session.currentSubType != oldScrSubType {
            self.changeScramble()
            oldScrType = Int(self.session.currentType)
            oldScrSubType = Int(self.session.currentSubType)
        }

        wcaInspection = Settings().bool(forKey: "wcaInspection")
        solvedTimes = Settings().int(forKey: "solvedTimes")
        knockToStop = Settings().bool(forKey: "knockToStop")
        threshold = Settings().int(forKey: "knockSensitivity")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.longPressGesture.minimumPressDuration = Double(Settings().getFreezeTime()) * 0.01
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SessionManager.saveSession(session: self.session)
        self.perform(#selector(stopTimer))
    }

    private func setTheme() {
        self.timerTheme = Theme.getTimerTheme()
        self.timerTheme.setNavigationControllerTheme()
        self.view.backgroundColor = self.timerTheme.backgroundColor
        self.tabBarController?.tabBar.barTintColor = self.timerTheme.tabBarColor
        self.scrambleLabel.textColor = self.timerTheme.textColor
        self.timeLabel.textColor = self.timerTheme.textColor
    }

    private func startCoreMotion() {
        if knockToStop {
            self.motionManager = CMMotionManager()
            self.motionManager.gyroUpdateInterval = 0.01

            let tolerance = 150 - threshold
            self.motionManager.startGyroUpdates(to: OperationQueue.current!) { gyroData, error in
                self.noticeRotationData(rotation: gyroData!.rotationRate, tolerance: tolerance)
            }
        }
    }

    private func stopCoreMotion() {
        if self.motionManager != nil {
            self.motionManager.stopGyroUpdates()
        }
    }

    private func noticeRotationData(rotation: CMRotationRate, tolerance: Int) {
        let value = abs(rotation.x * 1000) + abs(rotation.y * 1000) + abs(rotation.z * 1000)

        if Int(value) > tolerance {
            self.stopTimer()
        }
    }

    private func setupGestures() {
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(deleteLastSolve(swipGesture:)))
        swipeGestureLeft.direction = .left
        swipeGestureLeft.require(toFail: self.longPressGesture)
        self.view.addGestureRecognizer(swipeGestureLeft)

        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(getNewScramble))
        swipeGestureRight.direction = .right
        swipeGestureRight.require(toFail: self.longPressGesture)
        self.view.addGestureRecognizer(swipeGestureRight)

        let swipeGestureUp = UISwipeGestureRecognizer(target: self, action: #selector(resetTimerStatus))
        swipeGestureUp.direction = .up
        swipeGestureUp.require(toFail: self.longPressGesture)
        self.view.addGestureRecognizer(swipeGestureUp)

        let swipeGestureDown = UISwipeGestureRecognizer(target: self, action: #selector(manuallyAddNewSolve))
        swipeGestureDown.direction = .down
        swipeGestureDown.require(toFail: self.longPressGesture)
        self.view.addGestureRecognizer(swipeGestureDown)

        let singleFingerDoubleTaps = UITapGestureRecognizer(target: self, action: #selector(addPenalty(tapGesture:)))
        singleFingerDoubleTaps.numberOfTapsRequired = 2
        singleFingerDoubleTaps.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(singleFingerDoubleTaps)

        let twoFingersDoubleTaps = UITapGestureRecognizer(target: self, action: #selector(resetSession(tapGesture:)))
        twoFingersDoubleTaps.numberOfTapsRequired = 2
        twoFingersDoubleTaps.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(twoFingersDoubleTaps)

        let twoFingersSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(chooseScrambleType))
        twoFingersSwipeUp.direction = .up
        twoFingersSwipeUp.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(twoFingersSwipeUp)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if self.timerStatus == .idle {
            self.timeLabel.textColor = .red
            self.timerStatus = .freeze
        } else if self.timerStatus == .timing {
            self.perform(#selector(stopTimer))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if self.timerStatus == .freeze {
            self.timerStatus = .idle
            self.timeLabel.textColor = self.timerTheme.textColor
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        if self.timerStatus == .freeze {
            self.timerStatus = .idle
            self.timeLabel.textColor = self.timerTheme.textColor
        }
    }

    @objc private func updateTime() {
        let timeNow = mach_absolute_time()
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        self.time = (Int(timeNow) - self.timeWhenTimerStart) * Int(info.numer) / Int(info.denom) / 1000000
        let timeToDisplay = Utils.convertTimeFromMsecondToString(msecond: self.time)
        self.timeLabel.text = timeToDisplay
    }

    @objc private func startTimer(sender: UILongPressGestureRecognizer) {
        if !wcaInspection {
            if sender.state == .began {
                if self.timerStatus == .freeze {
                    self.timeLabel.textColor = .green
                    self.timerStatus = .ready
                }
            } else if sender.state == .cancelled {
                self.timeLabel.textColor = self.timerTheme.textColor
                self.timerStatus = .idle
            } else if sender.state == .ended {
                if self.timerStatus == .ready {
                    self.timeLabel.textColor = self.timerTheme.textColor
                    self.timeLabel.text = "0.000"
                    self.timeWhenTimerStart = Int(mach_absolute_time())
                    self.time = 0
                    self.myTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                    self.timerStatus = .timing
                    self.startCoreMotion()
                }
            }
        } else {
            if inspectionBegin {
                if sender.state == .began {
                    if self.timerStatus == .inspect {
                        self.timeLabel.textColor = .green
                        self.timerStatus = .ready
                    }
                }

                if sender.state == .cancelled {
                    self.timeLabel.textColor = .red
                    self.timerStatus = .inspect
                } else if sender.state == .ended {
                    if self.timerStatus == .ready {
                        self.timeLabel.textColor = self.timerTheme.textColor
                        self.timeLabel.text = "0.000"
                        self.timeWhenTimerStart = Int(mach_absolute_time())
                        self.time = 0
                        self.myTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                        self.inspectionTimer?.invalidate()
                        self.timerStatus = .timing
                        inspectionBegin = false
                        self.startCoreMotion()
                    }
                }
            } else {
                if sender.state == .began {
                    if self.timerStatus == .freeze {
                        self.timeLabel.textColor = .green
                        self.timerStatus = .ready
                    }
                }

                if sender.state == .cancelled {
                    self.timeLabel.textColor = self.timerTheme.textColor
                    self.timerStatus = .idle
                } else if sender.state == .ended {
                    if self.timerStatus == .ready {
                        self.timeLabel.textColor = self.timerTheme.textColor
                        self.timeLabel.text = "15"
                        self.inspectionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateInspectionTime), userInfo: nil, repeats: true)
                        self.timerStatus = .inspect
                        inspectionBegin = true
                    }
                }
            }
        }
    }

    @objc private func updateInspectionTime() {
        self.timeLabel.text = String(format: "%d", Int(self.timeLabel.text!)! - 1)

        if self.timeLabel.text == "1" {
            self.inspectionTimer?.invalidate()
            self.inspectionOverTimeTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateInspectionOverTimeTimer), userInfo: nil, repeats: true)
        }
    }

    @objc private func updateInspectionOverTimeTimer() {
        if self.timeLabel.text == "1" {
            self.timeLabel.text = "+2"
            self.plus2 = true
            return
        }

        if self.timeLabel.text == "+2" {
            self.plus2 = false
            self.timeLabel.text = "DNF"
            self.inspectionOverTimeTimer.invalidate()
            self.timerStatus = .idle
            self.inspectionBegin = false
            self.session.addSolve(0, with: PENALTY_DNF, scramble: self.thisScramble)
            SessionManager.saveSession(session: self.session)
            self.tabBarItem.badgeValue = String(format: "%d", self.session.numberOfSolves)
            self.displayNextScramble()
        }
    }

    @objc private func stopTimer() {
        if self.timerStatus == .timing {
            if self.time == 0 {
                return
            }

            self.myTimer.invalidate()
            self.inspectionTimer?.invalidate()
            self.timerStatus = .idle
            self.inspectionBegin = false

            if !self.plus2 {
                self.session.addSolve(Int32(Int(self.time)), with: PENALTY_NO_PENALTY, scramble: self.thisScramble)
            } else {
                self.session.addSolve(Int32(self.time), with: PENALTY_PLUS_2, scramble: self.thisScramble)
                self.plus2 = false
                self.timeLabel.text = self.session.lastSolve().toString()
            }

            SessionManager.saveSession(session: self.session)
            self.tabBarItem.badgeValue = String(format: "%d", self.session.numberOfSolves)
            self.displayNextScramble()
            self.stopCoreMotion()
            self.checkRated()
        }
    }

    @objc private func resetTimerStatus() {
        if !wcaInspection && timerStatus != TimerStatus.timing {
            self.timeLabel.textColor = timerTheme.textColor
            self.timerStatus = .idle
        }
    }

    @objc private func deleteLastSolve(swipGesture: UISwipeGestureRecognizer) {
        print("Swipe left")

        if self.timerStatus != .timing && self.timerStatus != TimerStatus.inspect && self.session.numberOfSolves > 0 {
            if swipGesture.direction == .left {
                let deleteLastTimerAlert = UIAlertController(
                    title: Utils.getLocalizedString(from: "delete last"),
                    message: Utils.getLocalizedString(from: "sure?"),
                    preferredStyle: .alert
                )
                deleteLastTimerAlert.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "no"), style: .cancel))
                deleteLastTimerAlert.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "yes"), style: .default, handler: { _ in
                    self.session.deleteLastSolve()
                    self.timeLabel.text = "Ready"
                    SessionManager.saveSession(session: self.session)
                    self.tabBarItem.badgeValue = String(format: "%d", self.session.numberOfSolves)
                }))
                self.present(deleteLastTimerAlert, animated: true)
            }
        }
    }

    @objc private func resetSession(tapGesture: UITapGestureRecognizer) {
        print("Swipe right")

        if self.timerStatus != .timing && self.timerStatus != TimerStatus.inspect && self.session.numberOfSolves > 0 {
            let clearTimeAlert = UIAlertController(
                title: Utils.getLocalizedString(from: "reset session"),
                message: Utils.getLocalizedString(from: "sure?"),
                preferredStyle: .alert
            )
            clearTimeAlert.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "no"), style: .cancel))
            clearTimeAlert.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "yes"), style: .default, handler: { _ in
                self.session.clear()
                self.timeLabel.text = "Ready"
                SessionManager.saveSession(session: self.session)
                self.tabBarItem.badgeValue = String(format: "%d", self.session.numberOfSolves)
            }))
            self.present(clearTimeAlert, animated: true)
        }
    }

    @objc private func addPenalty(tapGesture: UITapGestureRecognizer) {
        print("add penalty")

        if self.session.numberOfSolves > 0 && !(self.timeLabel.text == "Ready") && self.timerStatus != TimerStatus.timing && self.timerStatus != TimerStatus.inspect && self.session.lastSolve().timeBeforePenalty != 2147483647 {
            let addPenaltyAlert = UIAlertController(
                title: Utils.getLocalizedString(from: "penalty"),
                message: Utils.getLocalizedString(from: "this time was"),
                preferredStyle: .alert
            )
            addPenaltyAlert.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "cancel"), style: .cancel))
            addPenaltyAlert.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "+2"), style: .default, handler: { _ in
                self.session.addPenalty(toLastSolve: PENALTY_PLUS_2)
                self.timeLabel.text = self.session.lastSolve().toString()
                SessionManager.saveSession(session: self.session)
                self.tabBarItem.badgeValue = String(format: "%d", self.session.numberOfSolves)
            }))
            addPenaltyAlert.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "+DNF"), style: .default, handler: { _ in
                self.session.addPenalty(toLastSolve: PENALTY_DNF)
                self.timeLabel.text = self.session.lastSolve().toString()
                SessionManager.saveSession(session: self.session)
                self.tabBarItem.badgeValue = String(format: "%d", self.session.numberOfSolves)
            }))
            addPenaltyAlert.addAction(UIAlertAction(title: Utils.getLocalizedString(from: Utils.getLocalizedString(from: "no penalty")), style: .default, handler: { _ in
                self.session.addPenalty(toLastSolve: PENALTY_NO_PENALTY)
                self.timeLabel.text = self.session.lastSolve().toString()
                SessionManager.saveSession(session: self.session)
                self.tabBarItem.badgeValue = String(format: "%d", self.session.numberOfSolves)
            }))
            self.present(addPenaltyAlert, animated: true)
        }
    }

    @objc private func chooseScrambleType() {
        print("Choose Scramble Type")

        if self.timerStatus != .timing && self.timerStatus != TimerStatus.inspect {
            let pickerView = self.storyboard!.instantiateViewController(identifier: "ScramblePickerViewController") as! ScramblePickerViewController
            pickerView.modalPresentationStyle = .popover
            pickerView.delegate = self

            self.present(pickerView, animated: true)
        }
    }

    @objc private func manuallyAddNewSolve() {
        print("manually add new solve")

        if self.timerStatus != .timing && self.timerStatus != TimerStatus.inspect {
            let manuallyAddAlert = UIAlertController(
                title: Utils.getLocalizedString(from: "manuallyAdd"),
                message: Utils.getLocalizedString(from: "originalTime"),
                preferredStyle: .alert
            )
            manuallyAddAlert.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "cancel"), style: .cancel))
            manuallyAddAlert.addAction(UIAlertAction(title: Utils.getLocalizedString(from: "done"), style: .default, handler: { _ in
                let textField = manuallyAddAlert.textFields?.first!
                var text = textField!.text!
                let nf = NumberFormatter()
                nf.numberStyle = .decimal
                let nums = text.components(separatedBy: ".")

                if nums.count > 2 {
                    text = String(format: "%@.%@", nums[0], nums[1])
                }
                let myNumber = nf.number(from: text)
                let time = Int(myNumber!.doubleValue * 1000)

                self.session.addSolve(Int32(time), with: PENALTY_NO_PENALTY, scramble: self.thisScramble)
                SessionManager.saveSession(session: self.session)
                self.tabBarItem.badgeValue = String(format: "%d", self.session.numberOfSolves)
                self.timeLabel.text = self.session.lastSolve().toString()
                self.displayNextScramble()
                self.checkRated()
            }))
            manuallyAddAlert.addTextField(configurationHandler: { textField in
                textField.keyboardType = .decimalPad
            })
            self.present(manuallyAddAlert, animated: true)
        }
    }

    private func changeScramble() {
        self.nextScramble = Scramble.getNewScramble(scrambler: self.scrambler, type: Int(self.session.currentType), subType: Int(self.session.currentSubType))
        self.displayNextScramble()
    }

    @objc private func displayNextScramble() {
        self.thisScramble = self.nextScramble
        self.scrambleLabel.text = self.thisScramble.scramble
        print("This scramble : \(String(describing: self.thisScramble.scramble))")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.generateNextScramble()
        }
    }

    @objc private func getNewScramble() {
        if self.timerStatus != .timing && self.timerStatus != TimerStatus.inspect {
            self.displayNextScramble()
        }
    }

    private func generateNextScramble() {
        self.nextScramble = Scramble.getNewScramble(scrambler: self.scrambler, type: Int(self.session.currentType), subType: Int(self.session.currentSubType))
        print("next scramble : \(String(describing: self.nextScramble.scramble))")
    }

    private func checkRated() {
        // Should I do something for rating ?
    }

    private struct Const {
        static let TagAlertChangeScrambleType = 1
    }

}

extension TimingViewController: ScramblePickerViewControllerDelegate {
    func didSelectScramble(type: Int, subType: Int) {
        scrType = type
        scrSubType = subType
        self.session.currentType = Int32(type)
        self.session.currentSubType = Int32(subType)
        oldScrType = scrType
        oldScrSubType = scrSubType
        self.changeScramble()
        SessionManager.saveSession(session: self.session)

        print("choose scramble index \(self.session.currentType) \(self.session.currentSubType)")
    }
}
