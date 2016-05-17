//
//  StationInfoViewController.swift
//  tutuRoute
//
//  Created by Артмеий Шлесберг on 16/05/16.
//  Copyright © 2016 Shlesberg. All rights reserved.
//

import Foundation
import UIKit
// контроллер для отображения подробной информации о станции
//при нажатии на кнопку на navigationBar'е происходит выход на первый экран и отображения в нем выбранной станции
class StationInfoViewController : UITableViewController {
    var station : Station?
    var delegate : StationChoiseDelegate?
    
    @IBOutlet weak var stationTitle: UILabel!
    @IBOutlet weak var cityTitle: UILabel!
    @IBOutlet weak var regionTitle: UILabel!
    @IBOutlet weak var countryTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stationTitle.text = station?.stationTitle
        cityTitle.text = station?.cityTitle
        regionTitle.text = station?.regionTitle
        countryTitle.text = station?.countryTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select Station", style: .Plain ,  target:self, action: #selector(selectStation))

    }
    //метод обработки выбора станции
    func selectStation() {
        delegate?.didSelectStation(station!)
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
}