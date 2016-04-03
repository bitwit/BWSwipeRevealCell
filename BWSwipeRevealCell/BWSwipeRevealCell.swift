//
//  BWSwipeRevealCell.swift
//  BWSwipeCell
//
//  Created by Kyle Newsome on 2015-11-10.
//  Copyright © 2015 Kyle Newsome. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol BWSwipeRevealCellDelegate:BWSwipeCellDelegate {
    optional func swipeCellActivatedAction(cell: BWSwipeCell, isActionLeft: Bool)
}

public class BWSwipeRevealCell: BWSwipeCell {
    
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
    
    public var bgViewInactiveColor: UIColor = UIColor.grayColor()
    public var bgViewLeftColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    public var bgViewRightColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    
    public var bgViewLeftImage: UIImage?
    public var bgViewRightImage: UIImage?
    
    private var _leftBackButton: UIButton?
    var leftBackButton:UIButton? {
        if _leftBackButton == nil {
            _leftBackButton = UIButton(frame: CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame)))
            _leftBackButton!.setImage(self.bgViewLeftImage, forState: .Normal)
            _leftBackButton!.addTarget(self, action: #selector(BWSwipeRevealCell.leftButtonTapped), forControlEvents: .TouchUpInside)
            _leftBackButton!.tintColor = UIColor.whiteColor()
            _leftBackButton!.contentMode = .Center
            self.backView!.addSubview(_leftBackButton!)
        }
        return _leftBackButton
    }
    
    private var _rightBackButton: UIButton?
    var rightBackButton:UIButton? {
        if _rightBackButton == nil {
            _rightBackButton = UIButton(frame: CGRectMake(CGRectGetMaxX(self.contentView.frame), 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame)))
            _rightBackButton!.setImage(self.bgViewRightImage, forState: .Normal)
            _rightBackButton!.addTarget(self, action: #selector(BWSwipeRevealCell.rightButtonTapped), forControlEvents: .TouchUpInside)
            _rightBackButton!.tintColor = UIColor.whiteColor()
            _rightBackButton!.contentMode = .Center
            self.backView!.addSubview(_rightBackButton!)
        }
        return _rightBackButton
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
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
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public override func cleanUp() {
        super.cleanUp()
        if self.shouldCleanUpBackView {
            _leftBackButton?.removeFromSuperview()
            _leftBackButton = nil
            _rightBackButton?.removeFromSuperview()
            _rightBackButton = nil
            _backView?.removeFromSuperview()
            _backView = nil
        }
    }
    
    override func didStartSwiping() {
        super.didStartSwiping()
        self.backgroundView!.addSubview(self.backView!)
    }
    
    public override func animateContentViewForPoint(point: CGPoint) {
        super.animateContentViewForPoint(point)
        if point.x > 0 {
            let frame = self.leftBackButton!.frame
            let minX = getBackgroundViewImagesMaxX(point.x)
            let minY = CGRectGetMinY(frame)
            self.leftBackButton!.frame = CGRectMake(minX, minY, CGRectGetWidth(frame), CGRectGetHeight(frame))
            self.leftBackButton?.alpha = self.progress
            UIView.transitionWithView(_leftBackButton!, duration: 0.13, options: .TransitionCrossDissolve, animations: {
                if point.x >= CGRectGetHeight(self.frame) {
                    self.backView?.backgroundColor = self.bgViewLeftColor
                }
                else {
                    self.backView?.backgroundColor = self.bgViewInactiveColor
                }
                }, completion: nil)
        } else if point.x < 0 {
            let frame = self.rightBackButton!.frame
            let maxX = getBackgroundViewImagesMaxX(point.x)
            let minY = CGRectGetMinY(frame)
            self.rightBackButton!.frame = (CGRectMake(maxX, minY, CGRectGetWidth(frame), CGRectGetHeight(frame)))
            self.rightBackButton?.alpha = self.progress
            UIView.transitionWithView(_rightBackButton!, duration: 0.13, options: .TransitionCrossDissolve, animations: {
                  if -point.x >= CGRectGetHeight(self.frame) {
                      self.backView?.backgroundColor = self.bgViewRightColor
                  } else {
                      self.backView?.backgroundColor = self.bgViewInactiveColor
                  }
                }, completion: nil)
        }
    }
    
    // MARK: - Reveal Cell Animations
    
    override func animateCellSpringRelease() {
        super.animateCellSpringRelease()
        let pointX = self.contentView.frame.origin.x
        UIView.animateWithDuration(self.animationDuration,
            delay: 0,
            options: .CurveLinear,
            animations: {
                if pointX > 0 {
                    self.leftBackButton!.frame.origin.x = -self.threshold
                } else if pointX < 0 {
                    self.rightBackButton!.frame.origin.x = CGRectGetMaxX(self.frame)
                }
            }, completion: nil)
    }
    
    override func animateCellSwipeThrough() {
        super.animateCellSwipeThrough()
        let pointX = self.contentView.frame.origin.x
        UIView.animateWithDuration(self.animationDuration,
            delay: 0,
            options: .CurveLinear,
            animations: {
                if pointX > 0 {
                    self.leftBackButton!.frame.origin.x = CGRectGetMaxX(self.frame)
                } else if pointX < 0 {
                    self.rightBackButton!.frame.origin.x = -self.threshold
                }
            }, completion: nil)
    }
    
    override func animateCellSlidingDoor() {
        super.animateCellSlidingDoor()
        self.shouldCleanUpBackView = false
    }
    
    // MARK: - Reveal Cell
    
    func getBackgroundViewImagesMaxX(x:CGFloat) -> CGFloat {
        if x > 0 {
            let frame = self.leftBackButton!.frame
            if self.type == .SwipeThrough {
                return self.contentView.frame.origin.x - frame.width
            } else {
                return min(CGRectGetMinX(self.contentView.frame) - CGRectGetWidth(frame), 0)
            }
        } else {
            let frame = self.rightBackButton!.frame
            if self.type == .SwipeThrough {
                return CGRectGetMaxX(self.contentView.frame)
            } else {
                return max(CGRectGetMaxX(self.frame) - CGRectGetWidth(frame), CGRectGetMaxX(self.contentView.frame))
            }
        }
    }
    
    func leftButtonTapped () {
        self.shouldCleanUpBackView = true
        self.animateCellSpringRelease()
        let delegate = self.delegate as? BWSwipeRevealCellDelegate
        delegate?.swipeCellActivatedAction?(self, isActionLeft: true)
    }
    
    func rightButtonTapped () {
        self.shouldCleanUpBackView = true
        self.animateCellSpringRelease()
        let delegate = self.delegate as? BWSwipeRevealCellDelegate
        delegate?.swipeCellActivatedAction?(self, isActionLeft: false)
    }
    
}