//
//  SwipeRevealCell.swift
//  SwipeCell
//
//  Created by Kyle Newsome on 2015-11-10.
//  Copyright © 2015 Kyle Newsome. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol SwipeRevealCellDelegate:SwipeCellDelegate {
    @objc optional func swipeRevealCell(_ cell: SwipeCell, activatedAction isActionLeft: Bool)
}

public class SwipeRevealCell: SwipeCell {
    
    public var backViewbackgroundColor: UIColor = UIColor(white: 0.92, alpha: 1)
    private var _backView: UIView?
    public var backView: UIView? {
        if _backView == nil {
            _backView = UIView(frame: self.contentView.bounds)
            _backView!.backgroundColor = self.backViewbackgroundColor
        }
        return _backView
    }
    public var shouldCleanUpBackView = true
    
    public var bgViewInactiveColor: UIColor = UIColor.gray()
    public var bgViewLeftColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    public var bgViewRightColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    
    public var bgViewLeftImage: UIImage?
    public var bgViewRightImage: UIImage?
    
    private var _leftBackButton: UIButton?
    public var leftBackButton:UIButton? {
        if _leftBackButton == nil {
            _leftBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height))
            _leftBackButton!.setImage(self.bgViewLeftImage, for: UIControlState())
            _leftBackButton!.addTarget(self, action: #selector(SwipeRevealCell.leftButtonTapped), for: .touchUpInside)
            _leftBackButton!.tintColor = UIColor.white()
            _leftBackButton!.contentMode = .center
            self.backView!.addSubview(_leftBackButton!)
        }
        return _leftBackButton
    }
    
    private var _rightBackButton: UIButton?
    public var rightBackButton:UIButton? {
        if _rightBackButton == nil {
            _rightBackButton = UIButton(frame: CGRect(x: self.contentView.frame.maxX, y: 0, width: self.frame.height, height: self.frame.height))
            _rightBackButton!.setImage(self.bgViewRightImage, for: UIControlState())
            _rightBackButton!.addTarget(self, action: #selector(SwipeRevealCell.rightButtonTapped), for: .touchUpInside)
            _rightBackButton!.tintColor = UIColor.white()
            _rightBackButton!.contentMode = .center
            self.backView!.addSubview(_rightBackButton!)
        }
        return _rightBackButton
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let bgView: UIView = UIView(frame: self.frame)
        self.selectedBackgroundView = bgView
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        let bgView: UIView = UIView(frame: self.frame)
        self.selectedBackgroundView = bgView
    }
    
    public override func prepareForReuse() {
        
        super.prepareForReuse()
        
        if self.shouldCleanUpBackView {
            _leftBackButton?.removeFromSuperview()
            _leftBackButton = nil
            _rightBackButton?.removeFromSuperview()
            _rightBackButton = nil
            _backView?.removeFromSuperview()
            _backView = nil
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override public func swipeHandlerDidStartSwiping(_ handler: SwipeHandler) {
        
        super.swipeHandlerDidStartSwiping(handler)
        self.backgroundView!.addSubview(self.backView!)
    }
    
    override public func swipeHandlerWillRelease(_ handler: SwipeHandler) {
        
        super.swipeHandlerWillRelease(handler)
        
        if handler.config.type == .springRelease || handler.state == .normal {
            self.animateCellSpringRelease()
        } else if handler.config.type == .slidingDoor {
            self.animateCellSlidingDoor()
        } else {
            self.animateCellSwipeThrough()
        }
    }
    
    override public func swipeHandlerDidSwipe(_ handler: SwipeHandler) {
        
        super.swipeHandlerDidSwipe(handler)
        
        let position = handler.contentView.frame.origin
        animateContentViewForPoint(position, progress: handler.progress)
    }
    
    public func animateContentViewForPoint(_ point: CGPoint, progress:CGFloat) {
        
        if point.x > 0 {
            let frame = self.leftBackButton!.frame
            let minX = getBackgroundViewImagesMaxX(point.x)
            let minY = frame.minY
            self.leftBackButton!.frame = CGRect(x: minX, y: minY, width: frame.width, height: frame.height)
            self.leftBackButton?.alpha = progress
            UIView.transition(with: _leftBackButton!, duration: 0.13, options: .transitionCrossDissolve, animations: {
                if point.x >= self.frame.height {
                    self.backView?.backgroundColor = self.bgViewLeftColor
                }
                else {
                    self.backView?.backgroundColor = self.bgViewInactiveColor
                }
                }, completion: nil)
        } else if point.x < 0 {
            let frame = self.rightBackButton!.frame
            let maxX = getBackgroundViewImagesMaxX(point.x)
            let minY = frame.minY
            self.rightBackButton!.frame = (CGRect(x: maxX, y: minY, width: frame.width, height: frame.height))
            self.rightBackButton?.alpha = progress
            UIView.transition(with: _rightBackButton!, duration: 0.13, options: .transitionCrossDissolve, animations: {
                  if -point.x >= self.frame.height {
                      self.backView?.backgroundColor = self.bgViewRightColor
                  } else {
                      self.backView?.backgroundColor = self.bgViewInactiveColor
                  }
                }, completion: nil)
        }
    }
 
    
    // MARK: - Reveal Cell Animations
    
    public func animateCellSpringRelease() {
        
        swipeHandler.animateCellSpringRelease()
        
        let pointX = self.contentView.frame.origin.x
        UIView.animate(withDuration: swipeHandler.config.animationDuration,
            delay: 0,
            options: .curveLinear,
            animations: {
                if pointX > 0 {
                    self.leftBackButton!.frame.origin.x = -self.swipeHandler.threshold
                } else if pointX < 0 {
                    self.rightBackButton!.frame.origin.x = self.frame.maxX
                }
            }, completion: nil)
    }
    
    public func animateCellSwipeThrough() {
        
        swipeHandler.animateCellSwipeThrough()
        
        let pointX = self.contentView.frame.origin.x
        UIView.animate(withDuration: swipeHandler.config.animationDuration,
            delay: 0,
            options: .curveLinear,
            animations: {
                if pointX > 0 {
                    self.leftBackButton!.frame.origin.x = self.frame.maxX
                } else if pointX < 0 {
                    self.rightBackButton!.frame.origin.x = -self.swipeHandler.threshold
                }
            }, completion: nil)
    }
    
    public func animateCellSlidingDoor() {
        self.shouldCleanUpBackView = false
    }
    
    
    // MARK: - Reveal Cell
    
    public func getBackgroundViewImagesMaxX(_ x:CGFloat) -> CGFloat {
        if x > 0 {
            let frame = self.leftBackButton!.frame
            if swipeHandler.config.type == .swipeThrough {
                return self.contentView.frame.origin.x - frame.width
            } else {
                return min(self.contentView.frame.minX - frame.width, 0)
            }
        } else {
            let frame = self.rightBackButton!.frame
            if swipeHandler.config.type == .swipeThrough {
                return self.contentView.frame.maxX
            } else {
                return max(self.frame.maxX - frame.width, self.contentView.frame.maxX)
            }
        }
    }
    
    public func leftButtonTapped () {
        self.shouldCleanUpBackView = true
        self.animateCellSpringRelease()
        
        let delegate = self.delegate as? SwipeRevealCellDelegate
        
        delegate?.swipeRevealCell?(self, activatedAction: true)
    }
    
    public func rightButtonTapped () {
        self.shouldCleanUpBackView = true
        self.animateCellSpringRelease()
        let delegate = self.delegate as? SwipeRevealCellDelegate
        
        delegate?.swipeRevealCell?(self, activatedAction: false)
    }
}
