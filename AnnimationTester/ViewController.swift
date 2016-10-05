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

    private var panGesture: UIPanGestureRecognizer!
    fileprivate let animationDuration:CFTimeInterval = 2.0
    fileprivate var fromOffset: CGFloat = 0.0
    fileprivate var toOffset: CGFloat = 60.0
    
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
        animation.beginTime = 0
        animation.delegate = self // This is not called
        
        let animation2 = self.createAnim()
        animation2.beginTime = self.animationDuration
        animation2.speed = -1

        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = 4
        groupAnimation.animations = [ animation, animation2]
        groupAnimation.delegate = self // this delegate will be called.
        
        self.greybox.layer.add(groupAnimation, forKey: "Custom Animation")

        self.greybox.layer.speed = 1
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
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func onPanUpdate(_ gesture: UIPanGestureRecognizer) {
        switch (gesture.state) {
        case .began:
            self.fromOffset  = max(self.greybox.layer.presentation()?.frame.origin.y ?? self.toOffset,self.toOffset)
            let animation = self.createAnim()

            self.greybox.layer.add(animation, forKey: "Custom Animation")
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
            if self.greybox.layer.timeOffset < self.animationDuration {
                guard let presentationLayer = self.greybox.layer.presentation() else { break }
                
                
                let animation = self.createAnim()
                let olderTimeOffset = self.greybox.layer.timeOffset
                
                animation.delegate = self
                animation.fromValue = presentationLayer.frame.origin.y
                animation.duration = self.animationDuration - olderTimeOffset
                self.greybox.layer.position.y = self.toOffset
                
                //            self.greybox.layer.frame = presentationLayer.frame
                self.greybox.layer.add(animation, forKey: "Custom Animation")
                self.greybox.layer.speed = 1
                
            }
            break
        default:
            break
        }
    }

}

