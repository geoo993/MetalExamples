//
//  BoxViewController.swift
//  MetalByRaywenderlich.com
//
//  Created by GEORGE QUENTIN on 16/08/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import UIKit
import MetalKit
import AppCore

class BoxViewController: UIViewController {

    @IBOutlet weak var metalKitView: MTKView!

    var renderer: BoxRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We initialize our renderer object with the MTKView it will be drawing into
        renderer = BoxRenderer(mtkView: metalKitView)
    }

}
