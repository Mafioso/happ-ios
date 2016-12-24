//
//  EventOnMap.swift
//  Happ
//
//  Created by MacBook Pro on 11/20/16.
//  Copyright © 2016 Sattar Stamkulov. All rights reserved.
//

import UIKit



class TriangeCorner: UIView {
    
    var colorToFill: UIColor!

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
        self.colorToFill.setFill()
        path.fill()
    }

}


class EventOnMap: UIView {

    static let nibName = "EventOnMap"

    static func initView(color: UIColor) -> EventOnMap {

        let inst = NSBundle.mainBundle().loadNibNamed(EventOnMap.nibName, owner: EventOnMap(), options: nil)!.first as! EventOnMap

        let triangleFrame = CGRectMake(0, 14, 32, 32)
        let triangle = TriangeCorner(frame: triangleFrame)
        triangle.colorToFill = color
        triangle.backgroundColor = UIColor.clearColor()
        inst.insertSubview(triangle, atIndex: 0)

        return inst
    }

    var view: UIView!
    
    @IBOutlet weak var viewRounded: UIView!
    @IBOutlet weak var viewTriangle: TriangeCorner!
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!



}


