import Foundation
import UIKit


@objc public protocol SwipeHandlerDelegate: NSObjectProtocol {
    @objc optional func swipeHandlerDidStartSwiping(_ handler: SwipeHandler)
    @objc optional func swipeHandlerDidSwipe(_ handler: SwipeHandler)
    @objc optional func swipeHandlerWillRelease(_ handler: SwipeHandler)
    @objc optional func swipeHandlerDidCompleteRelease(_ handler: SwipeHandler)
    @objc optional func swipeHandlerDidChangeState(_ handler: SwipeHandler)
}

public enum State {
    case normal
    case pastThresholdLeft
    case pastThresholdRight
}

public class SwipeHandler: NSObject {
    
    public let backgroundView: UIView
    public let contentView: UIView
    
    public var config: SwipeHandlerConfiguration
    
    // The current state of the cell (either normal or past a threshold)
    public private(set) var state: State = .normal
    
    // The point at which pan elasticity starts, and `state` changes. Defaults to the height of the `UITableViewCell` (i.e. when it form a perfect square)
    public lazy var threshold: CGFloat = {
        return self.contentView.frame.height
    }()
    
    // A number between 0 and 1 to indicate progress toward reaching threshold in the current swiping direction. Useful for changing UI gradually as the user swipes.
    public var progress: CGFloat {
        get {
            let progress = abs(contentView.frame.origin.x) / self.threshold
            return (progress > 1) ? 1 : progress
        }
    }
    
    // BWSwipeCell Delegate
    public weak var delegate: SwipeHandlerDelegate?
    
    public lazy var releaseCompletionBlock:((Bool) -> Void)? = {
        return {
            [weak self] (finished: Bool) in
            
            guard let this = self else { return }
            
            this.delegate?.swipeHandlerDidCompleteRelease?(this)
            this.cleanUp()
        }
    }()
    
    
    //MARK: Initialization
    
    public init(configuration:SwipeHandlerConfiguration, contentView:UIView, backgroundView:UIView) {
        //TODO: self.selectionStyle = .None
        
        self.contentView = contentView
        self.backgroundView = backgroundView
        self.config = configuration
        
        super.init()
        
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwipeHandler.handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        contentView.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Swipe Cell Functions
    
    public func cleanUp() {
        self.state = .normal
    }
    
    public func handlePanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation: CGPoint = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        var panOffset: CGFloat = translation.x
        
        // If we have elasticity to consider, do some extra calculations for panOffset
        if config.type != .swipeThrough && abs(translation.x) > self.threshold {
            if config.shouldExceedThreshold {
                let offset: CGFloat = abs(translation.x)
                panOffset = offset - ((offset - self.threshold) * config.panElasticityFactor)
                panOffset *= translation.x < 0 ? -1.0 : 1.0
            } else {
                // If we don't allow exceeding the threshold
                panOffset = translation.x < 0 ? -self.threshold : self.threshold
            }
        }
        
        // Start, continue or complete the swipe gesture
        let actualTranslation: CGPoint = CGPoint(x: panOffset, y: translation.y)
        if panGestureRecognizer.state == .began && panGestureRecognizer.numberOfTouches() > 0 {
            let newTranslation = CGPoint(x: self.contentView.frame.origin.x, y: 0)
            panGestureRecognizer.setTranslation(newTranslation, in: panGestureRecognizer.view)
            self.didStartSwiping()
            self.animateContentViewForPoint(newTranslation)
        }
        else {
            if panGestureRecognizer.state == .changed && panGestureRecognizer.numberOfTouches() > 0 {
                self.animateContentViewForPoint(actualTranslation)
            }
            else {
                self.resetCellPosition()
            }
        }
    }
    
    public func didStartSwiping() {
        delegate?.swipeHandlerDidStartSwiping?(self)
    }
    
    public func animateContentViewForPoint(_ point: CGPoint) {
        if (point.x > 0 && config.revealDirection == .left) || (point.x < 0 && config.revealDirection == .right) || config.revealDirection == .both {
            self.contentView.frame = self.contentView.bounds.offsetBy(dx: point.x, dy: 0)
            let previousState = state
            if point.x >= self.threshold {
                self.state = .pastThresholdLeft
            }
            else if point.x < -self.threshold {
                self.state = .pastThresholdRight
            }
            else {
                self.state = .normal
            }
            
            if self.state != previousState {
                delegate?.swipeHandlerDidChangeState?(self)
            }
            delegate?.swipeHandlerDidSwipe?(self)
        }
        else {
            if (point.x > 0 && config.revealDirection == .right) || (point.x < 0 && config.revealDirection == .left) {
                self.contentView.frame = self.contentView.bounds.offsetBy(dx: 0, dy: 0)
            }
        }
    }
    
    public func resetCellPosition() {
        
        delegate?.swipeHandlerWillRelease?(self)
        
        if config.type == .springRelease || self.state == .normal {
            self.animateCellSpringRelease()
        } else if config.type == .slidingDoor {
            self.animateCellSlidingDoor()
        } else {
            self.animateCellSwipeThrough()
        }
    }
    
    // MARK: - Reset animations
    
    public func animateCellSpringRelease() {
        UIView.animate(withDuration: config.animationDuration,
                                   delay: 0,
                                   options: .curveEaseOut,
                                   animations: {
                                    self.contentView.frame = self.contentView.bounds
            },
                                   completion: self.releaseCompletionBlock)
    }
    
    public func animateCellSlidingDoor() {
        UIView.animate(withDuration: config.animationDuration,
                                   delay: 0,
                                   options: .allowUserInteraction,
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
    
    public func animateCellSwipeThrough() {
        UIView.animate(withDuration: config.animationDuration,
                                   delay: 0,
                                   options: UIViewAnimationOptions.curveLinear,
                                   animations: {
                                    let direction:CGFloat = (self.contentView.frame.origin.x > 0) ? 1 : -1
                                    self.contentView.frame.origin.x = direction * (self.contentView.bounds.width + self.threshold)
            }, completion: self.releaseCompletionBlock)
    }

}

extension SwipeHandler: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer && config.revealDirection != .none {
            let pan:UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let translation: CGPoint = pan.translation(in: contentView.superview)
            return (fabs(translation.x) / fabs(translation.y) > 1) ? true : false
        }
        return false
    }
}
