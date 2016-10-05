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
    fileprivate var fromOffset: CGFloat = 0.0
    fileprivate var toOffset: CGFloat = 60.0

    fileprivate var autoBeginTime: CFTimeInterval = 0.0
    fileprivate var autoTimeOffset: CFTimeInterval = 0.0
    fileprivate var autoReverseMode: Bool = false
    fileprivate var autoVelocity: CFTimeInterval = 1.0
    fileprivate var autoDisplayLink: CADisplayLink!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    

        self.panGesture = UIPanGestureRecognizer(target:self, action:#selector(onPanUpdate))
        self.panGesture.delegate = self
        self.view.addGestureRecognizer(self.panGesture)
    }
    
    func createAnim() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath:"position.y")
        
        animation.fromValue = self.fromOffset
        animation.toValue = self.toOffset
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = 2

        return animation
    }

    @IBAction func resetAction(_ sender: AnyObject) {
        self.greybox.layer.removeAllAnimations()
        self.view.setNeedsLayout()
    }
    
    @IBAction func startAction(_ sender: AnyObject) {
        // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/CreatingBasicAnimations/CreatingBasicAnimations.html
        
        /*
 If you want to chain two animations together so that one starts when the other finishes, do not use animation notifications. Instead, use the beginTime property of your animation objects to start each one at the desired time. To chain two animations together, set the start time of the second animation to the end time of the first animation. For more information about animation and timing values, see Customizing the Timing of an Animation.
 
*/
        self.fromOffset  = max(self.greybox.layer.presentation()?.frame.origin.y ?? self.toOffset,self.toOffset)

        let animation = self.createAnim()
        animation.autoreverses = true
        animation.speed = 1.0
        
        self.greybox.layer.timeOffset = 0
        self.greybox.layer.add(animation, forKey: self.animationReferenceID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print(")animation finsihed")
    }
    
}


extension ViewController: UIGestureRecognizerDelegate {

    
    func autoAnimateLoop() {

        if self.greybox.layer.timeOffset >= self.animationDuration ||
            self.greybox.layer.timeOffset <= 0 {
            self.autoDisplayLink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
            self.panGesture.isEnabled = true
            self.greybox.layer.removeAnimation(forKey: self.animationReferenceID)
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
            self.fromOffset  = max(self.greybox.layer.presentation()?.frame.origin.y ?? self.toOffset,self.toOffset)
            let animation = self.createAnim()
            self.greybox.layer.timeOffset = 0
            self.greybox.layer.add(animation, forKey: self.animationReferenceID)
            self.greybox.layer.speed = 0
            break
        case .changed:
            let offset = gesture.translation(in: self.view)
            let temp = max(self.toOffset, self.fromOffset + offset.y)
            let transitionProgress = min(temp, self.fromOffset)
            
            let progress = (self.fromOffset == self.toOffset) ? 1.0 : 1.0 - min(1.0,(transitionProgress - self.toOffset) / (self.fromOffset - self.toOffset))

            self.greybox.layer.timeOffset = self.animationDuration * CFTimeInterval(progress)
            break
        case .failed, .cancelled,.ended:
            self.autoBeginTime = CACurrentMediaTime()
            self.autoTimeOffset = self.greybox.layer.timeOffset
            if self.greybox.layer.timeOffset < self.animationDuration / 2  {
                // move backward
                self.autoReverseMode = true
            } else {
                // move forward
                self.autoReverseMode = false
            }
            self.panGesture.isEnabled = false
            self.autoDisplayLink = CADisplayLink(target: self, selector: #selector(autoAnimateLoop))
            self.autoDisplayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
            break
        default:
            break
        }
    }

}

