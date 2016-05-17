//
//  RouteViewController.swift
//  tutuRoute
//
//  Created by Артмеий Шлесберг on 16/05/16.
//  Copyright © 2016 Shlesberg. All rights reserved.
//

import Foundation
import UIKit
import RMDateSelectionViewController
//делегат для обработки выбора станции
protocol StationChoiseDelegate {
    func didSelectStation(station : Station)
}

//контроллер основного экрана с выбором станций и даты
class RouteViewController : UITableViewController, StationChoiseDelegate {
    
    var stationFrom : Station?
    var stationTo : Station?
    var date : NSDate?
    
    @IBOutlet weak var toTitle: UILabel!
    @IBOutlet weak var fromTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //в зависимости от выбранной ячейки следующему контроллеру присваивается тип направления для отображения станций
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! StationsListViewController
        
        if segue.identifier == "segueFrom" {
            vc.direction = Direction.From
        } else if segue.identifier == "segueTo" {
            vc.direction = Direction.To
        }
        
        vc.delegate = self
        
    }
    //обработка выора станций в делегате
    func didSelectStation(station: Station) {
        
        var label : UILabel?
        
        switch station.direction {
        case .From:
            label = fromTitle
            stationFrom = station
        case .To:
            label = toTitle
            stationTo = station
        }
        
        label?.textColor = UIColor.blackColor()
        label?.text = station.stationTitle
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 2{//ячейка с датой
            selectDate()
        }
    }
    
    //создается контроллер для выбора даты с использованием библиотеки RMDateSelectionViewController
    func selectDate() {
        
        let selectAction = RMAction(title: "Select", style: RMActionStyle.Done) { (c :RMActionController) -> Void in
            
            let dp = c.contentView as! UIDatePicker
            let df = NSDateFormatter()
            df.dateFormat = "eee dd MMM"
            
            
            self.dateLabel?.text = df.stringFromDate(dp.date)
            self.dateLabel?.textColor = UIColor.blackColor()
            self.dateLabel?.textAlignment = .Center
            
            
            self.date = dp.date
            // в случае выбора датыв ячейке отображается текст с выбранной датой
            
            let ip = NSIndexPath(forItem: 2, inSection: 0)
            self.tableView.deselectRowAtIndexPath(ip, animated: true)
        }
        
        let cancelAction = RMAction(title: "Cancel", style: RMActionStyle.Cancel) { (c :RMActionController) -> Void in
            let ip = NSIndexPath(forItem: 2, inSection: 0)
            self.tableView.deselectRowAtIndexPath(ip, animated: true)

        }
        let datePickerController = RMDateSelectionViewController(style: RMActionControllerStyle.Default, selectAction: selectAction, andCancelAction: cancelAction)
        
        datePickerController?.datePicker.datePickerMode = .Date
        datePickerController?.disableBlurEffectsForBackgroundView = true
        datePickerController?.datePicker.minimumDate = NSDate()
        
        self.tabBarController!.presentViewController(datePickerController!, animated: true) { () -> Void in
            
        }
    }
}