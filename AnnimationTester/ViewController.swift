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

