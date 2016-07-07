//
//  SwipeHandlerAnimation.swift
//  BWSwipeRevealCell
//
//  Created by Kyle Newsome on 2016-07-04.
//  Copyright © 2016 Kyle Newsome. All rights reserved.
//

import Foundation

public struct SwipeHandlerAnimation {
    
    public typealias AnimationCompletionCallback = (Bool) -> Void
    public typealias AnimationBlock = (SwipeHandler, AnimationCompletionCallback) -> Void
    
    public var duration: Double = 0.2
    
    public var resetAnimationBlock: AnimationBlock
    
    public init(resetAnimationBlock: AnimationBlock) {
    
        self.resetAnimationBlock = resetAnimationBlock
    }
    
}
