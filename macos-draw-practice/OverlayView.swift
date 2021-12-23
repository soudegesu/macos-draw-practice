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

struct Line: Identifiable {
    var drawPoints: [DrawPoints] = []
    var id = UUID()
}

struct DrawPoints: Identifiable {
    var points: [CGPoint]
    var color: Color
    var id = UUID()
}

struct OverlayView: View {
    @State var tmpDrawPoints: DrawPoints = DrawPoints(points: [], color: .black)
    @State var lines: [Line] = []
    @State var startPoint: CGPoint = CGPoint.zero
    @State var selectedColor: DrawType = .black
    let lineWidth = CGFloat(10.0)

    @ViewBuilder
    var body: some View {
        VStack {
            Rectangle()
                .foregroundColor(Color.white)
                .frame(width: 300, height: 300, alignment: .center)
                .overlay(
                  ZStack {
                    ForEach(lines) { line in
                      ZStack {
                        ForEach(line.drawPoints) { data in
                          Path { path in
                              path.addLines(data.points)
                          }
                          .stroke(Color.red, lineWidth: lineWidth)
                        }
                      }
                    }
                  }
                  .overlay(
                    Path { path in
                        path.addLines(self.tmpDrawPoints.points)
                    }
                    .stroke(self.tmpDrawPoints.color, lineWidth: lineWidth)
                  )
                )
                .gesture(
                    DragGesture()
                        .onChanged({ (value) in
//                          if self.startPoint != value.startLocation || self.startPoint == .zero {
                            self.tmpDrawPoints.points.append(value.location)
                            self.tmpDrawPoints.color = self.selectedColor.color
//                          }
                        })
                        .onEnded({ (value) in
                          self.startPoint = value.startLocation
                          let newLine = Line(drawPoints: [self.tmpDrawPoints])
                          self.lines.append(newLine)
                          DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            self.lines = self.lines.filter { $0.id != newLine.id }
                          }
                          self.tmpDrawPoints.points = []
                        })
                )
        }
    }
}
