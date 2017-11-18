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
    @objc optional func swipeCellActivatedAction(_ cell: BWSwipeCell, isActionLeft: Bool)
}

open class BWSwipeRevealCell: BWSwipeCell {
    
    open var backViewbackgroundColor: UIColor = UIColor(white: 0.92, alpha: 1)
    fileprivate var _backView: UIView?
    open var backView: UIView? {
        if _backView == nil {
            _backView = UIView(frame: self.contentView.bounds)
            _backView!.backgroundColor = self.backViewbackgroundColor
        }
        return _backView
    }
    open var shouldCleanUpBackView = true
    
    open var bgViewInactiveColor: UIColor = UIColor.gray
    open var bgViewLeftColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    open var bgViewRightColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    
    open var bgViewLeftImage: UIImage?
    open var bgViewRightImage: UIImage?
    
    fileprivate var _leftBackButton: UIButton?
    open var leftBackButton:UIButton? {
        if _leftBackButton == nil {
            _leftBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height))
            _leftBackButton!.setImage(self.bgViewLeftImage, for: .normal)
            _leftBackButton!.addTarget(self, action: #selector(BWSwipeRevealCell.leftButtonTapped), for: .touchUpInside)
            _leftBackButton!.tintColor = UIColor.white
            _leftBackButton!.contentMode = .center
            self.backView!.addSubview(_leftBackButton!)
        }
        return _leftBackButton
    }
    
    fileprivate var _rightBackButton: UIButton?
    open var rightBackButton:UIButton? {
        if _rightBackButton == nil {
            _rightBackButton = UIButton(frame: CGRect(x: self.contentView.frame.maxX, y: 0, width: self.frame.height, height: self.frame.height))
            _rightBackButton!.setImage(self.bgViewRightImage, for: .normal)
            _rightBackButton!.addTarget(self, action: #selector(BWSwipeRevealCell.rightButtonTapped), for: .touchUpInside)
            _rightBackButton!.tintColor = UIColor.white
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
    
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    open override func cleanUp() {
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
    
    open override func didStartSwiping() {
        super.didStartSwiping()
        self.backgroundView!.addSubview(self.backView!)
    }
    
    open override func animateContentViewForPoint(_ point: CGPoint) {
        super.animateContentViewForPoint(point)
        if point.x > 0 {
            let frame = self.leftBackButton!.frame
            let minX = getBackgroundViewImagesMaxX(point.x)
            let minY = frame.minY
            self.leftBackButton!.frame = CGRect(x: minX, y: minY, width: frame.width, height: frame.height)
            self.leftBackButton?.alpha = self.progress
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
            self.rightBackButton?.alpha = self.progress
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
    
    open override func animateCellSpringRelease() {
        super.animateCellSpringRelease()
        let pointX = self.contentView.frame.origin.x
        UIView.animate(withDuration: self.animationDuration,
            delay: 0,
            options: .curveLinear,
            animations: {
                if pointX > 0 {
                    self.leftBackButton!.frame.origin.x = -self.threshold
                } else if pointX < 0 {
                    self.rightBackButton!.frame.origin.x = self.frame.maxX
                }
            }, completion: nil)
    }
    
    open override func animateCellSwipeThrough() {
        super.animateCellSwipeThrough()
        let pointX = self.contentView.frame.origin.x
        UIView.animate(withDuration: self.animationDuration,
            delay: 0,
            options: .curveLinear,
            animations: {
                if pointX > 0 {
                    self.leftBackButton!.frame.origin.x = self.frame.maxX
                } else if pointX < 0 {
                    self.rightBackButton!.frame.origin.x = -self.threshold
                }
            }, completion: nil)
    }
    
    open override func animateCellSlidingDoor() {
        super.animateCellSlidingDoor()
        self.shouldCleanUpBackView = false
    }
    
    // MARK: - Reveal Cell
    
    open func getBackgroundViewImagesMaxX(_ x:CGFloat) -> CGFloat {
        if x > 0 {
            let frame = self.leftBackButton!.frame
            if self.type == .swipeThrough {
                return self.contentView.frame.origin.x - frame.width
            } else {
                return min(self.contentView.frame.minX - frame.width, 0)
            }
        } else {
            let frame = self.rightBackButton!.frame
            if self.type == .swipeThrough {
                return self.contentView.frame.maxX
            } else {
                return max(self.frame.maxX - frame.width, self.contentView.frame.maxX)
            }
        }
    }
    
    @objc open func leftButtonTapped () {
        self.shouldCleanUpBackView = true
        self.animateCellSpringRelease()
        let delegate = self.delegate as? BWSwipeRevealCellDelegate
        delegate?.swipeCellActivatedAction?(self, isActionLeft: true)
    }
    
    @objc open func rightButtonTapped () {
        self.shouldCleanUpBackView = true
        self.animateCellSpringRelease()
        let delegate = self.delegate as? BWSwipeRevealCellDelegate
        delegate?.swipeCellActivatedAction?(self, isActionLeft: false)
    }
    
}
