//
//  InputTextView.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-05.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

protocol InputTextViewProtocol: class {
    func sendInputText(_ text:String)
}

class InputTextView: UIView {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    weak var delegate:InputTextViewProtocol?
    
    override func awakeFromNib() {
        textField.text = nil
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textDidChange()
    }
    
    @IBAction func handleSendButton(_ sender: Any) {
        guard let text = textField.text else { return }
        delegate?.sendInputText(text)
        textField.text = nil
        textDidChange()
    }
    
    @objc func textDidChange() {
        sendButton.isEnabled = textField.text != nil && textField.text != ""
    }
    
}
