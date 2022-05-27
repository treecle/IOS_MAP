//
//  SplashView.swift
//  wbs
//
//  Created by Home on 05/11/2019.
//  Copyright © 2019 Sidory. All rights reserved.
//

import UIKit

class SplashView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit(){
        let view = Bundle.main.loadNibNamed("SplashView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        self.imageView.image = UIImage(named: "intro_01")
    }
    
    public func startAnimation(duration: TimeInterval = 0.4, delay: TimeInterval = 1.5) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            self.imageView.alpha = 0.0
        }) { (succsee) in
            self.removeFromSuperview()
        }
    }
}
