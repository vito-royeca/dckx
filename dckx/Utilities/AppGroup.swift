//
//  AppGroup.swift
//  dckx
//
//  Created by Vito Royeca on 4/21/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import Foundation

public enum AppGroup: String {
  case facts = "group.com.vitoroyeca.dckx"

  public var containerURL: URL {
    switch self {
    case .facts:
      return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.rawValue)!
    }
  }
}
