//
//  EventOnMap.swift
//  Happ
//
//  Created by MacBook Pro on 11/20/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit



class TriangeCorner: UIView {
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()
        path.lineWidth = 1
        path.moveToPoint(CGPoint(
            x:bounds.width/2,
            y:0))
        path.addLineToPoint(CGPoint(
            x:0,
            y:bounds.height))
        path.addLineToPoint(CGPoint(
            x:bounds.width,
            y:bounds.height))
        UIColor(hexString: "F6A623").setFill()
        path.fill()
    }

}


class EventOnMap: UIView {

    static let nibName = "EventOnMap"
    static func initView() -> EventOnMap {
        return NSBundle.mainBundle().loadNibNamed(EventOnMap.nibName, owner: EventOnMap(), options: nil)!.first as! EventOnMap
    }


    var view: UIView!
    
    @IBOutlet weak var viewRounded: UIView!
    @IBOutlet weak var viewTriangle: TriangeCorner!
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


