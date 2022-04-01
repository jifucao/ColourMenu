//
//  ViewController.swift
//  ColourMenu
//
//  Created by Jifu on 04/01/2022.
//  Copyright (c) 2022 Jifu. All rights reserved.
//

import Cocoa
import ColourMenu

class ViewController: NSViewController {
  
  private var highlightColor: NSColor = .red {
    didSet {
      self.view.layer?.backgroundColor = highlightColor.cgColor
    }
  }
  var config: NSMenuItem.ItemConfiguration {
    var config = NSMenuItem.ItemConfiguration.default
    config.backgroundColor = .white
    config.hoverColor = highlightColor
    return config
  }
  
  private lazy var items: [NSMenu.MenuItem] = {
    let redMenu = NSMenu.MenuItem.init(title: "Red Color", config: config){ [unowned self] in
      self.highlightColor = .red
    }
    
    let greenMenu = NSMenu.MenuItem.init(title: "Green Color", config: config){ [unowned self] in
      self.highlightColor = .green
    }
    
    let blueMenu = NSMenu.MenuItem.init(title: "Blue Color", config: config){ [unowned self] in
      self.highlightColor = .blue
    }
    return  [redMenu, greenMenu, NSMenu.MenuItem.separator, blueMenu]
  }()
  
  private lazy var contextMenu = NSMenu.init(title: "ColoursMenu",
                                             items: items)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.wantsLayer = true
  }
  
  override func mouseDown(with event: NSEvent) {
    let p = event.locationInWindow
    let viewPoint = view.convert(p, from: nil)
    contextMenu.popUp(positioning: nil, at: viewPoint, in: self.view)
  }
}
