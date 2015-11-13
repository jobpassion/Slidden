//
//  KeyboardViewController.swift
//  TrypeKeyboard
//
//  Created by Daniel Brim on 9/3/14.
//  Copyright (c) 2014 db. All rights reserved.
//

import UIKit
var cachedKeyboardView:KeyboardView? = nil
var cachedKeyboard = 0
//var cachedKeyboardViewController:UIInputViewController? = nil

public class KeyboardViewController: UIInputViewController, KeyboardViewDelegate, KeyboardViewDatasource {

    public enum Mode {
        case Alphabet
        case NumberSymbols1
        case NumberSymbols2
        case Wubi
    }
    
    public var keyboardView: KeyboardView!
    public var textDocument: KeyboardTextDocument!
    public var autoShifted: Bool = true
    public var mode = Mode.Wubi

    public var shouldLayoutKeyboardConstraintsAutomatically: Bool = true
    
    private var layoutConstrained: Bool = false
    private var spaceWaiting: Bool = false
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        //println(cachedKeyboardView)
        
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        textDocument = KeyboardTextDocument(proxy: proxy)

        setupKeyboard()
        self.keyboardView.reloadKeys()
        //if(cachedKeyboard == 0){
        //    self.keyboardView.reloadKeys()
        //}else{
        //    println(self.keyboardView.keyRows[0].count)
        //}
        //cachedKeyboard = 1
    }
    
    /// Setup a view with the standard defaults
    func setupKeyboard() {
        
        //if((cachedKeyboardView) == nil){
        //    cachedKeyboardView = KeyboardView()
        //}
        //self.keyboardView = cachedKeyboardView
        self.keyboardView = KeyboardView()
        self.keyboardView.delegate = self
        self.keyboardView.datasource = self
        self.keyboardView.currentLanguage = .English_US
        self.keyboardView.backgroundColor = UIColor.lightGrayColor()
        
        self.view.addSubview(keyboardView)
        self.view.setNeedsUpdateConstraints()
        //if(cachedKeyboard == 0){
        //    self.view.setNeedsUpdateConstraints()
        //}
    }
    
    ///MARK: Keyboard Datasource
    public func numberOfRowsInKeyboardView(keyboardView: KeyboardView) -> Int {
        return 0
    }
    
    public func keyboardView(keyboardView: KeyboardView, numberOfKeysInRow row:Int) -> Int {
        return 0
    }
    
    public func keyboardView(keyboardView: KeyboardView, keyAtIndexPath indexPath: NSIndexPath) -> KeyboardKeyView? {
        return nil
    }
    
    ///MARK: View Layout
    //for test
    public override func updateViewConstraints() {
        // Add custom view sizing constraints here
        super.updateViewConstraints()
        
        if !layoutConstrained {
            
            if shouldLayoutKeyboardConstraintsAutomatically {
                let left = NSLayoutConstraint(item: self.keyboardView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
                let top = NSLayoutConstraint(item: self.keyboardView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0)
                let right = NSLayoutConstraint(item: self.keyboardView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0.0)
                let bottom = NSLayoutConstraint(item: self.keyboardView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
                left.priority = 999
                right.priority = 999
                bottom.priority = 999
                top.priority = 999
                self.view.addConstraints([left, right, top, bottom])
            }
            
            layoutConstrained = true
        }
    }

    ///MARK: Text Management
    public override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    public override func textDidChange(textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        //var textToTranslate = getProperTextFrom(textInput)
        if textDocument.text() == "" && self.mode == .Alphabet {
            autoShifted = true
        }
    }
    
    ///MARK: Key Actions
    public func keyPressed(key: KeyboardKeyView) {
        //UIDevice.currentDevice().playInputClick()
        spaceWaiting = false
        
        if let text = key.outputText {
            if key.shifted {
                textDocument.insertText(text.uppercaseString)
            } else {
                textDocument.insertText(text.lowercaseString)
            }
        }
        
        if autoShifted {
            keyboardView.setShift(false)
            autoShifted = false
        }
    }
    
    public func specialKeyPressed(key:KeyboardKeyView) {
        
    }
    
    /** 
     Default action is to delete the last character.
     */
    public func backspaceKeyPressed(key: KeyboardKeyView) {
        //UIDevice.currentDevice().playInputClick()
        spaceWaiting = false

        textDocument.deleteBackward()
        
        let char = textDocument.lastCharacter()
        
        if char == nil {
            self.autoShifted = true
            self.keyboardView.setShift(true)
        }
        else if char != " " {
            self.autoShifted = false
            self.keyboardView.setShift(false)
        }
    }
    
    /**
     Default action is to insert one blank "space" character.
    */
    public func spaceKeyPressed(key: KeyboardKeyView) {
        //UIDevice.currentDevice().playInputClick()

        if let lastChar = textDocument.lastCharacter() {
            if ["!", "?", "."].contains(lastChar) {
                autoShifted = true
                keyboardView.setShift(true)
            } else if !spaceWaiting {
                spaceWaiting = true
            } else if lastChar == " " {
                textDocument.deleteBackward()
                textDocument.insertText(".")
                autoShifted = true
                keyboardView.setShift(true)
            }
        }
        
        if self.mode != .Alphabet {
            self.mode = .Alphabet
            self.keyboardView.reloadKeys()
        }
        textDocument.insertText(" ")
    }
    
    public func shiftKeyPressed(key: KeyboardKeyView) {
        //UIDevice.currentDevice().playInputClick()
        
        keyboardView.toggleShift()
        self.autoShifted = !self.autoShifted
    }
    
    public func returnKeyPressed(key: KeyboardKeyView) {
        //UIDevice.currentDevice().playInputClick()

        textDocument.insertText("\n")
    }
    
    public func modeChangeKeyPressed(key: KeyboardKeyView) {
        //UIDevice.currentDevice().playInputClick()
        if self.mode == .Wubi {
            self.mode = .NumberSymbols1
        }else if self.mode == .Alphabet {
            self.mode = .NumberSymbols1
        } else if self.mode == .NumberSymbols1 || self.mode == .NumberSymbols2 {
            self.mode = .Wubi
            self.autoShifted = false
        }
        
        self.keyboardView.reloadKeys()
    }
    
    public func backspaceKeyUp(key: KeyboardKeyView) {
    }
    public func nextKeyboardKeyPressed(key: KeyboardKeyView) {
        //UIDevice.currentDevice().playInputClick()

        self.advanceToNextInputMode()
    }
    
    deinit {
        //self.keyboardView.removeFromSuperview()
    }
    
    //override public func alloc() -> KeyboardViewController! {
    //    return KeyboardViewController()
    //}
    //override public func `self`() -> self! {
    //    if((cachedKeyboardViewController) == nil){
    //        return super.`self`() as
    //    }
    //}
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    //override public func viewDidLayoutSubviews() {
    //    super.viewDidLayoutSubviews()
    //    self.keyboardView.setupLayout()
    //}
    //override public func viewWillAppear(animated: Bool) {
    //    super.viewWillAppear(animated)
    //    self.keyboardView.setupLayout()
    //}
}
