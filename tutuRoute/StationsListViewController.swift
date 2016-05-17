//
//  StationsListViewController.swift
//  tutuRoute
//
//  Created by Артмеий Шлесберг on 16/05/16.
//  Copyright © 2016 Shlesberg. All rights reserved.
//

import Foundation
import UIKit
//контроллер представления станций
//изначально загружает все доступные станции
//при вводе в поле поиска отображает станции, удовлетворяющие запросу
//так как данных много, то требуется время на загрузку, особенно при работе со станциями прибытия
//в рамках тестовго задания, я не делал акцент на визуальную составляющую и не стал делать индикатор загрузки
//
//нажав ячейку можно получить более подробную информацию о станции и вырать ее для маршрута

class StationsListViewController: UITableViewController {
    
    var delegate : StationChoiseDelegate?
    
    let identifier = "stationCell"
    
    var direction : Direction?
    
    //индикатор загрузки всех данных для базового отображения
    //тем не менее поиск можно начинать раньше
    var baseInfoLoaded : Bool = false
    
    //загрзчик станций для поиска
    var stationsLoader : StationsLoader?
    //массивы всех данных
    var cities : [String] = []
    var stations : [String : [Station]] = [:]
    //массивы результатов поиска
    var citiesForFilteredStations : [String] = []
    var filteredStations : [String: [Station]] = [:]
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBaseInfo()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        switch direction! {
        case .To:
            navigationController?.title = "Куда"
        case .From:
            navigationController?.title = "Откуда"
        }

    }
    //при выходе все загрузки останавливаются
    override func viewDidDisappear(animated: Bool) {
        if stationsLoader != nil {
            stationsLoader?.actual = false
        }
    }
    //при условии того что serchBar активен, для наполнения таблицы используется массив с результатами поиска.
    //В ином случае основной массив
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredStations[citiesForFilteredStations[section]]!.count
        }
        if baseInfoLoaded {
            return  stations[cities[section]]!.count
        }
        return 0
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return citiesForFilteredStations.count
        }
        if baseInfoLoaded {
            return cities.count
        }
        return 0
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        var station : Station
        if searchController.active && searchController.searchBar.text != "" {
            station = filteredStations[citiesForFilteredStations[indexPath.section]]![indexPath.row]
        } else {
            let currentCity = cities[indexPath.section]
            let currentCityStations = stations[currentCity]
            station = currentCityStations![indexPath.row]
        }
        cell.textLabel?.text = station.stationTitle
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.active && searchController.searchBar.text != "" {
            return citiesForFilteredStations[section]
        }
        return cities[section]
    }
    
    //метод осуществляющий вызов асинхронного запроса к базе для поиска
    func filterContentForSearchText(searchText: String){
        
        if stationsLoader != nil {
            stationsLoader?.actual = false
        }
        
        if searchText != "" {
            
            stationsLoader = StationsLoader()
            stationsLoader?.getStations(withSearchString: searchText, byDirection: direction!, completion: didRecievedStations)
            
        }
            //в случае если поле осталось пустым но все данные еще не загружены обновление не произойдет
        else if baseInfoLoaded {
            tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc  = segue.destinationViewController as! StationInfoViewController
        let indexPath = tableView.indexPathForSelectedRow!
        var station : Station
        // передача данных в следующий контроллер для отображения подробной информации
        if  searchController.active && searchController.searchBar.text != "" {
            station = filteredStations[citiesForFilteredStations[indexPath.section]]![indexPath.row]
        } else {
            station = stations[cities[indexPath.section]]![indexPath.row]
        }
        vc.station = station
        vc.delegate = delegate
        
    }
    //  загрузка всех станций
    //  сначала загружается список всех городов
    //  затем для каждого города заргужается список доступных станций
    private func loadBaseInfo() {
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            self.cities =  Datamodel.getCitiesList(self.direction!)
            for city in self.cities {
                self.stations[city] = Datamodel.getStationsOfCity(nammed: city, direction: self.direction!)
                
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("loaded all stations")
                self.baseInfoLoaded = true
                self.tableView.reloadData()
            })
        })
    }
    // обработка получения резульатов поиска
    func didRecievedStations(cities : [String], stations : [String : [Station]]) {
        filteredStations = stations
        citiesForFilteredStations = cities
        
        tableView.reloadData()
    }
    //

    
}
// функция для обработки ввода текста в searchBar
extension StationsListViewController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}