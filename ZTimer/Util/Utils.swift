//
//  Utils.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 18/07/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import Foundation
import UIKit

struct Utils {

    private let settings = Settings()

    static func getLocalizedString(from string: String) -> String {
        NSLocalizedString(string, comment: "")
    }

    static func convertTimeFromMsecondToString(msecond: Int) -> String {
        var outputTimeString: String

        if msecond < 1000 {
            outputTimeString = String(format: "0.%03d", msecond)
        } else if msecond < 60000 {
            let second = Int(Double(msecond) * 0.001)
            let msec = msecond % 1000;
            outputTimeString = String(format: "%d.%03d", second, msec)
        } else if msecond < 3600000 {
            let minute = msecond / 60000;
            let second = (msecond % 60000)/1000;
            let msec = msecond % 1000;
            outputTimeString = String(format: "%d:%02d.%03d", minute, second, msec)
        } else {
            let hour = msecond / 3600000;
            let minute = (msecond % 360000) / 60000;
            let second = (msecond % 60000) / 1000;
            let msec = msecond % 1000;
            outputTimeString = String(format: "%d:%02d:%02d.%03d", hour, minute, second, msec)
        }

        return outputTimeString
    }

    func escapeString(string: String) -> String {
        var fileName = string
        fileName = fileName.replacingOccurrences(of: "/", with: "slash")
        return fileName
    }

    func heightOfContent(content: String, font: UIFont) -> CGFloat {
        let attributedText = NSAttributedString(string: content, attributes: [NSAttributedString.Key.font: font])
        let rect = attributedText.boundingRect(with: CGSize(width: self.getScreenWidth() - 20, height: 44.0 * 7), options: .usesLineFragmentOrigin, context: nil)

        return rect.size.height + 20
    }

    private func getScreenWidth() -> CGFloat {
        var screenWidth: CGFloat
        screenWidth = UIScreen.main.bounds.width
        print("screen width = \(screenWidth)")

        if screenWidth == 748.0 {
            screenWidth = 1024.0
        }

        return screenWidth
    }
}
