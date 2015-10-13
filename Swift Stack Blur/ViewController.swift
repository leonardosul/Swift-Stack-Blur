//
//  ViewController.swift
//  Swift Stack Blur
//
//  Created by Leonard O'Sullivan on 23/06/2015.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var blurImage: UIImageView!
    
    @IBOutlet weak var BlurSlideView: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newImage = UIImage(named: "Lakes")
        
        self.blurImage.image = newImage
        
        self.BlurSlideView.continuous = false
    }
    
    @IBAction func blurSlideChanged(sender: UISlider) {
        
        let currentValue : Int = Int(sender.value)
        
        let blurredImage = UIImage(named: "Lakes")
        
        self.blurImage.image = blurredImage!.swiftStackBlur(currentValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

