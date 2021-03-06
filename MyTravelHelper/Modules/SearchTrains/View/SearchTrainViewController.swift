//
//  SearchTrainViewController.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit
import SwiftSpinner
import DropDown

class SearchTrainViewController: UIViewController {
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var sourceTxtField: UITextField!
    @IBOutlet weak var trainsListTable: UITableView!
    @IBOutlet weak var sourceFavouriteButton: UIButton!
    @IBOutlet weak var destinationFavouriteButton: UIButton!
    @IBOutlet weak var favouriteStationButton: UIButton!
    
    var stationsList:[Station] = [Station]()
    var favouriteStations:[Station] = []
    var trains:[StationTrain] = [StationTrain]()
    var presenter:ViewToPresenterProtocol?
    var dropDown = DropDown()
    var favouriteDropDown = DropDown()
    var transitPoints:(source:String,destination:String) = ("","")

    override func viewDidLoad() {
        super.viewDidLoad()
        trainsListTable.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        if stationsList.count == 0 {
            SwiftSpinner.useContainerView(view)
            SwiftSpinner.show("Please wait loading station list ....")
            presenter?.fetchallStations()
        }
    }

    @IBAction func searchTrainsTapped(_ sender: Any) {
        view.endEditing(true)
        showProgressIndicator(view: self.view)
        presenter?.searchTapped(source: transitPoints.source, destination: transitPoints.destination)
    }
    
    @IBAction func onTapSourceFavouriteButton(_ sender: Any) {
        sourceFavouriteButton.isSelected =
            addOrRemoveFavouriteStationFor(textField: sourceTxtField)
    }
    
    @IBAction func onTapDestinationFavouriteButton(_ sender: Any) {
        destinationFavouriteButton.isSelected =
            addOrRemoveFavouriteStationFor(textField: destinationTextField)
    }

    @IBAction func onTapFavouriteStationButton(_ sender: UIButton) {
        favouriteDropDown = DropDown()
        favouriteDropDown.anchorView = sender
        favouriteDropDown.direction = .bottom
        favouriteDropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        favouriteDropDown.dataSource = favouriteStations.map {$0.stationDesc}
        favouriteDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            if self.sourceTxtField.isFirstResponder {
                self.transitPoints.source = item
                self.sourceFavouriteButton.isEnabled = true
                self.sourceFavouriteButton.isSelected =
                    self.favouriteStations
                        .contains(self.favouriteStations[index])
                self.sourceTxtField.text = item

            }else if self.destinationTextField.isFirstResponder {
                self.transitPoints.destination = item
                self.destinationFavouriteButton.isEnabled = true
                self.destinationFavouriteButton.isSelected =
                    self.favouriteStations
                        .contains(self.favouriteStations[index])
                self.destinationTextField.text = item
            }
        }
        favouriteDropDown.show()
    }
    
    func addOrRemoveFavouriteStationFor(textField: UITextField) -> Bool {
        if let index = favouriteStations.firstIndex(where: { $0.stationDesc == textField.text }) {
            favouriteStations.remove(at: index)
            return false
        } else {
            if let station = stationsList.filter({ $0.stationDesc == textField.text
            }).first {
                favouriteStations.append(station)
                favouriteStations.sort { $0.stationDesc < $1.stationDesc }
                return true
            }
        }
        return false
    }
}

extension SearchTrainViewController:PresenterToViewProtocol {
    func showNoInterNetAvailabilityMessage() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "No Internet", message: "Please Check you internet connection and try again", actionTitle: "Okay")
    }

    func showNoTrainAvailabilityFromSource() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.trainsListTable.isHidden = true
            hideProgressIndicator(view: self.view)
            self.showAlert(title: "No Trains",
                           message: "Sorry No trains arriving source station in another 90 mins",
                           actionTitle: "Okay")
        }
    }

    func updateLatestTrainList(trainsList: [StationTrain]) {
        hideProgressIndicator(view: self.view)
        trains = trainsList
        trainsListTable.isHidden = false
        trainsListTable.reloadData()
    }

    func showNoTrainsFoundAlert() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        trainsListTable.isHidden = true
        showAlert(title: "No Trains", message: "Sorry No trains Found from source to destination in another 90 mins", actionTitle: "Okay")
    }

    func showAlert(title:String,message:String,actionTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showInvalidSourceOrDestinationAlert() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "Invalid Source/Destination", message: "Invalid Source or Destination Station names Please Check", actionTitle: "Okay")
    }

    func saveFetchedStations(stations: [Station]?) {
        if let _stations = stations {
            self.stationsList = _stations.sorted(by: { (station1, station2) -> Bool in
                station1.stationDesc < station2.stationDesc
            })
        }
        SwiftSpinner.hide()
    }
}

extension SearchTrainViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDown = DropDown()
        dropDown.anchorView = textField
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = stationsList.map {$0.stationDesc}
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            if textField == self.sourceTxtField {
                self.transitPoints.source = item
                self.sourceFavouriteButton.isEnabled = true
                self.sourceFavouriteButton.isSelected =
                    self.favouriteStations
                        .contains(self.stationsList[index])
            }else {
                self.transitPoints.destination = item
                self.destinationFavouriteButton.isEnabled = true
                self.destinationFavouriteButton.isSelected =
                    self.favouriteStations
                        .contains(self.stationsList[index])
            }
            textField.text = item
        }
        dropDown.show()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dropDown.hide()
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let inputedText = textField.text {
            var desiredSearchText = inputedText
            if string != "\n" && !string.isEmpty{
                desiredSearchText = desiredSearchText + string
            }else {
                desiredSearchText = String(desiredSearchText.dropLast())
            }

            dropDown.dataSource = stationsList.map(\.stationDesc)
                .filter({
                    if let _ = $0.range(of: desiredSearchText, options: .caseInsensitive) {
                        return true
                    } else {
                        return false
                    }
                })
            dropDown.show()
            dropDown.reloadAllComponents()
        }
        return true
    }
}

extension SearchTrainViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trains.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "train", for: indexPath) as! TrainInfoCell
        let train = trains[indexPath.row]
        cell.trainCode.text = train.trainCode
        cell.souceInfoLabel.text = train.stationFullName
        cell.sourceTimeLabel.text = train.expDeparture
        if let _destinationDetails = train.destinationDetails {
            cell.destinationInfoLabel.text = _destinationDetails.locationFullName
            cell.destinationTimeLabel.text = _destinationDetails.expDeparture
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
