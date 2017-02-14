//
//  SFGaugeView.swift
//  SFGaugeView
//
//  Created by Krishnan Sriram Rama on 2/5/17.
//  Copyright © 2017 Krishnan Sriram Rama. All rights reserved.
//

import UIKit
import CoreGraphics

protocol SFGaugeViewDelegate: NSObjectProtocol {
    func sfGaugeView(_ gaugeView: SFGaugeView, didChangeLevel level: Int)
}

class SFGaugeView: UIView {
    var maxlevel: Int {
        get {
            return 10
        }
    }
    var minlevel: Int = 0
    private var _needleColor: UIColor?
    var needleColor: UIColor! {
        set(newColor) {
            _needleColor = newColor
        }
        get {
            if let _ = self._needleColor {
                return _needleColor
            }
            return UIColor(red: CGFloat(76 / 255.0), green: CGFloat(177 / 255.0), blue: CGFloat(88 / 255.0), alpha: CGFloat(1))
        }
    }
    private var _bgColor: UIColor?
    var bgColor: UIColor! {
        set(newColor) {
            _bgColor = newColor
        }
        get {
            if let _ = self._bgColor {
                return _bgColor!
            }
            return UIColor(red: CGFloat(211 / 255.0), green: CGFloat(211 / 255.0), blue: CGFloat(211 / 255.0), alpha: CGFloat(1))
            
        }
    }
    var isHideLevel: Bool = false
    var minImage: String = ""
    var maxImage: String = ""
    var isAutoAdjustImageColors: Bool = false
    
    var _currentLevel: Int = 0
    var currentLevel: Int {
        get {
            var level: Int = -1
            let levelSection: CGFloat = (.pi - (CUTOFF * 2)) / CGFloat(self.scale)
            var currentSection: CGFloat = CGFloat(-M_PI_2) + CUTOFF
            for i in 1...self.scale {
                if self.currentRadian >= currentSection && self.currentRadian < (currentSection + levelSection) {
                    level = i
                    break
                }
                currentSection += levelSection
            }
            if self.currentRadian >= (CGFloat(M_PI_2) - CUTOFF) {
                level = self.scale + 1
            }
            level = level + self.minlevel - 1
            if self.oldLevel != level && (self.delegate != nil) && (self.delegate?.responds(to: Selector(("sfGaugeView:didChangeLevel:"))))! {
                self.delegate?.sfGaugeView(self, didChangeLevel: level)
            }
            self.oldLevel = level
            return level
        }
        set {
            if _currentLevel >= self.minlevel && _currentLevel <= self.maxlevel {
                self.oldLevel = _currentLevel
                let range: CGFloat = .pi - (CUTOFF * 2)
                if _currentLevel != self.scale / 2 {
                    self.currentRadian = (CGFloat(newValue) * range) / CGFloat(self.scale) - (range / 2)
                }
                else {
                    self.currentRadian = 0.0
                }
                self.setNeedsDisplay()
            }
            
        }
    }
    
    var needleRadius: CGFloat {
        get {
            return self.bounds.size.height * 0.01
        }
    }
    
    var bgRadius: CGFloat {
        get {
            return self.centerX() - (self.centerX() * 0.1)
        }
    }
    
    var currentRadian: CGFloat = 0.0
    var oldLevel: Int = 0
    var scale: Int {
        get {
            return self.maxlevel - self.minlevel
        }
    }
    
    weak var delegate: SFGaugeViewDelegate?
    
