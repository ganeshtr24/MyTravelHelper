//
//  SearchTrainPresenter.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit

class SearchTrainPresenter:ViewToPresenterProtocol {
    var stationsList:[Station] = [Station]()

    func searchTapped(source: String, destination: String) {
        let sourceStationCode = getStationCode(stationName: source)
        let destinationStationCode = getStationCode(stationName: destination)
        interactor?.fetchTrainsFromSource(sourceCode: sourceStationCode, destinationCode: destinationStationCode)
    }
    
    var interactor: PresenterToInteractorProtocol?
    var router: PresenterToRouterProtocol?
    var view:PresenterToViewProtocol?

    func fetchallStations() {
        interactor?.fetchAllStations()
    }

    private func getStationCode(stationName:String)->String {
        let stationCode = stationsList.filter{$0.stationDesc == stationName}.first
        return stationCode?.stationCode.lowercased() ?? ""
    }
}

extension SearchTrainPresenter: InteractorToPresenterProtocol {
    func showNoInterNetAvailabilityMessage() {
        view?.showNoInterNetAvailabilityMessage()
    }

    func showNoTrainAvailabilityFromSource() {
        view?.showNoTrainAvailabilityFromSource()
    }

    func fetchedTrainsList(trainsList: [StationTrain]?) {
        if let trainsList = trainsList, !trainsList.isEmpty {
            view?.updateLatestTrainList(trainsList: trainsList)
        }else {
            view?.showNoTrainsFoundAlert()
        }
    }
    
    func stationListFetched(list: [Station]) {
        stationsList = list
        view?.saveFetchedStations(stations: list)
    }
}
