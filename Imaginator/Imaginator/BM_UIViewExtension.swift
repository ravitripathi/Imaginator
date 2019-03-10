//
//  UIViewExtension.swift
//  Feed Me
//
/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

enum VerticalLocation: String {
    case bottom
    case top
}

extension UIView {
    
    // MARK: - Lock View
    
    func isLocked() -> Bool {
        if let _ = viewWithTag(10) {
            return true
        }
        return false
    }
    
    @objc func lock() {
        self.lock(nil)
    }
    
    func lock(_ navigationItem: UINavigationItem?) {
        self.lock(navigationItem, activityIndicator: true)
    }
    
    func lock(_ navigationItem: UINavigationItem?, activityIndicator: Bool) {
        self.lock(navigationItem, activityIndicator: activityIndicator, tapRecognizer: nil)
    }
    
    func lock(_ navigationItem: UINavigationItem?, activityIndicator: Bool, tapRecognizer: UITapGestureRecognizer?) {
        self.lock(navigationItem, activityIndicator: activityIndicator, tapRecognizer: tapRecognizer, alpha: 0.75)
    }
    
    func lock(_ navigationItem: UINavigationItem?, activityIndicator: Bool, tapRecognizer: UITapGestureRecognizer?, alpha: CGFloat) {
        DispatchQueue.main.async {
            if let _ = self.viewWithTag(10) {
                //View is already locked
            } else {
                UIApplication.shared.beginIgnoringInteractionEvents()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                let lockView = UIView(frame: CGRect(x: self.bounds.minX,
                                                    y: self.bounds.minY,
                                                    width: UIScreen.main.bounds.width,
                                                    height: UIScreen.main.bounds.height))
                lockView.backgroundColor = UIColor(white: 0.0, alpha: alpha)
                lockView.tag = 10
                lockView.alpha = 0.0
                
                if tapRecognizer != nil {
                    lockView.addGestureRecognizer(tapRecognizer!)
                }
                
                if activityIndicator == true {
                    let activity = UIActivityIndicatorView(style: .white)
                    activity.hidesWhenStopped = true
                    activity.center = lockView.center
                    activity.translatesAutoresizingMaskIntoConstraints = false
                    
                    lockView.addSubview(activity)
                    activity.startAnimating()
                    
                    var constraints: [NSLayoutConstraint] = []
                    constraints.append(NSLayoutConstraint(item: activity, attribute: .centerX, relatedBy: .equal, toItem: lockView, attribute: .centerX, multiplier: 1, constant: 0))
                    constraints.append(NSLayoutConstraint(item: activity, attribute: .centerY, relatedBy: .equal, toItem: lockView, attribute: .centerY, multiplier: 1, constant: 0))
                    NSLayoutConstraint.activate(constraints)
                }
                self.addSubview(lockView)
                
                UIView.animate(withDuration: 0.2, animations: {
                    lockView.alpha = 1.0
                })
            }
        }
        
    }

    @objc func unlock() {
        self.unlock(nil)
    }
    
    func unlock(_ navigationItem: UINavigationItem?) {
        DispatchQueue.main.async {
            if let lockView = self.viewWithTag(10) {
                UIApplication.shared.endIgnoringInteractionEvents()
                UIView.animate(withDuration: 0.2, animations: {
                    lockView.alpha = 0.0
                }, completion: { finished in
                    lockView.removeFromSuperview()
                })
            }
        }
    }
    
    
    // MARK: - Transparent Screen
    
    func showTransparentScreen(_ screenView: UIView, tapRecognizer: UITapGestureRecognizer?) {
        if let _ = viewWithTag(20) {
            // transparent screen already showed
            return
        }
        
        screenView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        screenView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        screenView.backgroundColor = UIColor.clear
        screenView.tag = 20
        
        if tapRecognizer != nil {
            screenView.addGestureRecognizer(tapRecognizer!)
        }
        
        self.addSubview(screenView)
        
        UIView.animate(withDuration: 0.5, animations: {
            screenView.alpha = 1.0
        }) 
    }
    
    func hideTransparentScreen() {
        if let screenView = viewWithTag(20) {
            UIView.animate(withDuration: 0.2, animations: {
                screenView.alpha = 0.0
            }, completion: { finished in
                screenView.removeFromSuperview()
            }) 
        }
    }
    
    
    // MARK: - Popup Screen
    
