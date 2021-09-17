//
//  LicenceViewController.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 7/28/21.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import UIKit
import WebKit

class LicenseViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = R.string.localizable.license()

        self.webView.load(URLRequest(url: R.file.licenseHtml()!))
    }
}
