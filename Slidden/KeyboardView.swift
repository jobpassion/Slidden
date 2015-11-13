
//
//  KeyboardView.swift
//  Trype
//
//  Created by Daniel Brim on 9/3/14.
//  Copyright (c) 2014 db. All rights reserved.
//

import UIKit

public protocol KeyboardViewDatasource {
    func numberOfRowsInKeyboardView(keyboardView: KeyboardView) -> Int
    func keyboardView(keyboardView: KeyboardView, numberOfKeysInRow row:Int) -> Int
    func keyboardView(keyboardView: KeyboardView, keyAtIndexPath indexPath: NSIndexPath) -> KeyboardKeyView?
}

@objc
public protocol KeyboardViewDelegate {
    
    optional func keyPressed(key: KeyboardKeyView)
    optional func specialKeyPressed(key: KeyboardKeyView)
    optional func backspaceKeyPressed(key: KeyboardKeyView)
    optional func backspaceKeyUp(key: KeyboardKeyView)
    optional func spaceKeyPressed(key: KeyboardKeyView)
    optional func shiftKeyPressed(key: KeyboardKeyView)
    optional func returnKeyPressed(key: KeyboardKeyView)
    optional func modeChangeKeyPressed(key: KeyboardKeyView)
    optional func nextKeyboardKeyPressed(key: KeyboardKeyView)
    optional func keyClickSound()
}

public class KeyboardView: UIView {

    var backgroundImage: UIImage?
    var currentLanguage: KeyboardLanguage!
    
    var datasource: KeyboardViewDatasource?
    var delegate: KeyboardViewDelegate?
    
    var keyRows: Array<Array<KeyboardKeyView>>!
    private var layoutConstrained: Bool = false
    
    ///MARK: Setup
    convenience init() {
        self.init()
        setup()
    }
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        keyRows = Array<Array<KeyboardKeyView>>()
        self.currentLanguage = KeyboardLanguage.English_US
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func reloadKeys() {
        // Remove existing keys
        removeKeys()
        keyRows = Array<Array<KeyboardKeyView>>()
        
        if let numRows = datasource?.numberOfRowsInKeyboardView(self) {
            for rowIndex in 0..<numRows {
                if let numKeys = datasource?.keyboardView(self, numberOfKeysInRow: rowIndex) {
                    for keyIndex in 0..<numKeys {
                        if let keyView = datasource?.keyboardView(self, keyAtIndexPath: NSIndexPath(forItem: keyIndex, inSection: rowIndex)) {
                            addKey(keyView, row: rowIndex)
                        }
                    }
                }
            }
        }
        
        layoutConstrained = false
        //self.setNeedsUpdateConstraints()
        //self.setupLayout()
        //self.setNeedsLayout()
    }
    
    public func reloadKeyAtIndexpath(indexPath: NSIndexPath) {
        
    }
    var layoutCount = 0
    
    public func setupLayout(){
        //layoutCount = layoutCount + 1
        //if layoutCount < 3{
        //    return
        //}
        
            var lastRowView: UIView? = nil
            var keyboardHeight:Double = 270
        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            keyboardHeight = 352
        }

