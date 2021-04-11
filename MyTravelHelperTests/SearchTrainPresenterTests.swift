//
//  SearchTrainPresenterTests.swift
//  MyTravelHelperTests
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper

class SearchTrainPresenterTests: XCTestCase {
    var presenter: SearchTrainPresenter!
    var view = SearchTrainMockView()
    var interactor = SearchTrainInteractorMock()
    
    override func setUp() {
      presenter = SearchTrainPresenter()
        presenter.view = view
        presenter.interactor = interactor
        interactor.presenter = presenter
    }

    func testfetchallStations() {
        presenter.fetchallStations()
        XCTAssertTrue(view.isSaveFetchedStatinsCalled)
    }
    
    func testUpdateLatestTrainList() {
        presenter.searchTapped(source: "Dublin Connolly", destination: "Belfast")
        XCTAssertTrue(view.isUpdateLatestTrainListCalled)

    }
    
    func testUpdateTrainListWhenListIsEmpty() {
        interactor.testForEmptyTrainList = true
        presenter.searchTapped(source: "Dublin Connolly", destination: "Belfast")
        XCTAssertTrue(view.isShowNoTrainsFoundAlertCalled)
    }

    override func tearDown() {
        presenter = nil
    }
}


class SearchTrainMockView: PresenterToViewProtocol {
    
    var isSaveFetchedStatinsCalled = false
    
    var isUpdateLatestTrainListCalled = false
    
    var isShowNoTrainsFoundAlertCalled = false
    
    func saveFetchedStations(stations: [Station]?) {
        isSaveFetchedStatinsCalled = true
    }

    func showInvalidSourceOrDestinationAlert() {

    }
    
    func updateLatestTrainList(trainsList: [StationTrain]) {
        isUpdateLatestTrainListCalled = true
    }
    
    func showNoTrainsFoundAlert() {
        isShowNoTrainsFoundAlertCalled = true
    }
    
    func showNoTrainAvailabilityFromSource() {
    }
    
    func showNoInterNetAvailabilityMessage() {

    }
}

class SearchTrainInteractorMock: PresenterToInteractorProtocol {
    
    var presenter: InteractorToPresenterProtocol?
    var testForEmptyTrainList = false

    func fetchAllStations() {
        let station = Station(desc: "Belfast Central", latitude: 54.6123, longitude: -5.91744, code: "BFSTC", stationId: 228)
        presenter?.stationListFetched(list: [station])
    }

    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        if testForEmptyTrainList {
            presenter?.fetchedTrainsList(trainsList: [])
        } else {
            let stationTrain = [StationTrain(trainCode: "E932", fullName: "Dublin Connolly", stationCode: "CNLLY", trainDate: "10 Apr 2021", dueIn: 12, lateBy: 5, expArrival: "20:12", expDeparture: "20:13")]
            presenter?.fetchedTrainsList(trainsList: stationTrain)
        }

    }
}
