
# BWSwipeRevealCell

![Example](https://raw.githubusercontent.com/bitwit/BWSwipeRevealCell/master/example.gif)

### Using the library

**Note: Use version 1.0.1 for Swift 2.3 support and version 2.0.0 or higher for Swift 3 support **

There are two main classes available - `BWSwipeCell` and `BWSwipeRevealCell`

**BWSwipeCell** - Only contains the pan gesture handling, and is useful mainly for heavy customization through subclassing if all you need is a leg up on swipe interactions

**BWSwipeRevealCell** - Is an out of the box solution that lets you set images and colors for 1 action on the left and right of the table cell. BWSwipeRevealCell is a subclass of BWSwipeCell.


### BWSwipeRevealCell Example
After setting `BWSwipeRevealCell` as your table cell's type in the storyboard and setting a delegate. Use this code in your controller:
```swift
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BWSwipeRevealCell
        
        swipeCell.bgViewLeftImage = UIImage(named:"Done")!.withRenderingMode(.alwaysTemplate)
        swipeCell.bgViewLeftColor = UIColor.green
        
        swipeCell.bgViewRightImage = UIImage(named:"Delete")!.withRenderingMode(.alwaysTemplate)
        swipeCell.bgViewRightColor = UIColor.red
        
        swipeCell.type = .springRelease
        
        swipeCell.delegate = self // Or whatever your delegate might be
        return cell
    }
```

### Customizing through the interface

#### BWSwipeCell Properties

**var type:BWSwipeCellType**

Can be `.springRelease`, `.swipeThrough` or `.slidingDoor`. Defaults to `.springRelease`

**var revealDirection: BWSwipeCellRevealDirection**

Can be `.both`, `.left` or `.right`. Defaults to `.both`

**(readonly) var state: BWSwipeCellState**

Can be `.normal`, `.pastThresholdLeft` or `.pastThresholdRight`

**var threshold: CGFloat**

The point at which pan elasticity starts, and `state` changes. Defaults to the height of the `UITableViewCell` (i.e. when it form a perfect square)

**(readonly) var progress:CGFloat**

A number between 0 and 1 to indicate progress toward reaching threshold in the current swiping direction. Useful for changing UI gradually as the user swipes.

**var shouldExceedThreshold: Bool**

Control whether or not the cell pans past the threshold point

**var panElasticityFactor: CGFloat**

Control how much elasticity there is past threshold, if it can be exceeded. Default is `0.7` and `1.0` would mean no elastic resistance

**var animationDuration: Double**

Animation duration. Defaults to `0.2`

**weak var delegate: BWSwipeCellDelegate?**

Set the delegate on the cell

```swift
@objc public protocol BWSwipeCellDelegate: NSObjectProtocol {
    optional func swipeCellDidStartSwiping(cell: BWSwipeCell)
    optional func swipeCellDidSwipe(cell: BWSwipeCell)
    optional func swipeCellWillRelease(cell: BWSwipeCell)
    optional func swipeCellDidCompleteRelease(cell: BWSwipeCell)
    optional func swipeCellDidChangeState(cell: BWSwipeCell)
}
```

#### BWSwipeRevealCell Properties

**var bgViewInactiveColor: UIColor**

**var bgViewLeftColor: UIColor**

**var bgViewRightColor: UIColor**

Colors for inactive, and activated states for left and right

**var bgViewLeftImage: UIImage?**

**var bgViewRightImage: UIImage?**

Images for the left and right actions

**weak var delegate: BWSwipeRevealCellDelegate?**

```swift
@objc public protocol BWSwipeRevealCellDelegate:BWSwipeCellDelegate {
    optional func swipeCellActivatedAction(cell: BWSwipeCell, isActionLeft: Bool)
}
```

Set the delegate on the cell
### Roadmap
Some brief ideas on ways to improve this library

#### v 1.x.0 (Swift 2.x version)
- Complete

##### v 2.x.0 (Swift 3.x version)
- Fix bugs

##### v 3.0.0
- [See Github Milestone](https://github.com/bitwit/BWSwipeRevealCell/milestones/Version%203.0.0)

##### v x.0.0 (a.k.a. Ideas. PRs welcome.)
- Customizable interaction per side (i.e. left .SwipeThrough, right .SlidingDoor)
- Possible subclass for allowing .SlidingDoor to convert to .SwipeThrough past a threshold point (see Mail.app)
