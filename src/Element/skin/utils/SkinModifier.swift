import Cocoa
@testable import Utils

/**
 * // :TODO: Make the methods more Element cetric less skin centric
 */
class SkinModifier {// :TODO: consider renaming to ElementModifier (or a better name)
    /**
     * Aligns PARAM: view
     * Set the x and y of the decoratable
     * IMPORTANT: ⚠️️ Does not call draw on decoratable, only sets x,y
     */
    static func align(_ skin:ISkin, _ positional:IPositional,_ depth:Int = 0)->IPositional {
        let offset:CGPoint = StyleMetricParser.offset(skin,depth)
        let padding:Padding = StyleMetricParser.padding(skin,depth)
        let margin:Margin = StyleMetricParser.margin(skin,depth)
        let floatType:String? = SkinParser.float(skin,depth)
        let pos:CGPoint = {
            if(floatType == CSSConstants.left.rawValue || floatType == "" || floatType == nil) {
                return CGPoint(margin.left + offset.x, margin.top + offset.y)
            }else if(floatType == CSSConstants.right.rawValue) {
                let x:CGFloat = padding.right + margin.right + offset.x
                let y:CGFloat = margin.top + padding.top + offset.y
                return CGPoint(x,y)
            }else /*floatType == CSSConstants.NONE*/ {
                return CGPoint(margin.left + offset.x, margin.top + offset.y)
            }
        }()
        positional.setPosition(pos)
        return positional
    }
    /**
     * Floats PARAM: skin
     * NOTE: if clear == "none" no clearing is performed
     * NOTE: if float == "none" no floating is performed
     * TODO: ⚠️️ Text instances are inline, button are block (impliment inline and block stuff)
     * TODO: ⚠️️ Impliment support for box-sizing?!?
     * TODO: ⚠️️ Add support for hiding the element if its float is none
     * TODO: ⚠️️ possibly merge floatLeft and clearLeft? and floatRight and clearRight? or have float left/right call the clear calls
     */
    static func float(_ skin:ISkin){// :TODO: rename since it floats and clears which are two methods, position? // :TODO: move to ElementModifier
        if(skin.element!.getParent() is IElement == false) {return}/*if the skin.element doesnt have a parent that is IElement skip the code bellow*/// :TODO: this should be done by the caller
        guard let view:NSView = skin.element as? NSView else {fatalError("skin element is not NSView")}
        guard let element:Element = skin.element as? Element else{fatalError("skin has no element")}
        guard let parent:NSView = element.getParent() as? NSView else{ fatalError("skin has no parent")}
        guard let elementParent:IElement = element.getParent() as? IElement else{fatalError("skin has no elementParent")}
        let siblings:[IElement] = ElementParser.children(parent,IElement.self)
        let index:Int = parent.contains(view) ? Utils.elementIndex(parent, element) : siblings.count/*The index of skin, This creates the correct index even if its not added to the parent yet*/
        guard let parentSkin:ISkin = elementParent.skin else{fatalError("parent has no skin")}
        let parentTopLeft:CGPoint = SkinParser.relativePosition(parentSkin)/*the top-left-corner of the parent*/
        let parentTopRight:CGPoint = CGPoint(parentTopLeft.x + SkinParser.totalWidth(parentSkin)/*the top-right-corner of the parent*//*was skin.getHeight()*//* - SkinParser.padding(parent.skin).right - SkinParser.margin(parent.skin).right<-these 2 values are beta*/,parentTopLeft.y);
        let leftSiblingSkin:ISkin? = Utils.leftFloatingElementSkin(siblings, index)/*the last left floating element-sibling skin*/
        let rightSiblingSkin:ISkin? = Utils.rightFloatingElementSkin(siblings, index)/*the last right floating element-sibling-skin*/
        let clearType:String? = SkinParser.clear(skin)//TODO:this should be optional as not all Elements will have a clear value in the future
        let floatType:String? = SkinParser.float(skin)
        Utils.float(skin, clearType, floatType, leftSiblingSkin, rightSiblingSkin, parentTopLeft.x, parentTopRight.x)
        Utils.clear(skin, clearType, floatType, leftSiblingSkin, rightSiblingSkin, parentTopLeft.y)
    }
}
/**
 * TODO: You should split some of these methods into sub classes, I think maybe the reason why they are bundled together into one class is because the way the methods are so intertwined
 */
