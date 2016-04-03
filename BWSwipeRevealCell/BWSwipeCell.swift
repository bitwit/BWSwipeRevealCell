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
    optional func swipeCellDidPassThreshold(cell: BWSwipeCell)
}

public class BWSwipeCell:UITableViewCell {
    
    // The interaction type for this table cell
    public var type:BWSwipeCellType = .SpringRelease
    
    // The allowable swipe direction(s)
    public var revealDirection: BWSwipeCellRevealDirection = .Both
    
    // The current state of the cell (either normal or past a threshold)
    public private(set) var state: BWSwipeCellState = .Normal
    
    // The point at which pan elasticity starts, and `state` changes. Defaults to the height of the `UITableViewCell` (i.e. when it form a perfect square)
    public lazy var threshold: CGFloat = {
        return self.frame.height
    }()
    
    // A number between 0 and 1 to indicate progress toward reaching threshold in the current swiping direction. Useful for changing UI gradually as the user swipes.
    public var progress: CGFloat {
        get {
            let progress = abs(self.contentView.frame.origin.x) / self.threshold
            return (progress > 1) ? 1 : progress
        }
    }
    
    // Should we allow the cell to be pulled past the threshold at all? (.SwipeThrough cells will ignore this)
    public var shouldExceedThreshold: Bool = true
    
    // Control how much elastic resistance there is past threshold, if it can be exceeded. Default is `0.7` and `1.0` would mean no elastic resistance
    public var panElasticityFactor: CGFloat = 0.7
    
    // Length of the animation on release
    public var animationDuration: Double = 0.2
    
    // BWSwipeCell Delegate
    public weak var delegate: BWSwipeCellDelegate?
    
    private lazy var releaseCompletionBlock:((Bool) -> Void)? = {
        return {
            [weak self] (finished: Bool) in
            
            guard let this = self else { return }
            
            this.delegate?.swipeCellDidCompleteRelease?(this)
            this.cleanUp()
        }
    }()
    
    // MARK: - Swipe Cell Functions
    
    public func initialize() {
        self.selectionStyle = .None
        self.contentView.backgroundColor = UIColor.whiteColor()
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(BWSwipeCell.handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
        
        let backgroundView: UIView = UIView(frame: self.frame)
        backgroundView.backgroundColor = UIColor.whiteColor()
        self.backgroundView = backgroundView
    }
    
    public func cleanUp() {
        self.state = .Normal
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
            let previousState = state
            if point.x >= self.threshold {
                self.state = .PastThresholdLeft
            }
            else if point.x < -self.threshold {
                self.state = .PastThresholdRight
            }
            else {
                self.state = .Normal
            }
            
            if self.state != .Normal && self.state != previousState {
                self.delegate?.swipeCellDidPassThreshold?(self)
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