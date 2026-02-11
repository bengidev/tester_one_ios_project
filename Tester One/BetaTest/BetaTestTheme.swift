//
//  BetaTestTheme.swift
//  Tester One
//

import UIKit

extension UIColor {

  // MARK: Internal

  static let betaTestPrimaryText = betaTestDynamic(light: .black, dark: .white)
  static let betaTestSurface = betaTestDynamic(
    light: .white,
    dark: UIColor(red: 28.0 / 255.0, green: 28.0 / 255.0, blue: 30.0 / 255.0, alpha: 1),
  )
  static let betaTestBadgeBackground = betaTestDynamic(
    light: UIColor(white: 1.0, alpha: 0.92),
    dark: UIColor(white: 0.22, alpha: 0.92),
  )

  static let betaTestHeaderGreen = betaTestDynamic(
    light: UIColor(red: 54.0 / 255.0, green: 132.0 / 255.0, blue: 3.0 / 255.0, alpha: 1),
    dark: UIColor(red: 32.0 / 255.0, green: 92.0 / 255.0, blue: 24.0 / 255.0, alpha: 1),
  )
  static let betaTestLoadingText = betaTestDynamic(
    light: UIColor(red: 173.0 / 255.0, green: 177.0 / 255.0, blue: 178.0 / 255.0, alpha: 1),
    dark: UIColor(red: 178.0 / 255.0, green: 181.0 / 255.0, blue: 182.0 / 255.0, alpha: 1),
  )
  static let betaTestLoadingBackground = betaTestDynamic(
    light: UIColor(red: 215.0 / 255.0, green: 220.0 / 255.0, blue: 222.0 / 255.0, alpha: 1),
    dark: UIColor(red: 70.0 / 255.0, green: 74.0 / 255.0, blue: 77.0 / 255.0, alpha: 1),
  )
  static let betaTestSapGreen = betaTestDynamic(
    light: UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 28.0 / 255.0, alpha: 1),
    dark: UIColor(red: 122.0 / 255.0, green: 201.0 / 255.0, blue: 84.0 / 255.0, alpha: 1),
  )
  static let betaTestLabelGreen = betaTestHeaderGreen
  static let betaTestStatusGreen = betaTestDynamic(
    light: UIColor(red: 76.0 / 255.0, green: 153.0 / 255.0, blue: 31.0 / 255.0, alpha: 1),
    dark: UIColor(red: 132.0 / 255.0, green: 210.0 / 255.0, blue: 95.0 / 255.0, alpha: 1),
  )
  static let betaTestErrorRed = betaTestDynamic(
    light: UIColor(red: 194.0 / 255.0, green: 50.0 / 255.0, blue: 0, alpha: 1),
    dark: UIColor(red: 255.0 / 255.0, green: 105.0 / 255.0, blue: 97.0 / 255.0, alpha: 1),
  )
  static let betaTestDarkGray = betaTestDynamic(
    light: UIColor(red: 53.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1),
    dark: UIColor(red: 198.0 / 255.0, green: 198.0 / 255.0, blue: 198.0 / 255.0, alpha: 1),
  )
  static let betaTestLightGray = betaTestDynamic(
    light: UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1),
    dark: UIColor(red: 44.0 / 255.0, green: 44.0 / 255.0, blue: 46.0 / 255.0, alpha: 1),
  )
  static let betaTestInitialCard = betaTestLightGray
  static let betaTestDisabledCard = betaTestLightGray
  static let betaTestDisabledCircle = betaTestDynamic(
    light: UIColor(red: 214.0 / 255.0, green: 214.0 / 255.0, blue: 214.0 / 255.0, alpha: 1),
    dark: UIColor(red: 84.0 / 255.0, green: 84.0 / 255.0, blue: 88.0 / 255.0, alpha: 1),
  )
  static let betaTestDisabledIcon = betaTestDynamic(
    light: UIColor(red: 80.0 / 255.0, green: 80.0 / 255.0, blue: 80.0 / 255.0, alpha: 1),
    dark: UIColor(red: 196.0 / 255.0, green: 196.0 / 255.0, blue: 196.0 / 255.0, alpha: 1),
  )
  static let betaTestSuccessCircle = betaTestDynamic(
    light: UIColor(red: 218.0 / 255.0, green: 229.0 / 255.0, blue: 212.0 / 255.0, alpha: 1),
    dark: UIColor(red: 43.0 / 255.0, green: 74.0 / 255.0, blue: 47.0 / 255.0, alpha: 1),
  )
  static let betaTestErrorCircle = betaTestDynamic(
    light: UIColor(red: 234.0 / 255.0, green: 213.0 / 255.0, blue: 213.0 / 255.0, alpha: 1),
    dark: UIColor(red: 84.0 / 255.0, green: 44.0 / 255.0, blue: 44.0 / 255.0, alpha: 1),
  )

  // MARK: Private

  private static func betaTestDynamic(light: UIColor, dark: UIColor) -> UIColor {
    if #available(iOS 13.0, *) {
      UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? dark : light
      }
    } else {
      light
    }
  }
}