    func showPopupScreen(_ screenView: UIView, width: CGFloat, height: CGFloat) {
        if let _ = viewWithTag(30) {
            return
        }
        
        // add transparent view on the back
        let lockView = UIView(frame: bounds)
        lockView.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
        lockView.tag = 31
        lockView.alpha = 0.0
        lockView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(lockView)
        
        // add the pop-up screen
        screenView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        screenView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        screenView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        screenView.tag = 30
        self.addSubview(screenView)
        
        UIView.animate(withDuration: 0.5, animations: {
            lockView.alpha = 1.0
            screenView.alpha = 1.0
        }) 
    }
    func showPopupForDropDownScreen(_ screenView: UIView, width: CGFloat, height: CGFloat) {
        if let _ = viewWithTag(30) {
            return
        }
        
        // add transparent view on the back
        let lockView = UIView(frame: bounds)
        lockView.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
        lockView.tag = 31
        lockView.alpha = 0.0
        lockView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(lockView)
        
        // add the pop-up from bottom
        let y : CGFloat = lockView.frame.height - screenView.frame.size.height
        screenView.frame = CGRect(x: 0, y: y, width: lockView.frame.width, height: height)
        screenView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        screenView.tag = 30
        self.addSubview(screenView)
        
        UIView.animate(withDuration: 0.5, animations: {
            lockView.alpha = 1.0
            screenView.alpha = 1.0
        }) 
    }
    
    func hidePopupScreen() {
        if let screenView = viewWithTag(30) {
            UIView.animate(withDuration: 0.2, animations: {
                screenView.alpha = 0.0
            }, completion: { finished in
                screenView.removeFromSuperview()
            }) 
        }
        if let screenView = viewWithTag(31) {
            UIView.animate(withDuration: 0.2, animations: {
                screenView.alpha = 0.0
            }, completion: { finished in
                screenView.removeFromSuperview()
            }) 
        }
    }
    
    
    // MARK: - Fade
    
    func fadeOut(_ duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        }) 
    }
    
    func fadeIn(_ duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        }) 
    }
    
    class func viewFromNibName(_ name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        return views!.first as? UIView
    }
    
    
   
    // http://stackoverflow.com/a/21107340/897733
    
    func resizeToFitSubviews() {
        
        let subviewsRect = subviews.reduce(CGRect.zero) {
            $0.union($1.frame)
        }
        
        let fix = subviewsRect.origin
        subviews.forEach {
            $0.frame.offsetBy(dx: -fix.x, dy: -fix.y)
        }
        
        frame.offsetBy(dx: fix.x, dy: fix.y)
        frame.size = subviewsRect.size
    }
    
    
    //
    
    func stackViewWithSubView(subView: Any) {
        let topConstraint = NSLayoutConstraint(item: subView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: subView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: subView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: subView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        
        self.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        self.layoutIfNeeded()
    }
    
    func removeSubViewWithTag(tag: Int) {
        if let subView = viewWithTag(tag) {
            subView.removeFromSuperview()
        }
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    // View Masking
    
    func mask(withRect rect: CGRect, inverse: Bool = false) {
        
        let path = UIBezierPath(rect: rect)
        
        let maskLayer = CAShapeLayer()
        
        if inverse {
            path.append(UIBezierPath(rect: self.bounds))
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        }
        maskLayer.path = path.cgPath
        
        self.layer.mask = maskLayer
        
    }
    
    func mask(withPath path: UIBezierPath, inverse: Bool = false) {
        let path = path
        let maskLayer = CAShapeLayer()
        
        if inverse {
            path.append(UIBezierPath(rect: self.bounds))
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        }
        
        maskLayer.path = path.cgPath
        
        self.layer.mask = maskLayer
    }
    
    func anchor(top : NSLayoutYAxisAnchor?, left : NSLayoutXAxisAnchor?, bottom : NSLayoutYAxisAnchor?,right : NSLayoutXAxisAnchor?,paddingTop : CGFloat,paddingLeft : CGFloat,paddingBottom : CGFloat, paddingRight : CGFloat,width : CGFloat,height : CGFloat){
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top{
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let left = left{
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let right = right{
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if(width != 0){
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if(height != 0){
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchorCenterXToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    func anchorCenterYToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    func anchorCenterSuperview() {
        anchorCenterXToSuperview()
        anchorCenterYToSuperview()
    }
    
    func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
    
    func pushTransition(_ duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromTop
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.push.rawValue)
    }
    
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
   
    func addShadow(location: VerticalLocation, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0, height:CGFloat = 10.0) {
        switch location {
        case .bottom:
            addShadow(offset: CGSize(width: 0, height: height), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -height), color: color, opacity: opacity, radius: radius)
        }
    }
    
    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let border = UIView()
        self.addSubview(border)
        border.backgroundColor = color
        
        switch edge {
        case .top:
            border.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: thickness)
        case .bottom:
            border.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: thickness)
        case .left:
            border.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: thickness, height: 0)
        case .right:
            border.anchor(top: self.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: thickness, height: 0)
        default:
            break
        }
    }
    
}

