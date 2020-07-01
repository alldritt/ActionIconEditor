//
//  PaletteView.swift
//  IconEditor
//
//  Created by Mark Alldritt on 2020-06-30.
//  Copyright © 2020 Mark Alldritt. All rights reserved.
//

import UIKit

class PaletteView: UIView {

    let rows = 3
    let columns = 5
    
    var color: UIColor = ActionKit.colors[5] {
        didSet {
            guard color != oldValue else { return }
            assert(ActionKit.colors.contains(color))
            setNeedsDisplay()
            changed?(color)
        }
    }
    
    var changed: ((_: UIColor) -> Void)?
    
    private var firstPressedColorIndex: Int?
    private var pressedColorIndex: Int? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private func colorIndex(at point: CGPoint) -> Int {
        let cellWidth = bounds.width / CGFloat(columns)
        let cellHeight = bounds.height / CGFloat(rows)
        
        let c = Int(point.x / cellWidth)
        let r = Int(point.y / cellHeight)
        
        let cellColorIndex = r * columns + c

        return cellColorIndex
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapRecognizer.minimumPressDuration = 0
        addGestureRecognizer(tapRecognizer)

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(tapped(_:)))
        addGestureRecognizer(panRecognizer)

        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let tapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapRecognizer.minimumPressDuration = 0
        addGestureRecognizer(tapRecognizer)

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(tapped(_:)))
        addGestureRecognizer(panRecognizer)

        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        let cellWidth = bounds.width / CGFloat(columns)
        let cellHeight = bounds.height / CGFloat(rows)
        let size = min(cellWidth, cellHeight)
        
        for c in 0..<columns {
            for r in 0..<rows {
                let cellColorIndex = r * columns + c
                let cellColor = ActionKit.colors[cellColorIndex]
                let cellFrame = CGRect(x: CGFloat(c) * cellWidth + (cellWidth - size) / 2,
                                       y: CGFloat(r) * cellHeight + (cellHeight - size) / 2,
                                       width: size,
                                       height: size).insetBy(dx: 5, dy: 5)
                
                if cellColorIndex == pressedColorIndex {
                    let p = UIBezierPath(ovalIn: cellFrame)
                    
                    cellColor.setFill()
                    p.fill()
                }
                else if color == cellColor {
                    //  Draw selected...
                    let p = UIBezierPath(ovalIn: cellFrame)
                    cellColor.setStroke()
                    p.lineWidth = 2
                    p.stroke()
                    
                    let p2 = UIBezierPath(ovalIn: cellFrame.insetBy(dx: 3, dy: 3))
                    cellColor.setFill()
                    p2.fill()
                }
                else {
                    //  Draw unselected
                    let p = UIBezierPath(ovalIn: cellFrame)
                    
                    cellColor.lighter(by: 10)!.setFill()
                    p.fill()
                }
            }
        }
    }

    @objc
    private func tapped(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            let colorIndex = self.colorIndex(at: sender.location(in: self))
            pressedColorIndex = colorIndex
            firstPressedColorIndex = colorIndex

        case .changed:
            let colorIndex = self.colorIndex(at: sender.location(in: self))
            pressedColorIndex = colorIndex == firstPressedColorIndex ? colorIndex : nil

        case .ended,
             .cancelled,
             .failed:
            let colorIndex = self.colorIndex(at: sender.location(in: self))
            if colorIndex == firstPressedColorIndex {
                color = ActionKit.colors[colorIndex]
            }
            pressedColorIndex = nil
            
        default:
            break
        }
    }
}


extension UIColor {
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
