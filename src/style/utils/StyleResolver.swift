import Foundation

//Continue here: to bring id into the fold you need to bring in the origional code, atleast take a look

class StyleResolver{
    class func style2(element:IElement)->IStyle{
        return 
    }
    /**
     *
     */
    class func style(element:IElement)->IStyle{
        //let querrySelectors:Array = ElementParser.selectors(element);// :TODO: possibly move up in scope for optimizing
        //Swift.print("STACK: " + SelectorParser.string(querrySelectors));
        var styleComposition:IStyle = Style("styleComp")
        //let classType:String = element.getClassType()//gets the classtype from the component
        let querrySelector:ISelector = ElementParser.selector(element);// :TODO: possibly move up in scope for optimizing

        //Swift.print("styleComposition")
        //Swift.print(StyleManager.styles.count)
        for style in StyleManager.styles{//loop through styles
            //Swift.print("style.selector.element: " + style.selector.element)
            for selector in style.selectors{
                if(selector.element == querrySelector.element){ //if style.selector == classType
                    //Swift.print("  element match found")
                    if(selector.states.count > 0){
                        for state in selector.states{//loop style.selector.states
                            //Swift.print("state: " + state)
                            //Swift.print("element.skinState: " + element.skinState)
                            for s in querrySelector.states{
                                if(state == s){//if state == any of the current states TODO: figure out how the statemaschine works and impliment that
                                    //Swift.print("    state match found")
                                    StyleModifier.combine(&styleComposition, style)//gracefully append this style to styleComposition, forced overwrite
                                }
                            }
                        }
                    }else{//temp solution
                        StyleModifier.combine(&styleComposition, style)
                    }
                }
            }
            
        }
        
        //Swift.print("styleComposition.styleProperties.count: " + "\(styleComposition.styleProperties.count)")
        //StyleParser.describe(styleComposition)
        return styleComposition
    }
}