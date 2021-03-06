//
//  OverlayView.swift
//  macos-draw-practice
//
//  Created by soudegesu on 2021/12/23.
//

import SwiftUI

enum DrawType {
    case red
    case black
    
    var color: Color {
        switch self {
            case .red:
                return Color.red
            case .black:
                return Color.black
        }
    }
}

class RenderPathState: Identifiable, ObservableObject {
  @Published var points: [CGPoint] = []
  @Published var color: Color = .black
  @Published var renderPath = true
  var isFixed = false {
    didSet {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.renderPath = false
      }
    }
  }
  let lineWidth = CGFloat(7.0)
  
  var id = UUID()
    
  func toFixed() {
    self.color = .red
    self.isFixed = true
  }
  
  func addPoint(point: CGPoint) {
    self.points.append(point)
    self.objectWillChange.send()
  }
}

struct RenderPathView: View {
  
  @ObservedObject var state: RenderPathState
  
  @ViewBuilder
  var body: some View {
    Path { path in
      path.addLines(state.points)
    }
    .stroke(state.color, lineWidth: state.lineWidth)
    .opacity(state.renderPath ? 1.0 : 0.0)
    .animation(.easeOut)
  }
}

class OverlayViewState: ObservableObject {
  var drawnPaths: [RenderPathState] = [] {
    willSet {
      newValue.forEach { val in val.toFixed() }
    }
  }
  var drawingPath: RenderPathState = RenderPathState()
  
  private let clearDuration = 2.0
  
  func drawing(point: CGPoint) {
    self.drawingPath.addPoint(point: point)
  }
  
  func fixPath() {
    let newFixPath = self.drawingPath
    self.drawnPaths.append(newFixPath)

    DispatchQueue.main.asyncAfter(deadline: .now() + self.clearDuration) { [weak self] in
      self?.drawnPaths = self?.drawnPaths.filter { drawn in drawn.id != newFixPath.id } ?? []
      self?.objectWillChange.send()
    }

    self.drawingPath = RenderPathState()
    objectWillChange.send()
  }
}

struct OverlayView: View {
    
    @ObservedObject var state = OverlayViewState()
    
    @ViewBuilder
    var body: some View {
        VStack {
            Rectangle()
                .foregroundColor(Color.white)
                .frame(width: 300, height: 300, alignment: .center)
                .overlay(
                  ZStack {
                    ForEach(state.drawnPaths) { path in
                      RenderPathView(state: path)
                    }
                    RenderPathView(state: state.drawingPath)
                  }
                  .allowsHitTesting(false)
                  .disabled(true)
                )
                .gesture(
                    DragGesture()
                        .onChanged({ (value) in
                          self.state.drawing(point: value.location)
                        })
                        .onEnded({ (value) in
                          self.state.fixPath()
                        })
                )
        }.onHover(perform: { hovering in
          if hovering {
            NSCursor.crosshair.push()
          } else {
            NSCursor.current.pop()
          }
        })
    }
}
