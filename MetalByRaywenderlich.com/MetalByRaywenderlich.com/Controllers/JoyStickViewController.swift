//
//  JoyStickViewController.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 07/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit

class JoyStickViewController: UIViewController {

    @IBOutlet weak var leftMagnitude: UILabel!
    @IBOutlet weak var leftTheta: UILabel!
    @IBOutlet weak var rightMagnitude: UILabel!
    @IBOutlet weak var rightTheta: UILabel!
    @IBOutlet weak var leftJoyStick: JoyStickView!
    @IBOutlet weak var rightJoyStick: JoyStickView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        // Create 'fixed' joystick
        //
//        let rect = view.frame
//        let size = CGSize(width: 80.0, height: 80.0)
//        let joystick1Frame = CGRect(origin: CGPoint(x: 40.0,
//                                                    y: (rect.height - size.height - 40.0)),
//                                    size: size)
//        let joystick1 = JoyStickView(frame: joystick1Frame)
        leftJoyStick.monitor = { angle, displacement in
            self.leftTheta.text = "\(angle)"
            self.leftMagnitude.text = "\(displacement)"
        }

//        view.addSubview(joystick1)

        //leftJoyStick.movable = false
        //leftJoyStick.alpha = 1.0
        //leftJoyStick.baseAlpha = 0.5 // let the background bleed thru the base
        //leftJoyStick.handleTintColor = UIColor.green // Colorize the handle

//        let joystick2Frame = CGRect(origin: CGPoint(x: (rect.width - size.width - 40.0),
//                                                    y: (rect.height - size.height - 40.0)),
//                                    size: size)
//        let joystick2 = JoyStickView(frame: joystick2Frame)
        rightJoyStick.monitor = { angle, displacement in
            self.rightTheta.text = "\(angle)"
            self.rightMagnitude.text = "\(displacement)"
        }

//        view.addSubview(joystick2)

        //rightJoyStick.movable = false
        //rightJoyStick.alpha = 1.0
        //rightJoyStick.baseAlpha = 0.5 // let the background bleed thru the base
        //rightJoyStick.handleTintColor = UIColor.blue // Colorize the handle
    }

}


