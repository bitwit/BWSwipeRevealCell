//
//  BWSwipeCell.swift
//  BWSwipeCell
//
//  Created by Kyle Newsome on 2015-10-20.
//  Copyright © 2015 Kyle Newsome. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol BWSwipeCellDelegate: NSObjectProtocol {
    @objc optional func swipeCellDidStartSwiping(_ cell: BWSwipeCell)
    @objc optional func swipeCellDidSwipe(_ cell: BWSwipeCell)
    @objc optional func swipeCellWillRelease(_ cell: BWSwipeCell)
    @objc optional func swipeCellDidCompleteRelease(_ cell: BWSwipeCell)
    @objc optional func swipeCellDidChangeState(_ cell: BWSwipeCell)
}

public class BWSwipeCell: UITableViewCell {
    
    public private(set) var swipeHandler: BWSwipeViewHandler!
    public var delegate: BWSwipeCellDelegate?
    
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
        
        swipeHandler = BWSwipeViewHandler(contentView: contentView, backgroundView: bv)
        swipeHandler.delegate = self
    }
}

extension BWSwipeCell: BWSwipeViewHandlerDelegate {
    
    public func swipeViewDidStartSwiping(_ handler: BWSwipeViewHandler) {
        delegate?.swipeCellDidStartSwiping?(self)
    }

    public func swipeViewDidSwipe(_ handler: BWSwipeViewHandler) {
        delegate?.swipeCellDidSwipe?(self)
    }
    
    public func swipeViewWillRelease(_ handler: BWSwipeViewHandler) {
        delegate?.swipeCellWillRelease?(self)
    }
    
    public func swipeViewDidCompleteRelease(_ handler: BWSwipeViewHandler) {
        delegate?.swipeCellDidCompleteRelease?(self)
    }
    
    public func swipeViewDidChangeState(_ handler: BWSwipeViewHandler) {
        delegate?.swipeCellDidChangeState?(self)
    }
    
}
