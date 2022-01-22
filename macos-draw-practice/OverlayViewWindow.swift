//
//  OverlayViewWindow.swift
//  macos-draw-practice
//
//  Created by soudegesu on 2022/01/19.
//

import AppKit

class OverlayViewWindow: NSWindow {
  
  override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
      super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    self.disableCursorRects()
  }
}
