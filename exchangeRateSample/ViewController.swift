//
//  ViewController.swift
//  exchangeRateSample
//
//  Created by はるふ on 2016/09/12.
//  Copyright © 2016年 ha1f. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var fromValueTextField: UITextField!
    @IBOutlet weak var toValueTextField: UITextField!
    
    let model = ExchangeRateModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func onTranslateButtonPressed(sender: UIButton) {
        // textFieldの値をDoubleに変換
        let fromValue = NSString(string: fromValueTextField.text ?? "").doubleValue
        model.fetch {
            if let v = self.model.translate(from: .USD, to: .JPY, value: fromValue) {
                self.toValueTextField.text = "\(v)"
            } else {
                self.toValueTextField.text = "error"
            }
        }
    }

}