private class Utils{
    /**
     * Clear PARAM: skin to the left, right , both or none
     */
    static func clear(_ skin:ISkin,_ clearType:String?,_ floatType:String?,_ leftSiblingSkin:ISkin?,_ rightSiblingSkin:ISkin?,_ top:CGFloat){
        if(clearType == CSSConstants.left.rawValue) {clearLeft(skin,leftSiblingSkin,top)}/*Clear is left*/
        else if(clearType == CSSConstants.right.rawValue) {clearRight(skin,rightSiblingSkin,top)}/*Clear is right*/
        else if(clearType == CSSConstants.both.rawValue && (leftSiblingSkin != nil)) {clearBoth(skin,leftSiblingSkin ?? rightSiblingSkin,top)}/*Clear left & right*/
        else if(clearType == CSSConstants.none.rawValue || clearType == nil) {clearNone(skin, floatType,leftSiblingSkin,rightSiblingSkin, top)}/*Clear is none or null*/
    }
    /**
     * Floats PARAM: skin to the left or right or none
     */
    static func float(_ skin:ISkin, _ clearType:String?, _ floatType:String?, _ leftSiblingSkin:ISkin?,_ rightSiblingSkin:ISkin?,_ left:CGFloat,_ right:CGFloat) {
        if(floatType == CSSConstants.left.rawValue) { floatLeft(skin, clearType, leftSiblingSkin, left)}/*Float left*/
        else if(floatType == CSSConstants.right.rawValue) { floatRight(skin, clearType, rightSiblingSkin, right)}/*Float right*/
    }
    /**
     * Positions PARAM: skin by way of clearing it left
     * PARAM: skin the skin to be cleared
     * PARAM: leftSiblingSkin the skin that is left of skin.element
     * PARAM: top is the y value of the skins parent to align against
     */
    static func clearLeft(_ skin:ISkin,_ leftSiblingSkin:ISkin?,_ top:CGFloat) {
        let y:CGFloat = leftSiblingSkin != nil ? leftSiblingSkin!.element!.y + SkinParser.totalHeight(leftSiblingSkin!) : top
        skin.element!.y = y
    }
    /**
     * Positions PARAM: skin by way of clearing it right
     * PARAM: skin the skin to be cleared
     * PARAM: rightSiblingSkin the skin that is right of skin.element
     * PARAM: top is the y value of the skins parent to align against
     */
    static func clearRight(_ skin:ISkin,_ rightSiblingSkin:ISkin?,_ top:CGFloat){
        skin.element!.y = rightSiblingSkin != nil ? rightSiblingSkin!.element!.y + SkinParser.totalHeight(rightSiblingSkin!) : top
    }
    /**
     *
     */
    static func clearNone(_ skin:ISkin, _ floatType:String?, _ leftSibling:ISkin?,_ rightSibling:ISkin?, _ top:CGFloat){
        skin.element!.y = {
            if(floatType == CSSConstants.left.rawValue && leftSibling != nil) { return leftSibling!.element!.y }
            else if(floatType == CSSConstants.right.rawValue && rightSibling != nil) { return rightSibling!.element!.y}
            else if(floatType == CSSConstants.none.rawValue) { return skin.element!.y}
            else {return top}
        }()
    }
    /**
     * Positions PARAM: skin by way of clearing it left & right (both)
     * PARAM: skin the skin to be cleared
     * PARAM: prevSiblingSkin the skin that is previouse of skin.element
     * PARAM: top is the y value of the skins parent to align against
     */
    static func clearBoth(_ skin:ISkin,_ prevSiblingSkin:ISkin?,_ top:CGFloat){
        skin.element!.y = prevSiblingSkin != nil ? prevSiblingSkin!.element!.y + SkinParser.totalHeight(prevSiblingSkin!) : top
    }
    /**
     *  Positions PARAM: skin by way of floating it left
     *  PARAM: skin the skin to be floated
     *  PARAM: leftSiblingSkin the skin that is left of skin.element
     *  PARAM: left the x value to align against
     */
    static func floatLeft(_ skin:ISkin, _ clearType:String?, _ leftSiblingSkin:ISkin?,  _ left:CGFloat){
        skin.element!.x = {
            if let leftSiblingSkin = leftSiblingSkin, (clearType != CSSConstants.left.rawValue && clearType != CSSConstants.both.rawValue) {/*Sets the position of the skin.element*/
                return leftSiblingSkin.element!.x + SkinParser.totalWidth(leftSiblingSkin)
            };return left/*a previous element-sibling floats left*/
        }()
    }
    /**
     *  Positions PARAM: skin by way of floating it right
     *  PARAM: skin the skin to be floated
     *  PARAM: rightSiblingSkin the skin that is right of skin.element
     *  PARAM: right the x value to align against
     */
    static func floatRight(_ skin:ISkin, _ clearType:String?, _ rightSiblingSkin:ISkin?, _ right:CGFloat){
        skin.element!.x = {
            if let rightSiblingSkin = rightSiblingSkin , (clearType != CSSConstants.right.rawValue && clearType != CSSConstants.both.rawValue) {/*a previous element-sibling floats right*/
                return rightSiblingSkin.element!.x
            };return right - SkinParser.totalWidth(skin)/*Sets the position of the skin.element*/
        }()
    }
    /**
     * NOTE:-1 -> Not found
     */
    static func elementIndex(_ parent:NSView,_ element:Element)->Int {
        return parent.subviews.lazy.filter{$0 is Element}.index(where:{$0 === element}) ?? -1// functional programming 🎉
    }
    /**
     *
     */
    static func leftFloatingElementSkin(_ elements:[IElement],_ index:Int)->ISkin? {
        let lastIndexOfLeftFloatingElement:Int = Utils.lastIndex(elements, 0,index-1, CSSConstants.left.rawValue)
        return lastIndexOfLeftFloatingElement != -1 ? elements[lastIndexOfLeftFloatingElement].skin : nil/*the left element-sibling*/
    }
    /**
     * PARAM: index is the index of the skin being floated
     */
    static func rightFloatingElementSkin(_ elements:[IElement],_ index:Int)->ISkin? {
        let lastIndexOfRightFloatingElement:Int = Utils.lastIndex(elements, 0,index-1, CSSConstants.right.rawValue,exception)
        return lastIndexOfRightFloatingElement != -1 ? elements[lastIndexOfRightFloatingElement].skin! : nil/*the right-sibling-skin*/
    }
    /**
     * Exception method used to fix a problem where Elements would not float correctly to the right if a leftfloating Element that also cleared to the right or both, came before a Right floating Element
     */
    static func exception(_ skin:ISkin) -> Bool{
        return (SkinParser.float(skin) == CSSConstants.left.rawValue && (SkinParser.clear(skin) == CSSConstants.right.rawValue || SkinParser.clear(skin) == CSSConstants.both.rawValue))
    }
    /**
     * NOTE: Loops backwards
     * PARAM: Tange is the range within the possible rightfloating skin can be in
     * CAUTION: ⚠️️ The reason we dont use range or for in range {} is because the methods that call this doesnt assert for empty arrays. Fix this later. for now the code is clumpsy but works
     */
    static func lastIndex(_ elements:[IElement],_ rangeStart:Int,_ rangeEnd:Int,_ floatType:String,_ exception:((ISkin)->Bool)? = nil)->Int {
        var i:Int = rangeEnd
        while(i >= rangeStart){
            let skin:ISkin = elements[i].skin!
            if(exception != nil && exception!(skin)) {return -1}
            if(SkinParser.float(skin) == floatType && SkinParser.display(skin) != CSSConstants.none.rawValue) {return i}
            i -= 1
        }
        return -1
    }
}
