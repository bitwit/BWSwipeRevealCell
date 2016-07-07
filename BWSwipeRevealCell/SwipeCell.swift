//
//  BWSwipeCell.swift
//  BWSwipeCell
//
//  Created by Kyle Newsome on 2015-10-20.
//  Copyright © 2015 Kyle Newsome. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol SwipeCellDelegate: NSObjectProtocol {
    @objc optional func swipeCellDidStartSwiping(_ cell: SwipeCell)
    @objc optional func swipeCellDidSwipe(_ cell: SwipeCell)
    @objc optional func swipeCellWillRelease(_ cell: SwipeCell)
    @objc optional func swipeCellDidCompleteRelease(_ cell: SwipeCell)
    @objc optional func swipeCellDidChangeState(_ cell: SwipeCell)
}

public class SwipeCell: UITableViewCell {
    
    public private(set) var swipeHandler: SwipeHandler!
    public var delegate: SwipeCellDelegate?
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override public func prepareForReuse() {
        
        super.prepareForReuse()
        swipeHandler.cleanUp()
    }
    
    public func initialize() {
        
        contentView.backgroundColor = UIColor.white()
        
        let bv:UIView
        if let b = backgroundView {
            bv = b
        } else {
            bv = UIView(frame: self.frame)
            bv.backgroundColor = UIColor.white()
            backgroundView = bv
        }
        
        swipeHandler = SwipeHandler(contentView: contentView, backgroundView: bv)
        swipeHandler.delegate = self
    }
}

extension SwipeCell: SwipeHandlerDelegate {
    
    public func swipeHandlerDidStartSwiping(_ handler: SwipeHandler) {
        delegate?.swipeCellDidStartSwiping?(self)
    }

    public func swipeHandlerDidSwipe(_ handler: SwipeHandler) {
        delegate?.swipeCellDidSwipe?(self)
    }
    
    public func swipeHandlerWillRelease(_ handler: SwipeHandler) {
        delegate?.swipeCellWillRelease?(self)
    }
    
   public func swipeHandlerDidCompleteRelease(_ handler: SwipeHandler) {
        delegate?.swipeCellDidCompleteRelease?(self)
    }
    
    public func swipeHandlerDidChangeState(_ handler: SwipeHandler) {
        delegate?.swipeCellDidChangeState?(self)
    }
    
}
