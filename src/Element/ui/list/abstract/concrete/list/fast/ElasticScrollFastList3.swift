import Foundation
@testable import Utils

class ElasticScrollFastList3:FastList3,ElasticScrollableFastListable3 {
    lazy var moverGroup:MoverGroup? = MoverGroup(self.setProgressVal,self.maskSize,self.contentSize)
    lazy var rbContainer:Container? = self.rubberBandContainer/*needed for the overshot animation*/
}
extension Elastic3 where Self:FastList3{
    var rubberBandContainer:Container {
        let rbContainer = addSubView(Container(w,h,self,"rb"))//⚠️️TODO: move to lazy var later
        rbContainer.addSubview(contentContainer)/*adds content Container inside rbContainer*/
        contentContainer.parent = rbContainer/*set the correct parent*/
        return rbContainer
    }
}
