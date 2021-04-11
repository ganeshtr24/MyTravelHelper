//
//  SearchTrainRouter.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit
class SearchTrainRouter: PresenterToRouterProtocol {
    static func createModule() -> SearchTrainViewController {
        let view = mainStoryboard.instantiateViewController(withIdentifier: "searchTrain") as! SearchTrainViewController
        let presenter: ViewToPresenterProtocol & InteractorToPresenterProtocol = SearchTrainPresenter()
        let interactor: PresenterToInteractorProtocol = SearchTrainInteractor(networkManager: NetworkManger())
        let router:PresenterToRouterProtocol = SearchTrainRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter

        return view
    }

    static var mainStoryboard: UIStoryboard{
        return UIStoryboard(name:"Main",bundle: Bundle.main)
    }
}
