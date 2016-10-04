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

    @IBAction func startAction(_ sender: AnyObject) {

//        let animation = CABasicAnimation(keyPath:"position.y")
//            
//        animation.fromValue = self.greybox.frame.origin.y;
//        animation.toValue = 0
//        
//        animation.duration = 5;
//        animation.isRemovedOnCompletion = true;

        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = UIColor.red.cgColor
        animation.toValue = UIColor.blue.cgColor
        animation.duration = 5.0
        
        self.greybox.layer.add(animation, forKey: "Custom Animation")
        self.greybox.layer.speed = -1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

