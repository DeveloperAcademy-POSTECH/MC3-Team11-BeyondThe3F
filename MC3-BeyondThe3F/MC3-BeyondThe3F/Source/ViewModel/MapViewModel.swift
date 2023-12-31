//
//  MapViewModel.swift
//  Tune Spot
//
//  Created by Seungui Moon on 2023/08/05.
//

import CoreLocation
import MapKit
import SwiftUI


class MapViewModel: ObservableObject {
    @ObservedObject private var musicUpdateViewModel = MusicItemUpdateViewModel.shared
    
    @Published var mapView = MKMapView()
    @Published var userLocation = CLLocationCoordinate2D(latitude: 37.4,longitude: 127)
    @Published var region: MKCoordinateRegion = startRegion
    
    @Published var selectedCoordinate = CLLocationCoordinate2D(latitude: 37.4,longitude: 127)
    @Published var selectedPositionDescription = "저장하고 싶은 위치를 선택하세요"
    @Published var isRegionSetted = false
    @Published var isLocationAuthDenied = false
    @Published var isLocationEnabled = false
    @Published var locationInfo = "" {
        willSet {
            if newValue.isEmpty {
                isLocationEnabled = false
                selectedPositionDescription = "설정할 수 없는 위치입니다."
            } else {
                isLocationEnabled = true
            }
        }
    }
    @Published var centerPlaceDescription = "장소"
    
    let locationManager = LocationManager.shared
    
    func showUserLocation(){
        locationManager.locationManager.startUpdatingLocation()
        if let userCurrentLocation = locationManager.locationManager.location?.coordinate {
            userLocation = userCurrentLocation
        }
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude), span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
    }
    
    func moveToSelectedPlaced(place: Place){
        guard let coordinate = place.place.location?.coordinate else { return }

        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        mapView.setRegion(coordinateRegion, animated: true)
        isRegionSetted = true
        region = coordinateRegion
    }
}
