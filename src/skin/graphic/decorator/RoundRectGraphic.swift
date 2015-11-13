import Cocoa

class RoundRectGraphic:Decoratable,IRoundRectGraphic{
    var fillet:Fillet;
    init(_ decoratable:IDecoratable, _ fillet:Fillet? = nil){
        self.fillet = fillet ?? Fillet();
        super.init(decoratable);
        //fill();
        //line();
    }
    override func fill() {
        Swift.print("RoundRectGraphic.fill() ")
        clear()
        beginFill();
        drawFill();
        //CGContextClearRect(getGraphic().graphics.context, NSMakeRect(0, 0, 100, 100))
        //CGContextSetBlendMode(getGraphic().graphics.context,CGBlendMode.SourceIn);
    }
    
    
    override func beginFill() {
        CGContextSetBlendMode(getGraphic().graphics.context,CGBlendMode.Screen);
        GraphicModifier.applyProperties(getGraphic().graphics, FillStyle(NSColor.whiteColor()))
        
    }
    
    
    /**
     *
     */
    func clear(){
        let w:CGFloat = CGFloat((decoratable as! RectGraphic).width)
        let h:CGFloat = CGFloat((decoratable as! RectGraphic).height)
        CGContextSetBlendMode(getGraphic().graphics.context,CGBlendMode.Multiply);
        GraphicModifier.applyProperties(getGraphic().graphics, FillStyle(NSColor.whiteColor()))
        let path:CGPath = CGPathParser.rect(w, h, 0, 0)
        GraphicModifier.stylize(path, getGraphic().graphics)//realize style on the graphic
        
        //CGContextSetBlendMode(getGraphic().graphics.context,CGBlendMode.Clear);//
        //CGContextModifier.clear(getGraphic().graphics.context,NSMakeRect(0, 0, w, h))
        
        //CGContextRef cgref = UIGraphicsGetCurrentContext();
        

        //CGContextSetBlendMode(cgref, kCGBlendModeNormal);
        /*
        
       
        CGContextFlush(getGraphic().graphics.context)
        */
        //CGContextRestoreGState(getGraphic().graphics.context);
    }
    //continue here: you need to clear Graphics for this to work, google it, look trhough your notes, books, or create the decoratable differently, with a dedicated init method
    
    override func line() {
        
    }
    /**
     * Draws the fill
     */
    override func drawFill(){
        Swift.print("RoundRectGraphic.drawFill() ")
        let w:Double = (decoratable as! RectGraphic).width
        Swift.print("w: " + "\(w)")
        let h:Double = (decoratable as! RectGraphic).height
        Swift.print("h: " + "\(h)")
        Swift.print("fillet.topLeft: " + "\(fillet.topLeft)")
        getGraphic().path = CGPathParser.roundRect(0,0,CGFloat(w), CGFloat(h),CGFloat(fillet.topLeft), CGFloat(fillet.topRight), CGFloat(fillet.bottomLeft), CGFloat(fillet.bottomRight))//Shapes
        GraphicModifier.stylize(getGraphic().path,getGraphic().graphics)//realize style on the graphic
    }
}