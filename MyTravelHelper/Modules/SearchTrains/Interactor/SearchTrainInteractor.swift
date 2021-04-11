//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import XMLParsing

class SearchTrainInteractor: PresenterToInteractorProtocol {
    var _sourceStationCode = String()
    var _destinationStationCode = String()
    var presenter: InteractorToPresenterProtocol?
    let networkManager:NetworkManageable

    init(networkManager: NetworkManageable) {
        self.networkManager = networkManager
    }
    
    func fetchAllStations() {
        if Reach().isNetworkReachable() == true {
            networkManager.request(
                url: "http://api.irishrail.ie/realtime/realtime.asmx/getAllStationsXML") {
                (result: Swift.Result<Stations, Error>) in
                switch result {
                case .success(let station):
                    self.presenter?.stationListFetched(list: station.stationsList)
                case .failure(_):
                    return
                }
            }
        } else {
            self.presenter?.showNoInterNetAvailabilityMessage()
        }
    }

    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
        let urlString = "http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML?StationCode=\(sourceCode)"
        print(urlString)
        if Reach().isNetworkReachable() {
            
            networkManager.request(url: urlString) { (result: Swift.Result<StationData, Error>) in
                switch result {
                
                case .success(let stationData):
                    if !stationData.trainsList.isEmpty {
                        print("TrainList --> \(stationData.trainsList)")
                        self.processTrainListForDestinationCheck(trainsList: stationData.trainsList)
                    } else {
                        self.presenter?.showNoTrainAvailabilityFromSource()
                    }
                case .failure(_):
                    self.presenter?.showNoTrainAvailabilityFromSource()
                    return
                }
            }
        } else {
            self.presenter?.showNoInterNetAvailabilityMessage()
        }
    }
    
    private func processTrainListForDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        let today = Date()
        let group = DispatchGroup()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: today)
        
        for index  in 0...trainsList.count-1 {
            group.enter()
            let _urlString = "http://api.irishrail.ie/realtime/realtime.asmx/getTrainMovementsXML?TrainId=\(trainsList[index].trainCode)&TrainDate=\(dateString)"
            if Reach().isNetworkReachable() {
                networkManager.request(url: _urlString) {
                    (result: Swift.Result<TrainMovementsData,Error>) in
                    switch result {
                    case .success(let trainMovements):
                        let _movements = trainMovements.trainMovements
                        let sourceIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
                        let destinationIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
                        let desiredStationMoment =  _movements.filter{$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
                        let isDestinationAvailable = desiredStationMoment.count == 1
                        
                        if isDestinationAvailable 
                            && sourceIndex! < destinationIndex! {
                            _trainsList[index].destinationDetails = desiredStationMoment.first
                        }
                        group.leave()
                    case .failure(_):
                        self.presenter?.showNoTrainAvailabilityFromSource()
                    }
                }
            } else {
                self.presenter?.showNoInterNetAvailabilityMessage()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            let sourceToDestinationTrains = _trainsList.filter{$0.destinationDetails != nil}
            self.presenter?.fetchedTrainsList(trainsList: sourceToDestinationTrains)
        }
    }
}