    let CUTOFF: CGFloat = 0.0
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.isOpaque = false
        self.contentMode = .redraw
        self.currentRadian = 0
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePan)))
    }
    
    override func awakeFromNib() {
        self.setup()
    }
    // MARK: drawing
    
    override func draw(_ rect: CGRect) {
        self.drawBg()
        self.drawNeedle()
        self.drawLabels()
        self.drawImageLabels()
    }
    
    func drawImageLabels() {
        if self.minImage.isEmpty == false && self.maxImage.isEmpty == false {
            var badImg: UIImage?
            var goodImg: UIImage?
            if self.isAutoAdjustImageColors {
                badImg = self.imageNamed(self.minImage, with: self.needleColor, drawAsOverlay: false)
                goodImg = self.imageNamed(self.maxImage, with: self.needleColor, drawAsOverlay: false)
            }
            else {
                badImg = UIImage(named: self.minImage)
                goodImg = UIImage(named: self.maxImage)
            }
            let scaleFactor: CGFloat? = (self.bounds.size.width / (badImg?.size.width)!) / 6
            badImg?.draw(in: CGRect(x: CGFloat(self.centerX() - self.bgRadius), y: CGFloat(self.centerY() - (badImg?.size.height)! * scaleFactor!), width: CGFloat((badImg?.size.width)! * scaleFactor!), height: CGFloat((badImg?.size.height)! * scaleFactor!)))
            goodImg?.draw(in: CGRect(x: CGFloat(self.centerX() + self.bgRadius - ((goodImg?.size.width)! * scaleFactor!)), y: CGFloat(self.centerY() - (goodImg?.size.height)! * scaleFactor!), width: CGFloat((goodImg?.size.width)! * scaleFactor!), height: CGFloat((goodImg?.size.height)! * scaleFactor!)))
        }
    }
    
    func drawLabels() {
        var fontSize: CGFloat = self.bounds.size.width / 18
        var font = UIFont(name: "Arial", size: fontSize)
        var textColor: UIColor? = self.needleColor
        var stringAttrs: NSDictionary = [NSFontAttributeName: font!, NSForegroundColorAttributeName: textColor!]
        if !self.isHideLevel {
            fontSize = self.needleRadius + 5
            font = UIFont(name: "Arial", size: fontSize)
            textColor = self.bgColor
            stringAttrs = [NSFontAttributeName: font!, NSForegroundColorAttributeName: textColor!]
            let levelStr = NSAttributedString(string: "\(UInt(self.currentLevel))", attributes: stringAttrs as? [String : Any])
            let levelStrPoint = CGPoint(x: CGFloat(self.centerView().x - levelStr.size().width / 2), y: CGFloat(self.centerView().y - levelStr.size().height / 2))
            levelStr.draw(at: levelStrPoint)
        }
    }
    
    func drawBg() {
        let starttime: CGFloat = .pi + CUTOFF
        let endtime: CGFloat = 2 * .pi - CUTOFF
        let endtime1: CGFloat = (CGFloat(3 * M_PI_2)) - 0.5
        let endtime2: CGFloat = (CGFloat(3 * M_PI_2)) - 0.01
        let endtime3: CGFloat = (CGFloat(3 * M_PI_2)) + 0.6
    
        let bgEndAngle: CGFloat = CGFloat(3 * M_PI_2)
        
        if bgEndAngle > starttime {
            let bgPath = UIBezierPath()
            bgPath.move(to: self.centerView())
            bgPath.addArc(withCenter: self.centerView(), radius: self.bgRadius, startAngle: starttime, endAngle: endtime1, clockwise: true)
            bgPath.addLine(to: self.centerView())
            UIColor.green.setFill()
//            self.bgColor.setFill()
            bgPath.fill()
        }
        
        let bgPath2 = UIBezierPath()
        bgPath2.move(to: self.centerView())
        bgPath2.addArc(withCenter: self.centerView(), radius: self.bgRadius, startAngle: endtime1, endAngle: endtime2, clockwise: true)
//        self.bgColor.setFill()
        UIColor.yellow.setFill()
        bgPath2.fill()
        
        let bgPath3 = UIBezierPath()
        bgPath3.move(to: self.centerView())
        bgPath3.addArc(withCenter: self.centerView(), radius: self.bgRadius, startAngle: endtime2, endAngle: endtime3, clockwise: true)
        //        self.bgColor.setFill()
        UIColor.yellow.setFill()
        bgPath3.fill()
        
        let bgPath4 = UIBezierPath()
        bgPath4.move(to: self.centerView())
        bgPath4.addArc(withCenter: self.centerView(), radius: self.bgRadius, startAngle: endtime3, endAngle: endtime, clockwise: true)
        //        self.bgColor.setFill()
        UIColor.red.setFill()
        bgPath4.fill()
        
        
        let bgPathInner = UIBezierPath()
        bgPathInner.move(to: self.centerView())
        
        let innerRadius: CGFloat = self.bgRadius - (self.bgRadius * 0.3)
        bgPathInner.addArc(withCenter: self.centerView(), radius: innerRadius, startAngle: starttime, endAngle: endtime, clockwise: true)
        bgPathInner.addLine(to: self.centerView())

        UIColor.white.setStroke()
        UIColor.clear.setFill()
        bgPathInner.fill()
    }
    
    func imageNamed(_ name: String, with color: UIColor, drawAsOverlay overlay: Bool) -> UIImage {
        // load the image
        let img = UIImage(named: name)
        // begin a new image context, to draw our colored image onto
        UIGraphicsBeginImageContextWithOptions((img?.size)!, false, UIScreen.main.scale)
        // get a reference to that context we created
        let context: CGContext? = UIGraphicsGetCurrentContext()
        // set the fill color
        color.setFill()
        // translate/flip the graphics context (for transforming from CG* coords to UI* coords
        context?.translateBy(x: 0, y: (img?.size.height)!)
        context?.scaleBy(x: 1.0, y: -1.0)
        // set the blend mode to overlay, and the original image
        //kCGBlendModeOverlay
        context!.setBlendMode(CGBlendMode.overlay)
        let rect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat((img?.size.width)!), height: CGFloat((img?.size.height)!))
        
        if overlay {
            context?.draw((img?.cgImage)!, in: rect)
        }
        // set a mask that matches the shape of the image, then draw (overlay) a colored rectangle
        context?.clip(to: rect, mask: (img?.cgImage)!)
        context?.addRect(rect)
        context?.drawPath(using: CGPathDrawingMode.fill)
        // generate a new UIImage from the graphics context we drew onto
        let coloredImg: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //return the color-burned image
        return coloredImg!
    }
    
    func drawNeedle() {
        let distance: CGFloat = self.bgRadius + (self.bgRadius * 0.1)
        let starttime: CGFloat = 0
        let endtime: CGFloat = .pi
        let topSpace: CGFloat = (distance * 0.1) / 6
        let center: CGPoint = self.centerView()
//        let topPoint = CGPoint(x: CGFloat(self.centerView().x), y: CGFloat(self.centerView().y - distance))
        let topPoint1 = CGPoint(x: CGFloat(self.centerView().x - topSpace), y: CGFloat(self.centerView().y - distance + (distance * 0.1)))
//        let topPoint2 = CGPoint(x: CGFloat(self.centerView().x + topSpace), y: CGFloat(self.centerView().y - distance + (distance * 0.1)))
        let finishPoint = CGPoint(x: CGFloat(self.centerView().x + self.needleRadius), y: CGFloat(self.centerView().y))
        let needlePath = UIBezierPath()
        //empty path
        needlePath.move(to: center)
        var next: CGPoint = CGPoint()
        next.x = center.x + self.needleRadius * cos(starttime)
        next.y = center.y + self.needleRadius * sin(starttime)
        
        needlePath.addLine(to: next)
        //go one end of arc
        needlePath.addArc(withCenter: center, radius: self.needleRadius, startAngle: starttime, endAngle: endtime, clockwise: true)
        //add the arc
        needlePath.addLine(to: topPoint1)
//        needlePath.addQuadCurve(to: topPoint2, controlPoint: topPoint)
        needlePath.addLine(to: finishPoint)
        var translate = CGAffineTransform(translationX: -1 * (self.bounds.origin.x + self.centerView().x), y: -1 * (self.bounds.origin.y + self.centerView().y))
        needlePath.apply(translate)
        let rotate = CGAffineTransform(rotationAngle: self.currentRadian)
        needlePath.apply(rotate)
        translate = CGAffineTransform(translationX: (self.bounds.origin.x + self.centerView().x), y: (self.bounds.origin.y + self.centerView().y))
        needlePath.apply(translate)
//        self.needleColor.setFill()
        UIColor.black.setFill()
        needlePath.fill()
    }
    
    func lighterColor(for c: UIColor) -> UIColor? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if c.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: CGFloat(min(r + 0.1, 1.0)), green: CGFloat(min(g + 0.1, 1.0)), blue: CGFloat(min(b + 0.1, 1.0)), alpha: a)
        }
        return nil
    }
    
    func handlePan(_ gesture: UIPanGestureRecognizer) {
        let currentPosition: CGPoint = gesture.location(in: self)
        if gesture.state == .changed {
            self.currentRadian = self.calculateRadian(currentPosition)
            self.setNeedsDisplay()
            let level = self.currentLevel
            debugPrint("Current level is \(level)")
        }
    }
    
    func calculateRadian(_ pos: CGPoint) -> CGFloat {
        let tmpPoint = CGPoint(x: CGFloat(pos.x), y: CGFloat(self.centerView().y))
        // return zero if needle in center
        if pos.x == self.centerView().x {
            return 0
        }
        if pos.y > self.centerView().y {
            return self.currentRadian
        }
        // calculate distance between pos and center
        let p12: CGFloat = self.calculateDistance(from: pos, to: self.centerView())
        // calculate distance between pos and tmpPoint
        let p23: CGFloat = self.calculateDistance(from: pos, to: tmpPoint)
        // cacluate distance between tmpPont and center
        var p13: CGFloat = 0
        p13 = self.calculateDistance(from: tmpPoint, to: self.centerView())
        
        var result:CGFloat = CGFloat(M_PI_2) - acos(((p12 * p12) + (p13 * p13) - (p23 * p23))/(2 * p12 * p13))
        if pos.x <= self.centerView().x {
            result = result * -1
        }
        if result > (CGFloat(M_PI_2) - CGFloat(CUTOFF)) {
            return CGFloat(M_PI_2) - CGFloat(CUTOFF)
        }
        
        if result < (CGFloat(-M_PI_2) + CUTOFF) {
            return CGFloat(-M_PI_2) + CUTOFF
        }
        return result
    }
    
    func calculateDistance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        let dx: CGFloat = p2.x - p1.x
        let dy: CGFloat = p2.y - p1.y
        let distance: CGFloat = sqrt(dx * dx + dy * dy)
        return distance
    }
    
    func centerView() -> CGPoint {
        return CGPoint(x: CGFloat(self.centerX()), y: CGFloat(self.centerY()))
    }
    
    func centerY() -> CGFloat {
        return self.bounds.size.height - (self.bounds.size.height * 0.2)
    }
    
    func centerX() -> CGFloat {
        return self.bounds.size.width / 2
    }
    
}
