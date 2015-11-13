
# BWSwipeRevealCell

![Example](https://raw.githubusercontent.com/bitwit/BWSwipeRevealCell/master/example.gif)

### Using the library

There are two main classes available - `BWSwipeCell` and `BWSwipeRevealCell`

**BWSwipeCell** - Only contains the pan gesture handling, and is useful mainly for heavy customization through subclassing if all you need is a leg up on swipe interactions

**BWSwipeRevealCell** - Is an out of the box solution that lets you set images and colors for 1 action on the left and right of the table cell. BWSwipeRevealCell is a subclass of BWSwipeCell.


### BWSwipeRevealCell Example
After setting `BWSwipeRevealCell` as your table cell's type in the storyboard and setting a delegate. Use this code in your controller:
```swift
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    let swipeCell:BWSwipeRevealCell = cell as! BWSwipeRevealCell
    swipeCell.bgViewLeftImage = UIImage(named:"Done")!.imageWithRenderingMode(.AlwaysTemplate)
    swipeCell.bgViewLeftColor = UIColor.greenColor()
    swipeCell.bgViewRightImage = UIImage(named:"Delete")!.imageWithRenderingMode(.AlwaysTemplate)
    swipeCell.bgViewRightColor = UIColor.redColor()
    swipeCell.type = .SpringRelease
    return cell
}
```

### Roadmap
Some brief ideas on ways to improve this library

##### v 0.1.0
- Release as Cocoapod

##### v 0.x.0
- Fix bugs
- More code commentary
- Identify and remove any code redundancy

##### v 1.0.0
- Any breaking changes (protocol, method names etc)

##### v x.0.0
- Customizable interaction per side (i.e. left .SwipeThrough, right .SlidingDoor)
- Possible subclass for allowing .SlidingDoor to convert to .SwipeThrough past a threshold point (see Mail.app)
