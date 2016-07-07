//
//  SwipeHandlerConfiguration.swift
//  BWSwipeRevealCell
//
//  Created by Kyle Newsome on 2016-07-04.
//  Copyright © 2016 Kyle Newsome. All rights reserved.
//

import Foundation

public enum SwipeDirection {
    case none
    case both
    case right
    case left
}

public struct SwipeHandlerConfiguration {

    public let name:String
    
    // The allowable swipe direction(s)
    public var revealDirection: SwipeDirection = .both
    public var shouldExceedThreshold: Bool = true
    public var panElasticityFactor: CGFloat = 0.7

    public var animation: SwipeHandlerAnimation? = nil
    
    public init(named configName:String) {
        
        self.name = configName
    }

}

///  SwipeHandlerConfiguration+Defaults
///
///

extension SwipeHandlerConfiguration {
    
    ///
    /// Spring release is the default configuration for the swipe handler.
    /// It will always return the swipeHandler's contentView to `frame.origin.x = 0` on release.
    ///
    public static func springRelease() -> SwipeHandlerConfiguration {
        
        var config = SwipeHandlerConfiguration(named: "SpringRelease")
        
        config.animation = SwipeHandlerAnimation {
            swipeHandler, doneBlock in
            
            let contentView = swipeHandler.contentView
            
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                            contentView.frame = contentView.bounds
                },
                           completion: doneBlock)
        }
        
        return config
    }
    
    ///
    /// This configuration will animate the swipeHandler's contentView 
    /// to the threshold point on release if swipeHandler.state is past threshold.
    ///
    public static func slidingDoor() -> SwipeHandlerConfiguration {
        
        var config = SwipeHandlerConfiguration(named: "SlidingDoor")
        
        config.animation = SwipeHandlerAnimation {
            swipeHandler, doneBlock in
            
            let contentView = swipeHandler.contentView
            let isPastThreshold = swipeHandler.state != .normal
            
            let xDestination: CGFloat
            if isPastThreshold {
                
                let xOrigin = contentView.frame.origin.x
                let direction:CGFloat = (xOrigin > 0) ? 1 : -1
                xDestination = direction * swipeHandler.threshold
                
            } else {
                
                xDestination = 0
            }
            
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                            contentView.frame.origin.x = xDestination
                },
                           completion: doneBlock)
        }
        
        return config
    }
    
    ///
    /// This configuration will animate the swipeHandler's contentView 
    /// entirely outside its bounds on release if swipeHandler.state is past threshold.
    ///
    public static func swipeThrough() -> SwipeHandlerConfiguration {
        
        var config = SwipeHandlerConfiguration(named: "SwipeThrough")
        config.panElasticityFactor = 0
        
        config.animation = SwipeHandlerAnimation {
            swipeHandler, doneBlock in
            
            let contentView = swipeHandler.contentView
            let isPastThreshold = swipeHandler.state != .normal
            
            let xDestination: CGFloat
            if isPastThreshold {
                
                let xOrigin = contentView.frame.origin.x
                let direction:CGFloat = (xOrigin > 0) ? 1 : -1
                xDestination = direction * (contentView.bounds.width + abs(xOrigin))
            } else {
                
                xDestination = 0
            }
            
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: UIViewAnimationOptions.curveLinear,
                           animations: {
                            contentView.frame.origin.x = xDestination
                }, completion: doneBlock)
            
        }
        
        return config
    }
    
}
