//
//  BWSwipeCell.swift
//  BWSwipeCell
//
//  Created by Kyle Newsome on 2015-10-20.
//  Copyright © 2015 Kyle Newsome. All rights reserved.
//

import Foundation
import UIKit

//Defines the interaction type of the table cell
public enum BWSwipeCellType: Int {
    case SwipeThrough = 0 // swipes with finger and animates through
    case SpringRelease // resists pulling and bounces back
    case SlidingDoor // swipe to a stopping position where underlying buttons can be revealed
}

public enum BWSwipeCellRevealDirection {
    case None
    case Both
    case Right
    case Left
}

public enum BWSwipeCellState {
    case Normal
    case PastThresholdLeft
    case PastThresholdRight
}

@objc public protocol BWSwipeCellDelegate: NSObjectProtocol {
    optional func swipeCellDidStartSwiping(cell: BWSwipeCell)
    optional func swipeCellDidSwipe(cell: BWSwipeCell)
    optional func swipeCellWillRelease(cell: BWSwipeCell)
    optional func swipeCellDidCompleteRelease(cell: BWSwipeCell)
}

public class BWSwipeCell:UITableViewCell {
    
    public var type:BWSwipeCellType = .SpringRelease
    public var revealDirection: BWSwipeCellRevealDirection = .Both
    
    private var _state: BWSwipeCellState = .Normal
    public var state: BWSwipeCellState {
        return _state
    }
    
    //Threshold properties
    public lazy var threshold: CGFloat = {
        return self.frame.height
    }()
    public var progress: CGFloat {
        get {
            let progress = abs(self.contentView.frame.origin.x) / self.threshold
            return (progress > 1) ? 1 : progress
        }
    }
    public var shouldExceedThreshold: Bool = true
    public var panElasticityFactor: CGFloat = 0.7
    
    // Animation properties
    public var animationDuration: Double = 0.2
    // Delegate
    public weak var delegate: BWSwipeCellDelegate?
    
    private var _releaseCompletionBlock:((Bool) -> Void)?
    var releaseCompletionBlock:((Bool) -> Void)?  {
        if _releaseCompletionBlock == nil {
            _releaseCompletionBlock = {(finished: Bool) in
                self.delegate?.swipeCellDidCompleteRelease?(self)
                self.cleanUp()
            }
        }
        return _releaseCompletionBlock
    }
    
    // MARK: - Swipe Cell Functions
    
    public func initialize() {
        self.selectionStyle = .None
        self.contentView.backgroundColor = UIColor.whiteColor()
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
        
        let backgroundView: UIView = UIView(frame: self.frame)
        backgroundView.backgroundColor = UIColor.whiteColor()
        self.backgroundView = backgroundView
    }
    
    public func cleanUp() {
        _state = .Normal
    }
    
    func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        let translation: CGPoint = panGestureRecognizer.translationInView(panGestureRecognizer.view)
        var panOffset: CGFloat = translation.x
        
        // If we have elasticity to consider, do some extra calculations for panOffset
        if self.type != .SwipeThrough && abs(translation.x) > self.threshold {
            if self.shouldExceedThreshold {
                let offset: CGFloat = abs(translation.x)
                panOffset = offset - ((offset - self.threshold) * self.panElasticityFactor)
                panOffset *= translation.x < 0 ? -1.0 : 1.0
            } else {
                // If we don't allow exceeding the threshold
                panOffset = translation.x < 0 ? -self.threshold : self.threshold
            }
        }
        
        // Start, continue or complete the swipe gesture
        let actualTranslation: CGPoint = CGPointMake(panOffset, translation.y)
        if panGestureRecognizer.state == .Began && panGestureRecognizer.numberOfTouches() > 0 {
            let newTranslation = CGPointMake(self.contentView.frame.origin.x, 0)
            panGestureRecognizer.setTranslation(newTranslation, inView: panGestureRecognizer.view)
            self.didStartSwiping()
            self.animateContentViewForPoint(newTranslation)
        }
        else {
            if panGestureRecognizer.state == .Changed && panGestureRecognizer.numberOfTouches() > 0 {
                self.animateContentViewForPoint(actualTranslation)
            }
            else {
                self.resetCellPosition()
            }
        }
    }
    
    func didStartSwiping() {
        self.delegate?.swipeCellDidStartSwiping?(self)
    }
    
    public func animateContentViewForPoint(point: CGPoint) {
        if (point.x > 0 && self.revealDirection == .Left) || (point.x < 0 && self.revealDirection == .Right) || self.revealDirection == .Both {
            self.contentView.frame = CGRectOffset(self.contentView.bounds, point.x, 0)
            if point.x >= self.threshold {
                _state = .PastThresholdLeft
            }
            else if point.x < -self.threshold {
                _state = .PastThresholdRight
            }
            else {
                _state = .Normal
            }
            self.delegate?.swipeCellDidSwipe?(self)
        }
        else {
            if (point.x > 0 && self.revealDirection == .Right) || (point.x < 0 && self.revealDirection == .Left) {
                self.contentView.frame = CGRectOffset(self.contentView.bounds, 0, 0)
            }
        }
    }
    
    public func resetCellPosition() {
        self.delegate?.swipeCellWillRelease?(self)
        if self.type == .SpringRelease || self.state == .Normal {
            self.animateCellSpringRelease()
        } else if self.type == .SlidingDoor {
            self.animateCellSlidingDoor()
        } else {
            self.animateCellSwipeThrough()
        }
    }
    
    // MARK: - Reset animations
    
    func animateCellSpringRelease() {
        UIView.animateWithDuration(self.animationDuration,
            delay: 0,
            options: .CurveEaseOut,
            animations: {
                self.contentView.frame = self.contentView.bounds
            },
            completion: self.releaseCompletionBlock)
    }
    
    func animateCellSlidingDoor() {
        UIView.animateWithDuration(self.animationDuration,
            delay: 0,
            options: .AllowUserInteraction,
            animations: {
                let pointX = self.contentView.frame.origin.x
                if pointX > 0 {
                    self.contentView.frame.origin.x = self.threshold
                } else if pointX < 0 {
                    self.contentView.frame.origin.x = -self.threshold
                }
            },
            completion: self.releaseCompletionBlock)
    }
    
    func animateCellSwipeThrough() {
        UIView.animateWithDuration(self.animationDuration,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                let direction:CGFloat = (self.contentView.frame.origin.x > 0) ? 1 : -1
                self.contentView.frame.origin.x = direction * (self.contentView.bounds.width + self.threshold)
            }, completion: self.releaseCompletionBlock)
    }
    
    // MARK: - UITableViewCell Overrides
    
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
        self.cleanUp()
    }
    
    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer) && self.revealDirection != .None {
            let pan:UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let translation: CGPoint = pan.translationInView(self.superview)
            return (fabs(translation.x) / fabs(translation.y) > 1) ? true : false
        }
        return false
    }
}