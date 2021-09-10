//
//  EditSessionViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 8/1/21.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit

class EditSessionViewController: UITableViewController {

    private var myTextField: UITextField!
    @objc var isNew: Bool = false
    @objc var oldSessionName: String!
    private var sessionManager = SessionManager.loadd()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        myTextField.resignFirstResponder()
        super.viewWillDisappear(animated)
    }
}

extension EditSessionViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        self.view.setNeedsDisplay()

        myTextField = UITextField(frame: CGRect(x: 20, y: 5, width: 280, height: 36))
        myTextField.borderStyle = .none
        myTextField.contentVerticalAlignment = .center
        myTextField.placeholder = R.string.localizable.input_session_name()
        myTextField.clearButtonMode = .whileEditing
        myTextField.returnKeyType = .done

        if !isNew {
            myTextField.text = oldSessionName
        }

        myTextField.enablesReturnKeyAutomatically = true
        myTextField.delegate = self
        myTextField.font = R.font.regular(size: 17)
        myTextField.becomeFirstResponder()

        cell.addSubview(myTextField)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        R.string.localizable.session_name()
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        R.string.localizable.session_name_dup()
    }
}

extension EditSessionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.isNew {
            let newSession = textField.text ?? ""

            if sessionManager.hasSession(sessionName: newSession) == true {
                textField.text = ""
                textField.resignFirstResponder()

                let duplicateName = UIAlertController(
                    title: R.string.localizable.dup_warning(),
                    message: R.string.localizable.choose_another_name(),
                    preferredStyle: .alert
                )
                duplicateName.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .cancel))
                self.present(duplicateName, animated: true)
                return false
            } else {
                self.sessionManager.addSession(addName: newSession)
                self.sessionManager.save()
                self.navigationController?.popViewController(animated: true)
                return true
            }
        } else {
            let newSession = textField.text ?? ""

            if !(newSession
                    == oldSessionName) && (sessionManager.hasSession(sessionName: newSession) == true) {
                textField.text = oldSessionName
                textField.resignFirstResponder()

                let duplicateName = UIAlertController(
                    title: R.string.localizable.dup_warning(),
                    message: R.string.localizable.choose_another_name(),
                    preferredStyle: .alert
                )
                duplicateName.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .cancel))
                self.present(duplicateName, animated: true)
                return false
            } else {
                self.sessionManager.renameSession(from: oldSessionName, to: newSession)
                self.sessionManager.save()
                self.navigationController?.popViewController(animated: true)
                return true
            }
        }
    }
}
