//
//  SwipeHandlerConfiguration.swift
//  BWSwipeRevealCell
//
//  Created by Kyle Newsome on 2016-07-04.
//  Copyright © 2016 Kyle Newsome. All rights reserved.
//

import Foundation


//Defines the interaction type of the table cell
public enum InteractionType: Int {
    case swipeThrough = 0 // swipes with finger and animates through
    case springRelease // resists pulling and bounces back
    case slidingDoor // swipe to a stopping position where underlying buttons can be revealed
}

public enum SwipeDirection {
    case none
    case both
    case right
    case left
}

public struct SwipeHandlerConfiguration {

    // The interaction type for this table cell
    public var type: InteractionType = .springRelease
    
    // The allowable swipe direction(s)
    public var revealDirection: SwipeDirection = .both
    
    // Should we allow the cell to be pulled past the threshold at all? (.swipeThrough interactions will ignore this)
    public var shouldExceedThreshold: Bool = true
    
    public var panElasticityFactor: CGFloat = 0.7
    
    // Length of the animation on release
    public var animationDuration: Double = 0.2

}
