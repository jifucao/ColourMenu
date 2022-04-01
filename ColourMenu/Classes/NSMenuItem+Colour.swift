//
//  NSMenu+Ex.swift
//  MacXLSDKs
//
//  Created by Jifu on 2022/3/31.
//  Copyright (c) 2022 Jifu. All rights reserved.
//

import AppKit
import ViewHover

private final class BackgroundMenuView: NSView {
  init(color: NSColor) {
    super.init(frame: .zero)
    wantsLayer = true
    layer?.backgroundColor = color.cgColor
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: -
private final class MenuItemView: NSView {
  
  public typealias MenuItemAction = () -> Void
  
  var config: NSMenuItem.ItemConfiguration
  private var title: String = ""
  private var isSeparatorItem: Bool
  private var isEnabled: Bool {
    self.enclosingMenuItem?.isEnabled ?? false
  }
  
  private lazy var titleLabel: NSTextField = {
    let label = NSTextField.init(labelWithString: self.title)
    label.font = self.config.titleFont
    label.textColor = self.config.titleColor
    return label
  }()
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public init(title: String,
              isSeparatorItem: Bool = false,
              config: NSMenuItem.ItemConfiguration = .default) {
    self.title = title
    self.config = config
    self.isSeparatorItem = isSeparatorItem
    if isSeparatorItem {
      super.init(frame: .init(origin: .zero,
                              size: .init(width: config.minimumItemSize.width, height: 8)))
      
    } else {
      super.init(frame: .init(origin: .zero, size: config.minimumItemSize))
    }
    wantsLayer = true
    layer?.backgroundColor = config.backgroundColor.cgColor
  }
  
  private func setup() {
    didSetup = true
    guard !isSeparatorItem else { return setupSeparatorItem() }
    let stackview = NSStackView.init(views: [titleLabel])
    stackview.edgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
    addSubview(stackview)
    stackview.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackview.heightAnchor.constraint(equalTo: self.heightAnchor),
      stackview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
      stackview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
      stackview.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    ])
    stackview._setBackgroundColor(.clear)
    stackview.layer?.cornerRadius = 4.0
    titleLabel.textColor = isEnabled ? self.config.titleColor : self.config.disabledTitleColor
    if isEnabled {
      onHover(option: [.downAsExit]) { [unowned self] isHover in
        stackview.layer?.backgroundColor = isHover ? self.config.hoverColor.cgColor : self.config.backgroundColor.cgColor
      }
    }
    
  }
  
  private lazy var separator = CALayer()
  private func setupSeparatorItem() {
    _setBackgroundColor(config.backgroundColor)
    layer?.addSublayer(separator)
    separator.backgroundColor = config.separatorColor.cgColor
    separator.frame = NSInsetRect(bounds, config.separatorHorizontalPadding, config.separatorVerticlaPadding)
  }
  
  private var didSetup: Bool = false
  public override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    let views = drawingViews
    views.forEach {
      $0._setBackgroundColor(self.config.backgroundColor)
    }
    if let itemsContainerView = itemsContainerView, let drawingView = views.last {
      drawingView.addSubview(itemsContainerView)
    }
    guard !didSetup else { return }
    setup()
   
  }
  
  private var drawingViews: [NSView] {
    guard let contentView = self.window?.contentView else { return []}
    return contentView.subviews.filter({ $0.className == "NSMenuWindowManagerDrawingHandlerView" })
  }
  
  private var itemsContainerView: NSView? {
    guard let contentView = self.window?.contentView else { return nil }
    return contentView.subviews.first(where: { $0.className == "NSMenuWindowManagerMenuItemsContainerView" })
  }

  
  override public func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    mouseDownloadHandler?()
  }
  
  var mouseDownloadHandler: (() -> Void)?
}


// MARK: -
private  extension NSView {
  func _setBackgroundColor(_ color: NSColor) {
    wantsLayer = true
    self.layer?.backgroundColor = color.cgColor
  }
}

// MARK: -
public extension NSMenuItem {
  struct ItemConfiguration {
    public static let `default`: ItemConfiguration = ItemConfiguration()
    public var backgroundColor: NSColor = .white
    public var hoverColor: NSColor = .blue
    public var minimumItemSize: NSSize = .init(width: 160, height: 30)
    public var titleFont: NSFont = .systemFont(ofSize: 14)
    public var titleColor: NSColor = NSColor.textColor
    public var disabledTitleColor: NSColor = NSColor.disabledControlTextColor
    public var separatorColor: NSColor = .gridColor
    public var separatorThickness: CGFloat = 1.0
    public var separatorHorizontalPadding: CGFloat = 20
    public var separatorVerticlaPadding: CGFloat = 3
  }
  
  func setConfig(_ config: ItemConfiguration) {
    if let itemView = self.view as? MenuItemView {
      itemView.config = config
    } else {
      let itemView = MenuItemView.init(title: self.title,
                                       isSeparatorItem: self.isSeparatorItem,
                                       config: config)
      itemView.mouseDownloadHandler = { [unowned self] in
        if let action =  self.action {
          NSApp.sendAction(action, to: self.target, from: self)
          self.menu?.cancelTracking()
        }
      }
      self.view = itemView
    }
  }
}

