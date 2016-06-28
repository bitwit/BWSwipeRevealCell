import Foundation
import UIKit


@objc public protocol BWSwipeViewHandlerDelegate: NSObjectProtocol {
    @objc optional func swipeViewDidStartSwiping(_ handler: BWSwipeViewHandler)
    @objc optional func swipeViewDidSwipe(_ handler: BWSwipeViewHandler)
    @objc optional func swipeViewWillRelease(_ handler: BWSwipeViewHandler)
    @objc optional func swipeViewDidCompleteRelease(_ handler: BWSwipeViewHandler)
    @objc optional func swipeViewDidChangeState(_ handler: BWSwipeViewHandler)
}

//Defines the interaction type of the table cell
public enum BWSwipeCellType: Int {
    case swipeThrough = 0 // swipes with finger and animates through
    case springRelease // resists pulling and bounces back
    case slidingDoor // swipe to a stopping position where underlying buttons can be revealed
}

public enum BWSwipeCellRevealDirection {
    case none
    case both
    case right
    case left
}

public enum BWSwipeCellState {
    case normal
    case pastThresholdLeft
    case pastThresholdRight
}

public class BWSwipeViewHandler: NSObject, UIGestureRecognizerDelegate {
    
    public let backgroundView: UIView
    public let contentView: UIView
    
    // The interaction type for this table cell
    public var type: BWSwipeCellType = .springRelease
    
    // The allowable swipe direction(s)
    public var revealDirection: BWSwipeCellRevealDirection = .both
    
    // The current state of the cell (either normal or past a threshold)
    public private(set) var state: BWSwipeCellState = .normal
    
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
    
    // Should we allow the cell to be pulled past the threshold at all? (.SwipeThrough cells will ignore this)
    public var shouldExceedThreshold: Bool = true
    
    // Control how much elastic resistance there is past threshold, if it can be exceeded. Default is `0.7` and `1.0` would mean no elastic resistance
    public var panElasticityFactor: CGFloat = 0.7
    
    // Length of the animation on release
    public var animationDuration: Double = 0.2
    
    // BWSwipeCell Delegate
    public weak var delegate: BWSwipeViewHandlerDelegate?
    
    private lazy var releaseCompletionBlock:((Bool) -> Void)? = {
        return {
            [weak self] (finished: Bool) in
            
            guard let this = self else { return }
            
            this.delegate?.swipeViewDidCompleteRelease?(this)
            this.cleanUp()
        }
    }()
    
    
    //MARK: Initialization
    
    public init(contentView:UIView, backgroundView:UIView) {
        //TODO: self.selectionStyle = .None
        
        self.contentView = contentView
        self.backgroundView = backgroundView
        
        super.init()
        
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(BWSwipeViewHandler.handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        contentView.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Swipe Cell Functions
    
    public func cleanUp() {
        self.state = .normal
    }
    
    func handlePanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation: CGPoint = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        var panOffset: CGFloat = translation.x
        
        // If we have elasticity to consider, do some extra calculations for panOffset
        if self.type != .swipeThrough && abs(translation.x) > self.threshold {
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
    
    func didStartSwiping() {
        delegate?.swipeViewDidStartSwiping?(self)
    }
    
    public func animateContentViewForPoint(_ point: CGPoint) {
        if (point.x > 0 && self.revealDirection == .left) || (point.x < 0 && self.revealDirection == .right) || self.revealDirection == .both {
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
                delegate?.swipeViewDidChangeState?(self)
            }
            delegate?.swipeViewDidSwipe?(self)
        }
        else {
            if (point.x > 0 && self.revealDirection == .right) || (point.x < 0 && self.revealDirection == .left) {
                self.contentView.frame = self.contentView.bounds.offsetBy(dx: 0, dy: 0)
            }
        }
    }
    
    public func resetCellPosition() {
        
        delegate?.swipeViewWillRelease?(self)
        
        if self.type == .springRelease || self.state == .normal {
            self.animateCellSpringRelease()
        } else if self.type == .slidingDoor {
            self.animateCellSlidingDoor()
        } else {
            self.animateCellSwipeThrough()
        }
    }
    
    // MARK: - Reset animations
    
    func animateCellSpringRelease() {
        UIView.animate(withDuration: self.animationDuration,
                                   delay: 0,
                                   options: .curveEaseOut,
                                   animations: {
                                    self.contentView.frame = self.contentView.bounds
            },
                                   completion: self.releaseCompletionBlock)
    }
    
    func animateCellSlidingDoor() {
        UIView.animate(withDuration: self.animationDuration,
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
    
    func animateCellSwipeThrough() {
        UIView.animate(withDuration: self.animationDuration,
                                   delay: 0,
                                   options: UIViewAnimationOptions.curveLinear,
                                   animations: {
                                    let direction:CGFloat = (self.contentView.frame.origin.x > 0) ? 1 : -1
                                    self.contentView.frame.origin.x = direction * (self.contentView.bounds.width + self.threshold)
            }, completion: self.releaseCompletionBlock)
    }
    
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer && self.revealDirection != .none {
            let pan:UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let translation: CGPoint = pan.translation(in: contentView.superview) //TODO: superview reference may not be accurate
            return (fabs(translation.x) / fabs(translation.y) > 1) ? true : false
        }
        return false
    }
}
