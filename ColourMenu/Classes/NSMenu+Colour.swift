//
//  NSMenu+Colour.swift
//  ColourMenu
//
//  Created by Jifu Cao on 2022/4/1.
//

import AppKit

public extension NSMenu {
  struct MenuItem {
    public init(title: String, config: NSMenuItem.ItemConfiguration = .default, keyEquivalent: String = "", isSeparatorItem: Bool = false, action: (() -> Void)? = nil) {
      self.title = title
      self.config = config
      self.keyEquivalent = keyEquivalent
      self.isSeparatorItem = isSeparatorItem
      self.action = action
    }
    
    public static let separator: MenuItem = .init(title: "", isSeparatorItem: true)
    var title: String
    var config: NSMenuItem.ItemConfiguration = .default
    var keyEquivalent: String = ""
    var isSeparatorItem: Bool = false
    var action: (() -> Void)?
  }

  private static var _menuItemIndex: Int = 0
  private var _items: [MenuItem]? {
    get {
      objc_getAssociatedObject(self, &NSMenu._menuItemIndex) as? [MenuItem]
    }
    set {
      objc_setAssociatedObject(self, &NSMenu._menuItemIndex, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  convenience
  init(title: String, items: [MenuItem]) {
    self.init(title: title)
    self._items = items
    items.forEach { item in
      if item.isSeparatorItem {
        let separator = NSMenuItem.separator()
        separator.setConfig(item.config)
        self.addItem(separator)
      } else {
        let menuItem = self.addItem(withTitle: item.title, action: #selector(handleColoursMenuItemAction(_:)), keyEquivalent: item.keyEquivalent)
        menuItem.target = self
        menuItem.representedObject = item
        menuItem.setConfig(item.config)
      }
    }
  }
  
  @objc
  private func handleColoursMenuItemAction(_ sender: NSMenuItem) {
    guard let item = sender.representedObject as? MenuItem else { return }
    item.action?()
  }
}
