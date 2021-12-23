//
//  OverlayView.swift
//  macos-draw-practice
//
//  Created by soudegesu on 2021/12/23.
//

import SwiftUI

enum DrawType {
    case red
    case clear
    case black
    
    var color: Color {
        switch self {
            case .red:
                return Color.red
            case .clear:
                return Color.white
            case .black:
                return Color.black
        }
    }
}

struct DrawPoints: Identifiable {
    var points: [CGPoint]
    var color: Color
    var id = UUID()
}

struct DrawPathView: View {
    var drawPointsArray: [DrawPoints]

    var body: some View {
        ZStack {
            ForEach(drawPointsArray) { data in
                Path { path in
                    path.addLines(data.points)
                }
                .stroke(data.color, lineWidth: 10)
            }
        }
    }
}

struct OverlayView: View {
    @State var tmpDrawPoints: DrawPoints = DrawPoints(points: [], color: .red)
    @State var endedDrawPoints: [DrawPoints] = []
    @State var startPoint: CGPoint = CGPoint.zero
    @State var selectedColor: DrawType = .red

    var body: some View {
        VStack {
            Rectangle()
                .foregroundColor(Color.white)
                .frame(width: 300, height: 300, alignment: .center)
                .overlay(
                    DrawPathView(drawPointsArray: endedDrawPoints)
                        .overlay(
                            // ドラッグ中の描画。指を離したらここの描画は消えるがDrawPathViewが上書きするので見た目は問題ない
                            Path { path in
                                path.addLines(self.tmpDrawPoints.points)
                            }
                            .stroke(self.tmpDrawPoints.color, lineWidth: 10)
                        )
                )
                .gesture(
                    DragGesture()
                        .onChanged({ (value) in
                            if self.startPoint != value.startLocation {
                              self.tmpDrawPoints.points.append(value.location)
                              self.tmpDrawPoints.color = self.selectedColor.color
                            }
                            self.endedDrawPoints.append(self.tmpDrawPoints)
                        })
                        .onEnded({ (value) in
                            self.startPoint = value.startLocation
                            self.endedDrawPoints.append(self.tmpDrawPoints)
                            self.tmpDrawPoints = DrawPoints(points: [], color: self.selectedColor.color)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                              self.endedDrawPoints = []
                            }
                        })
                )
            VStack(spacing: 10) {
                Button(action: {
                    self.selectedColor = .red

                }) { Text("赤")
                }
                Button(action: {
                    self.selectedColor = .clear
                }) { Text("消しゴム")
                }
                Spacer()
            }
            .frame(minWidth: 0.0, maxWidth: CGFloat.infinity)
            .background(Color.gray)
        }
    }
}
