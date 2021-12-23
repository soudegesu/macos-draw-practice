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
  @Published var points: [CGPoint]
  @Published var color: Color
  var id = UUID()
  
  init(points: [CGPoint], color: Color) {
    self.points = points
    self.color = color
  }
  
  func addPoint(point: CGPoint) {
    self.points.append(point)
    self.objectWillChange.send()
  }
  
//  func reset() {
//    self.points = []
//    self.objectWillChange.send()
//  }
}

class Shape: Identifiable, ObservableObject {
  @Published var drawPoints: [RenderPathState] = []
  var id = UUID()
}

class OverlayViewState: ObservableObject {
  @Published var shapes: [Shape] = []
  @Published var tmpDrawPoints: RenderPathState = RenderPathState(points: [], color: .black)
  
  let lineWidth = CGFloat(10.0)
  
  func resetTmpDrawPoints() {
    self.tmpDrawPoints = RenderPathState(points: [], color: .black)
  }
  
  func vanishShape(id: UUID) {
    self.shapes = self.shapes.filter { shape in shape.id != id }
    objectWillChange.send()
  }
}

struct RenderPathView: View {
  
  @ObservedObject var state: RenderPathState

  var lineWidth: CGFloat
  
  var color: Color
  
  @ViewBuilder
  var body: some View {
    Path { path in
        path.addLines(state.points)
    }
    .stroke(color, lineWidth: self.lineWidth)
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
                    ForEach(state.shapes) { shape in
                      ZStack {
                        ForEach(shape.drawPoints) { data in
                          RenderPathView(state: data, lineWidth: state.lineWidth, color: .red)
                        }
                      }
                    }
                  }
                  .overlay(
                    RenderPathView(state: state.tmpDrawPoints, lineWidth: state.lineWidth, color: .black)
                  )
                )
                .gesture(
                    DragGesture()
                        .onChanged({ (value) in
                          self.state.tmpDrawPoints.addPoint(point: value.location)
                        })
                        .onEnded({ (value) in
                          let newShape = Shape()
                          newShape.drawPoints.append(state.tmpDrawPoints)
                          self.state.shapes.append(newShape)
                          self.state.resetTmpDrawPoints()
                          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.state.vanishShape(id: newShape.id)
                          }
                        })
                )
        }
    }
}
