import Cocoa
@testable import Utils
/**
 * TODO: You can't set the frame after you have called the display call on a layer. so you have to set it before.
 * TODO: See if you cant add drawLayer in the LineShape class after all. doesnt delegate work then?
 * TODO: Graphic is currently an NSVIew, it doesnt have to be. it can be a CALAyer that you attach to skin, SKin it self could be a CALayer, then Text skin would need its own subclass that extends NSView, but they could have a common protocol. 
 * TODO: there needs to be a call to decoratable.initialize() when the skin is updated, check the old project how it was done there. they are done thorugh the size call. and then it calls fill and line basically!?!?
 * NOTE: Why do we add tracking areas to the parent: because all mouseenter / exit mousemoved should be handled by the element not the skin
 */
class GraphicSkin:Skin{
    override init(_ style:IStyle? = nil, _ state:String = "", _ element:IElement? = nil){
        super.init(style, state, element)
        SkinModifier.float(self)/*Floats the entire skin*/
        let depthCount:Int = StyleParser.depthCount(style!)
        decoratables = (0..<depthCount).indices.map{ depth -> IGraphicDecoratable in
            let decoratable = GraphicSkinParser.configure(self,depth)/*this call is here because CGContext is only accessible after drawRect is called*/
            addSubview(decoratable.graphic)
            _ = SkinModifier.align(self,decoratable as! IPositional,depth)/*the argument now becomes a reference to the orgiginal instance, but it also becomes immutable unfortunatly,not to worry, the implicit setter method isn't defined by swift as mutable, even though it is. I guess indirectly, so the values are mutated on the orginal instance and all is well*/
            Modifier.rotate(decoratable, self, depth)
            decoratable.draw()/*Setup the geometry and init the display process of fill and line*/
            return decoratable
        }
    }
    /**
     * Draws Skin (aka each "decoratable" in the skin)
     */
    override func draw(){
        if(hasStateChanged || hasSizeChanged || hasStyleChanged){
            let depthCount:Int = StyleParser.depthCount(style!)
            for depth in (0..<depthCount){drawDecoratable(depth)}
        }
        super.draw()/*Sets flags etc*/
    }
    required init(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}/*Required by super class*/
}
extension GraphicSkin{
    /**
     * Draws decoratable
     */
    func drawDecoratable(_ depth:Int){
        if(hasSizeChanged){
            Modifier.reSize(decoratables[depth], Parser.size(self,depth))
        }/*Do sizing of the sizable here*/
        if(hasStateChanged || hasStyleChanged) {
            updateAppearance(decoratables[depth], depth)
        }
        if(hasSizeChanged || hasStateChanged || hasStyleChanged){
            decoratables[depth].draw()/*<--Init the actual draw call, you only want to draw once bc performance*/
        }
    }
    /**
     * Refreshes the look of the "decoratable"
     */
    func updateAppearance(_ decoratable:IGraphicDecoratable,_ depth:Int){
        Modifier.applyStyle(decoratable,self,depth)/*derives and applies style to the decoratable*/
        decoratable.get(RectGraphic.self)?.setSizeValue(Parser.size(self,depth))
        decoratable.get(RoundRectGraphic.self)?.fillet = StyleMetricParser.fillet(self,depth)/*fillet*/
        decoratable.get(AssetDecorator.self)?.assetURL = StylePropertyParser.asset(self,depth)/*Svg*/
        decoratable.get(DropShadowDecorator.self)?.dropShadow = StylePropertyParser.dropShadow(self,depth)/*dropshadow*/
        Modifier.rotate(decoratable, self, depth)
        _ = SkinModifier.align(self,decoratables[depth] as! IPositional,depth)
    }
}
/**
 * Parser for "decoratable"
 */
private class Parser{
    /**
     * TODO: ⚠️️ Should just use the instance setSize function
     * TODO: ⚠️️ Should only be called if the size has actually changed
     */
    static func size(_ skin:ISkin,_ depth:Int)->CGSize{
        let padding:Padding = Padding()//StylePropertyParser.padding(self,depth) //StylePropertyParser.padding(self,depth);// :TODO: what about margin?<----not sure this is needed, the padding
        let width:CGFloat = Parser.width(skin,depth,padding)
        let height:CGFloat = Parser.height(skin,depth,padding)
        return CGSize(width,height)
    }
    static func width(_ skin:ISkin,_ depth:Int, _ padding:Padding) -> CGFloat {
        return (StyleMetricParser.width(skin,depth) ?? skin.width!) + padding.hor// :TODO: only querry this if the size has changed?
    }
    static func height(_ skin:ISkin,_ depth:Int, _ padding:Padding) -> CGFloat {
        return (StyleMetricParser.height(skin,depth) ?? skin.height!) + padding.ver// :TODO: only querry this if the size has changed?
    }
}
private class Modifier{
    /**
     * beta
     * TODO: move to DecoratorModifier.swift
     */
    static func reSize(_ sizableDecorator:IGraphicDecoratable,_ size:CGSize){
        (sizableDecorator as! ISizeable).setSizeValue(size)
        //sizableDecorator.draw()
    }
    static func rotate(_ decoratable:IGraphicDecoratable,_ skin:ISkin,_ depth:Int){
        if let rotation:CGFloat = StyleMetricParser.rotation(skin,depth){
            let size:CGSize = (decoratable as! ISizeable).size
            let pos:CGPoint = (decoratable as! IPositional).pos
            let rect:CGRect = CGRect(pos, size)
            disableAnim{
                GraphicModifier.applyRotation(decoratable, rotation, rect.center)
            }
        }
    }
    /**
     * Applies style and lineOffset
     */
    static func applyStyle(_ decoratable:IGraphicDecoratable, _ graphicSkin:GraphicSkin,_ depth:Int){
        let fillStyle:IFillStyle = StylePropertyParser.fillStyle(graphicSkin,depth)
        let lineStyle:ILineStyle? = StylePropertyParser.lineStyle(graphicSkin,depth)
        let lineOffsetType = StylePropertyParser.lineOffsetType(graphicSkin,depth)
        _ = GraphicModifier.applyProperties(decoratable,fillStyle ,lineStyle ,lineOffsetType)/*color or gradient*/
    }
}

/*
 override func updateTrackingAreas() {
    Swift.print("updateTrackingAreas: " + "\(self)")
 }
 */
