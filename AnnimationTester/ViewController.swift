//
//  ViewController.swift
//  AnnimationTester
//
//  Created by Marc Van Olmen on 10/3/16.
//  Copyright © 2016 Marc Van Olmen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var greybox: UIView!

    fileprivate var panGesture: UIPanGestureRecognizer!
    fileprivate let animationDuration:CFTimeInterval = 2.0
    fileprivate let animationReferenceID = "Custom Interactive Animation"
    private var fromOffset: CGFloat = 0.0
    fileprivate var toOffset: CGFloat = 60.0

    fileprivate var autoBeginTime: CFTimeInterval = 0.0
    fileprivate var autoTimeOffset: CFTimeInterval = 0.0
    fileprivate var autoReverseMode: Bool = false
    fileprivate var autoVelocity: CFTimeInterval = 1.0
    fileprivate var autoDisplayLink: CADisplayLink!
    
    fileprivate var cachedFromOffset: CGFloat {
        if self.fromOffset == 0 {
            self.fromOffset = max(self.greybox.layer.presentation()?.frame.origin.y ?? self.toOffset,self.toOffset)
        }
        return self.fromOffset
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        self.greybox.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)

        self.panGesture = UIPanGestureRecognizer(target:self, action:#selector(onPanUpdate))
        self.panGesture.delegate = self
        self.view.addGestureRecognizer(self.panGesture)
    }
    
    fileprivate func createAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath:"position.y")
        
        animation.fromValue = self.cachedFromOffset
        animation.toValue = self.toOffset
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = self.animationDuration

        return animation
    }

    @IBAction func resetAction(_ sender: AnyObject) {
        self.greybox.layer.removeAnimation(forKey: self.animationReferenceID)
        self.greybox.layer.timeOffset = 0
        self.greybox.layer.speed = 1.0
        self.view.setNeedsLayout()
    }
    
    @IBAction func startAction(_ sender: AnyObject) {
        self.resetAction(sender)
        
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            let animation = self.createAnimation()
            animation.autoreverses = true
            animation.delegate = self
            
            self.greybox.layer.timeOffset = 0
            self.greybox.layer.add(animation, forKey: self.animationReferenceID)
            self.greybox.layer.speed = 1.0
            self.panGesture.isEnabled = false
            })
    }
}

extension ViewController: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("--animation finsihed--")
        self.panGesture.isEnabled = true
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    
    func autoAnimateLoop() {

        if self.greybox.layer.timeOffset >= self.animationDuration ||
            self.greybox.layer.timeOffset <= 0 {
            self.autoDisplayLink.invalidate()
            self.panGesture.isEnabled = true
            // I needed to remove this because gave issues in Simulator, if I drag
            // again. This will reset the animation also...
//            self.greybox.layer.removeAnimation(forKey: self.animationReferenceID)
            print("--removed auto animation--")
            return
        }

        let elapsedTime = (CACurrentMediaTime() - self.autoBeginTime) * self.autoVelocity

        self.greybox.layer.timeOffset = self.autoReverseMode ?
            max(self.autoTimeOffset - elapsedTime, 0.0) :
            min(self.autoTimeOffset + elapsedTime, self.animationDuration)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func onPanUpdate(_ gesture: UIPanGestureRecognizer) {
        switch (gesture.state) {
        case .began:
            let animation = self.createAnimation()
            self.greybox.layer.timeOffset = 0
            self.greybox.layer.add(animation, forKey: self.animationReferenceID)
            self.greybox.layer.speed = 0
            break
        case .changed:
            let offset = gesture.translation(in: self.view)
            
            var offsetProgress = max(0,-offset.y / (self.cachedFromOffset - self.toOffset))
            offsetProgress = min(1.0,offsetProgress)

            self.greybox.layer.timeOffset = self.animationDuration * CFTimeInterval(offsetProgress)
            break
        case .failed, .cancelled,.ended:
            self.autoBeginTime = CACurrentMediaTime()
            self.autoTimeOffset = self.greybox.layer.timeOffset
            self.autoVelocity = 2.0
            self.autoReverseMode = self.greybox.layer.timeOffset < self.animationDuration / 2
            self.panGesture.isEnabled = false
            self.autoDisplayLink = CADisplayLink(target: self, selector: #selector(autoAnimateLoop))
            self.autoDisplayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
            break
        default:
            break
        }
    }
}