            let keyboardWidth:Double = Double(UIScreen.mainScreen().bounds.width)
            for (rowIndex, keyRow) in keyRows.enumerate() {
                var lastKeyView: UIView? = nil
                var lastX = 0.0
                for (keyIndex, key) in keyRow.enumerate() {
                    
                    //key.setTranslatesAutoresizingMaskIntoConstraints(false)
                    //key.frame = CGRectMake(100, 100, 100, 100)
                    //continue
                    
                    var relativeWidth: CGFloat = 0.0;
                    switch key.type! {
                    case .ModeChange:
                        relativeWidth = 1/8
                    case .KeyboardChange:
                        relativeWidth = 1/8
                    case .Space:
                        relativeWidth = 4/8
                    case .Return:
                        relativeWidth = 2/8
                    case .BlankType1:
                        relativeWidth = 1/20
                    //case .Backspace:
                    //    relativeWidth = 2/10
                    default:
                        //relativeWidth = 1/10
                        relativeWidth = 0.0
                    }
                    let x = lastX
                    var y = 0.0
                    var width = 0.0
                    var height = 0.0
                    switch rowIndex {
                    case 0:
                        y = keyboardHeight * 0.18
                    default:
                        y = keyboardHeight * 0.18 + Double(rowIndex) * keyboardHeight * (1 - 0.18)/4
                    }
                    height = keyboardHeight * (1 - 0.18)/4
                    if(relativeWidth == 0.0){
                        width = keyboardWidth / Double(keyRow.count)
                    }else{
                        width = keyboardWidth * Double(relativeWidth)
                    }
                    lastX = lastX + width
                    //key.backgroundColor = UIColor.randomColor()
                    key.frame = CGRectMake(CGFloat(x), CGFloat(y), CGFloat(width), CGFloat(height))
                    //key.setupLayout()
                }
            }
    }
    
    
    ///MARK: Layout
    override public func updateConstraints() {
        super.updateConstraints()
        print("updating constraints in keyboardView")
        return
        
        if !layoutConstrained {
            var lastRowView: UIView? = nil
            var lastX = 0.0
            let keyboardHeight:Double = 270
            let keyboardWidth:Double = Double(UIScreen.mainScreen().bounds.width)
            for (rowIndex, keyRow) in keyRows.enumerate() {
                var lastKeyView: UIView? = nil
                for (keyIndex, key) in keyRow.enumerate() {
                    
                    key.translatesAutoresizingMaskIntoConstraints = false
                    
                    var relativeWidth: CGFloat = 0.0;
                    switch key.type! {
                    case .ModeChange:
                        relativeWidth = 1/8
                    case .KeyboardChange:
                        relativeWidth = 1/8
                    case .Space:
                        relativeWidth = 4/8
                    case .Return:
                        relativeWidth = 2/8
                    case .BlankType1:
                        relativeWidth = 1/20
                    //case .Backspace:
                    //    relativeWidth = 2/10
                    default:
                        //relativeWidth = 1/10
                        relativeWidth = 0.0
                    }
                    
                    
                    if let lastView = lastKeyView {
                        let left = NSLayoutConstraint(item: key, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: lastView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
                        let top = NSLayoutConstraint(item: key, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: lastView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
                        let bottom = NSLayoutConstraint(item: key, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: lastView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
                        var width: NSLayoutConstraint?
                        if relativeWidth == 0.0 {
                            width = NSLayoutConstraint(item: key, attribute: .Width, relatedBy: .Equal, toItem: lastView, attribute: .Width, multiplier: 1.0, constant: 0.0)
                        } else {
                            width = NSLayoutConstraint(item: key, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: relativeWidth, constant: 0.0)
                        }
                        
                        self.addConstraints([left, top, bottom, width!])
                    } else {
                        let leftEdge = NSLayoutConstraint(item: key, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
                        self.addConstraint(leftEdge)
                        
                        if let lastRow = lastRowView {
                            let top = NSLayoutConstraint(item: key, attribute: .Top, relatedBy:.Equal, toItem: lastRow, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
                            let height = NSLayoutConstraint(item: key, attribute: .Height, relatedBy: .Equal, toItem: lastRow, attribute: .Height, multiplier: 1.0, constant: 0.0)

                            self.addConstraints([top, height])
                        } else {
                            let topEdge =  NSLayoutConstraint(item: key, attribute: .Top, relatedBy:.Equal, toItem: self, attribute: .Bottom, multiplier: 0.18, constant: 0)
                            self.addConstraint(topEdge)
                        }
                        
                        if rowIndex == keyRows.count - 1 {
                            let bottomEdge = NSLayoutConstraint(item: key, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
                            self.addConstraint(bottomEdge)
                        }
                        lastRowView = key
                    }
                    
                    if keyIndex == keyRow.count - 1 {
                        let rightEdge = NSLayoutConstraint(item: key, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
                        self.addConstraint(rightEdge)
                    }
                    
                    lastKeyView = key
                }
            }
            layoutConstrained = true
        }
    }
    
    public func addKey(key: KeyboardKeyView, row: Int) {
        if((key.type) != nil && key.type != .BlankType1){
        key.addTarget(self, action: "keyPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        key.addTarget(self, action: "keyPressedTouchDown:", forControlEvents: UIControlEvents.TouchDown)
        key.addTarget(self, action: "keyPressedTouchUpOutside:", forControlEvents: UIControlEvents.TouchUpOutside)
        }
        if keyRows.count <= row {
            for i in self.keyRows.count...row {
                keyRows.append(Array<KeyboardKeyView>())
            }
        }
        
        keyRows[row].append(key)
        addSubview(key)
    }
    
    ///MARK: Public
    public func setShift(shift: Bool) {
        for row in keyRows {
            for key in row {
                if key.type == KeyboardKeyView.KeyType.Character {
                    key.shifted = shift
                }
            }
        }

    }
    
    public func toggleShift() {
        for row in keyRows {
            for key in row {
                if key.type == KeyboardKeyView.KeyType.Character {
                    key.shifted = !key.shifted
                }
            }
        }
    }
    
    ///MARK: Private Helper Methods
    func keyUp(sender: AnyObject!) {
        if let key: KeyboardKeyView = sender as? KeyboardKeyView {
            if let type = key.type {
                switch type {
                case .Backspace:
                    delegate?.backspaceKeyUp!(key)
                default:
                    delegate?.keyPressed!(key)
                }
            }
        }
    }
    func keyPressedTouchUpOutside(sender: AnyObject!) {
        if let key: KeyboardKeyView = sender as? KeyboardKeyView {
            if let type = key.type {
                switch type {
                //case .Character:
                //    delegate?.keyPressed!(key)
                //case .SpecialCharacter:
                //    delegate?.specialKeyPressed!(key)
                //case .Shift:
                //    delegate?.shiftKeyPressed!(key)
                case .Backspace:
                    delegate?.backspaceKeyUp!(key)
                //case .ModeChange:
                //    delegate?.modeChangeKeyPressed!(key)
                //case .KeyboardChange:
                //    delegate?.nextKeyboardKeyPressed!(key)
                //case .Return:
                //    delegate?.returnKeyPressed!(key)
                //case .Space:
                //    delegate?.spaceKeyPressed!(key)
                //default:
                //    delegate?.keyPressed!(key)
                //}
                default:
                    let a=1
                }
            }
        }
    }
    
    func keyPressedTouchDown(sender: AnyObject!) {
        delegate?.keyClickSound!()
        if let key: KeyboardKeyView = sender as? KeyboardKeyView {
            if let type = key.type {
                switch type {
                case .Character:
                    delegate?.keyPressed!(key)
                case .SpecialCharacter:
                    delegate?.specialKeyPressed!(key)
                case .Shift:
                    delegate?.shiftKeyPressed!(key)
                case .Backspace:
                    delegate?.backspaceKeyPressed!(key)
                case .ModeChange:
                    delegate?.modeChangeKeyPressed!(key)
                //case .KeyboardChange:
                //    delegate?.nextKeyboardKeyPressed!(key)
                case .Return:
                    delegate?.returnKeyPressed!(key)
                case .Space:
                    delegate?.spaceKeyPressed!(key)
                default:
                    delegate?.keyPressed!(key)
                }
            }
        }
    }
    func keyPressed(sender: AnyObject!) {
        if let key: KeyboardKeyView = sender as? KeyboardKeyView {
            if let type = key.type {
                switch type {
                //case .Character:
                //    delegate?.keyPressed!(key)
                //case .SpecialCharacter:
                //    delegate?.specialKeyPressed!(key)
                //case .Shift:
                //    delegate?.shiftKeyPressed!(key)
                case .Backspace:
                    delegate?.backspaceKeyUp!(key)
                //case .ModeChange:
                //    delegate?.modeChangeKeyPressed!(key)
                case .KeyboardChange:
                    delegate?.nextKeyboardKeyPressed!(key)
                //case .Return:
                //    delegate?.returnKeyPressed!(key)
                //case .Space:
                //    delegate?.spaceKeyPressed!(key)
                //default:
                //    delegate?.keyPressed!(key)
                //}
                default:
                    let a=1
                }
            }
        }
    }
    
    private func constraintsForKey(key: KeyboardKeyView, lastKeyView: KeyboardKeyView, lastRowView: KeyboardKeyView) -> [NSLayoutConstraint] {
        let constraints: [NSLayoutConstraint] = []
        
        return constraints
    }
    
    private func removeKeys() {
        var constraints = [NSLayoutConstraint]()
        for row in keyRows {
            for key in row {
                if key.hasAmbiguousLayout() {
                    print(" *** Ambiguous layout: \(key) \n")
                }
                key.removeConstraints(key.constraints)
                key.removeFromSuperview()
            }
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
    }
}
