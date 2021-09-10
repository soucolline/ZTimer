//
//  Theme.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 19/07/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import Foundation
import UIKit

@objc enum ThemeValue: Int, CaseIterable {
    case blue = 0
    case white
    case red
    case green
    case yellow
    case black
    case pink
}

@objc enum FontStyle: Int {
    case bold = 0
    case light
    case regular
}

@objcMembers class Theme: NSObject {
    var myTheme: ThemeValue!
    var textColor: UIColor!
    var backgroundColor: UIColor!
    var tabBarColor: UIColor!
    var navigationColor: UIColor!
    var barItemColor: UIColor!

    func getMyTheme() -> ThemeValue {
        myTheme
    }

    static func initWithTheme(theme: ThemeValue) -> Theme {
        let timerTheme = Theme()
        timerTheme.myTheme = theme
        timerTheme.navigationColor = Theme.getColorFromTheme(theme: theme)

        let lightBlackColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)

        switch theme {
            case .blue, .red, .green, .pink:
                timerTheme.textColor = UIColor.white
                timerTheme.backgroundColor = lightBlackColor
                timerTheme.tabBarColor = UIColor.black
                timerTheme.barItemColor = UIColor.yellow
            case .white:
                timerTheme.textColor = UIColor.black
                timerTheme.backgroundColor = UIColor.white
                timerTheme.tabBarColor = timerTheme.navigationColor
                timerTheme.barItemColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            case .yellow:
                timerTheme.textColor = UIColor.white
                timerTheme.backgroundColor = lightBlackColor
                timerTheme.tabBarColor = UIColor.black
                timerTheme.barItemColor = UIColor.orange
            case .black:
                timerTheme.textColor = UIColor.white
                timerTheme.backgroundColor = lightBlackColor
                timerTheme.tabBarColor = UIColor.black
                timerTheme.barItemColor = UIColor.white
        }

        return timerTheme
    }

    func setNavigationControllerTheme() {
        let myApp = UIApplication.shared
        if myTheme == .white {
            print("theme white")
            myApp.setStatusBarStyle(.default, animated: true)

        } else {
            print("theme others")
            myApp.setStatusBarStyle(.lightContent, animated: true)
        }

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: R.font.regular(size: 22),
            NSAttributedString.Key.foregroundColor: self.textColor as Any
        ]
        UINavigationBar.appearance().barTintColor = self.navigationColor
        UINavigationBar.appearance().tintColor = self.barItemColor
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.font: R.font.regular(size: 17)
        ], for: .normal)
        UITabBar.appearance().barTintColor = self.tabBarColor
    }

    func setNavigationControllerTheme(controller: UINavigationController) {
        let myApp = UIApplication.shared
        if myTheme == .white {
            print("theme white")
            myApp.setStatusBarStyle(.default, animated: true)

        } else {
            print("theme others")
            myApp.setStatusBarStyle(.lightContent, animated: true)
        }

        controller.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: R.font.regular(size: 22),
            NSAttributedString.Key.foregroundColor: self.textColor as Any
        ]
        controller.navigationBar.barTintColor = self.navigationColor
        controller.navigationBar.tintColor = self.barItemColor
    }

    static func getThemeName(theme: ThemeValue) -> String {
        switch theme {
            case .blue: return R.string.localizable.theme_blue()
            case .white: return R.string.localizable.theme_white()
            case .red: return R.string.localizable.theme_red()
            case .green: return R.string.localizable.theme_green()
            case .yellow: return R.string.localizable.theme_yellow()
            case .black: return R.string.localizable.theme_black()
            case .pink: return R.string.localizable.theme_pink()
        }
    }

    func getMyThemeName() -> String {
        Theme.getThemeName(theme: myTheme)
    }

    func save() {
        Settings().save(int: myTheme.rawValue, forKey: "timerTheme")
    }

    static func getTimerTheme() -> Theme {
        self.initWithTheme(theme: ThemeValue(rawValue: Settings().int(forKey: "timerTheme"))!)
    }

    static func getAllTheme() -> [Int] {
        var themes: [Int] = []

        ThemeValue.allCases.forEach {
            themes.append($0.rawValue)
        }

        return themes
    }

    static func getColorFromTheme(theme: ThemeValue) -> UIColor {
        var color: UIColor

        switch theme {
            case .blue:
                color = UIColor(red: 26/255, green: 127/255, blue: 191/255, alpha: 1)
            case .white:
                color = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
            case .red:
                color = UIColor(red: 255/255, green: 58/255, blue: 45/255, alpha: 1)
            case .green:
                color = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
            case .yellow:
                color = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
            case .black:
                color = UIColor.black
            case .pink:
                color = UIColor(red: 255/255, green: 73/255, blue: 129/255, alpha: 1)
            default:
                color = UIColor(red: 26/255, green: 127/255, blue: 191/255, alpha: 1)
        }

        return color
    }

    func getTintColor() -> UIColor {
        if self.myTheme == .white {
            return UIColor.lightGray
        } else {
            return Theme.getColorFromTheme(theme: myTheme)
        }
    }
}

extension R {
    struct font {
        static func bold(size: CGFloat) -> UIFont {
            UIFont(name: "Avenir-Medium", size: size)!
        }

        static func light(size: CGFloat) -> UIFont {
            UIFont(name: "Avenir-Light", size: size)!
        }

        static func regular(size: CGFloat) -> UIFont {
            UIFont(name: "Avenir-Book", size: size)!
        }
    }
}
