//
//  HomeViewController.swift
//  SwiftSyft
//
//  Created by SashaBataieva on 01/20/2020.
//  Copyright (c) 2020 mjjimenez. All rights reserved.
//

import UIKit

enum StaticHomeScreenStrings {
    static let headerDescription = "syft.js/grid.js testing"
    static let description = """
            This is a demo using @SwiftSyft@ from @OpenMined@ to execute a multi-worker protocol hosted on grid.js
    """
    static let swiftSyft = "SwiftSyft"
    static let swiftSyftKey = "@SwiftSyft@"
    static let swiftSyftURL = "https://github.com/OpenMined/SwiftSyft"
    static let openMined = "OpenMined"
    static let openMinedKey = "@OpenMined@"
    static let openMinedURL = "https://github.com/OpenMined/grid.js"
    static let socketURL = "wss://localhost:3000"
    static let protocolID = "50801316202"
    static let connectButtonText = "Connect to grid.js server"
    static let messagePlaceholder = "Enter your message ..."
    static let sendButtonText = "Send message"
}

class HomeViewController: UIViewController, UITextViewDelegate {
    var isConnected = false

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerDescriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var socketURLTextField: UITextField!
    @IBOutlet weak var protocolIDTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        headerDescriptionLabel.text = StaticHomeScreenStrings.headerDescription

        descriptionTextView.text = StaticHomeScreenStrings.description
        descriptionTextView.attributedText = descriptionTextView.attributedText?
            .fillInLink(StaticHomeScreenStrings.swiftSyftKey,
                        with: StaticHomeScreenStrings.swiftSyft,
                        url: StaticHomeScreenStrings.swiftSyftURL)
            .fillInLink(StaticHomeScreenStrings.openMinedKey,
                        with: StaticHomeScreenStrings.openMined,
                        url: StaticHomeScreenStrings.openMinedURL)

        socketURLTextField.text = StaticHomeScreenStrings.socketURL
        protocolIDTextField.text = StaticHomeScreenStrings.protocolID

        connectButton.titleLabel?.text = StaticHomeScreenStrings.connectButtonText
        messageTextView.text = StaticHomeScreenStrings.messagePlaceholder
        messageTextView.textColor = UIColor.lightGray
        messageTextView.delegate = self
        sendButton.titleLabel?.text = StaticHomeScreenStrings.sendButtonText

        if isConnected {
            messageTextView.isHidden = false
            sendButton.isHidden = false
        } else {
            messageTextView.isHidden = true
            sendButton.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func connectPressed(_ sender: Any) {
        guard !socketURLTextField.text!.isEmpty else {
            print("Socket URL is empty!")
            return
        }
        guard !protocolIDTextField.text!.isEmpty else {
            print("Protocol ID is empty!")
            return
        }
        print("Socket URL: \(socketURLTextField.text!), Protocol ID: \(protocolIDTextField.text!)")

        isConnected = true
        messageTextView.isHidden = false
        sendButton.isHidden = false
    }
    @IBAction func sendPressed(_ sender: Any) {
        guard !messageTextView.text!.isEmpty else {
            print("Message is empty!")
            return
        }
        print("Message: \(messageTextView.text!)")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = StaticHomeScreenStrings.messagePlaceholder
            textView.textColor = UIColor.lightGray
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            messageTextView.contentInset = .zero
        } else {
            let userInfo = notification.userInfo!
            var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey]
                as? NSValue)!.cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)

            var contentInset: UIEdgeInsets = self.scrollView.contentInset
            contentInset.bottom = keyboardFrame.size.height
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                   bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        messageTextView.scrollIndicatorInsets = messageTextView.contentInset

        let selectedRange = messageTextView.selectedRange
        messageTextView.scrollRangeToVisible(selectedRange)
    }
}

extension NSAttributedString {
    func fillInLink(_ placeholder: String, with link: String, url: String) -> NSAttributedString {
        let mutableAttr = NSMutableAttributedString(attributedString: self)
        let linkAttr = NSAttributedString(string: link, attributes: [NSAttributedString.Key.link: URL(string: url)!])
        let placeholderRange = (self.string as NSString).range(of: placeholder)

        mutableAttr.replaceCharacters(in: placeholderRange, with: linkAttr)
        return mutableAttr
    }
}
