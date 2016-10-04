//
//  ViewController.swift
//  AnnimationTester
//
//  Created by Marc Van Olmen on 10/3/16.
//  Copyright © 2016 Marc Van Olmen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var greybox: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    
        self.panGesture = UIPanGestureRecognizer(target:self, action:#selector(onPanUpdate))
        self.panGesture.delegate = self;
        self.view.addGestureRecognizer(self.panGesture)
    }
    
    func createAnim() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath:"position.y")
        
        animation.fromValue = self.greybox.frame.origin.y;
        animation.toValue = 0
        animation.duration = 2;
        return animation
    }

    
    @IBAction func startAction(_ sender: AnyObject) {
        // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/CreatingBasicAnimations/CreatingBasicAnimations.html
        
        /*
 If you want to chain two animations together so that one starts when the other finishes, do not use animation notifications. Instead, use the beginTime property of your animation objects to start each one at the desired time. To chain two animations together, set the start time of the second animation to the end time of the first animation. For more information about animation and timing values, see Customizing the Timing of an Animation.
 
*/
        let animation = self.createAnim()
        animation.beginTime = 0
        animation.delegate = self // This is not called
        
        let animation2 = self.createAnim()
        animation2.beginTime = 2.0;
        animation2.speed = -1;

        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = 4
        groupAnimation.animations = [ animation, animation2]
        groupAnimation.delegate = self // this delegate will be called.
        
        self.greybox.layer.add(groupAnimation, forKey: "Custom Animation")
        self.greybox.layer.speed = 1.3
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
            NSLog("begin")
            break
        case .changed:
            NSLog("changed")
            break
        case .failed, .cancelled,.ended:
            NSLog("end")
            break
        default:
            break
        }
    }

}

