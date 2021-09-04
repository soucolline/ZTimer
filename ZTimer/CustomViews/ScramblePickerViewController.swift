//
//  ScramblePickerViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 14/08/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit
import ZScrambler

protocol ScramblePickerViewControllerDelegate: AnyObject {
    func didSelectScramble(type: Int, subType: Int)
}

class ScramblePickerViewController: UIViewController {
    @IBOutlet private var pickerView: UIPickerView!
    @IBOutlet private var validateButton: UIButton!

    var scrType: NSDictionary!
    var types: [String]!
    var selectedType = 0
    var selectedSubType = 0
    var subsets: [String]!

    weak var delegate: ScramblePickerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupPicker()
    }

    private func setupUI() {
        self.validateButton.clipsToBounds = true
        self.validateButton.layer.cornerRadius = 12
    }

    private func setupPicker() {
        let plistUrl = Bundle.main.url(forResource: "scrambleTypes", withExtension: "plist")!
        self.scrType = NSDictionary(contentsOf: plistUrl)
        self.types = ZScrambler.scrambleTypes()
        let select = self.types[0]
        self.subsets = self.scrType[select] as? [String]

        self.pickerView.delegate = self
        self.pickerView.dataSource = self
    }

    @IBAction private func didTapValidate() {
        self.dismiss(animated: true) {
            self.delegate?.didSelectScramble(type: self.selectedType, subType: self.selectedSubType)
        }
    }
}

extension ScramblePickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.types.count
        } else {
            return self.subsets.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return self.types[row]
        } else {
            return self.subsets[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let selType = types[row]
            let newSubsets = scrType[selType] as? [String]
            subsets = newSubsets

            pickerView.selectRow(0, inComponent: 1, animated: true)
            pickerView.reloadComponent(1)
        }

        self.selectedType = pickerView.selectedRow(inComponent: 0)
        self.selectedSubType = pickerView.selectedRow(inComponent: 1)
    }
}
