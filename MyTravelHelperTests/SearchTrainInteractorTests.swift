//
//  SearchTrainInteractorTests.swift
//  MyTravelHelperTests
//
//  Created by Ganesh TR on 11/04/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper
@testable import XMLParsing

class SearchTrainInteractorTests: XCTestCase {
    var networkManger: NetworkManageable!
    var interactor: SearchTrainInteractor!
    var presenter = SearchTrainPresenter()
    var view = SearchTrainMockView()
    override func setUpWithError() throws {

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchAllStation() {
        networkManger = NetworkManger(urlSession: URLSessionMock(scenario: .fetchAllStations))
        interactor = SearchTrainInteractor(networkManager: networkManger)
        interactor.presenter = presenter
        presenter.interactor = interactor
        presenter.view = view
        presenter.fetchallStations()

        XCTAssertTrue(view.isSaveFetchedStatinsCalled)
    }

}
