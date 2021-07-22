//
//  File.swift
//  
//
//  Created by Malte on 17.06.21.
//

import ComposableArchitecture
import SwiftUI

public struct MapFeatureView: View {
  public init(store: Store<MapFeatureState, MapFeatureAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  let store: Store<MapFeatureState, MapFeatureAction>
  @ObservedObject var viewStore: ViewStore<MapFeatureState, MapFeatureAction>
  
  public var body: some View {
    ZStack {
      MapView(
        riderCoordinates: viewStore.binding(
          get: \.riders,
          send: MapFeatureAction.updateRiderCoordinates
        ),
        userTrackingMode: viewStore.binding(
          get: { $0.userTrackingMode.userTrackingMode },
          send: MapFeatureAction.updateUserTrackingMode
        ),
        shouldAnimateUserTrackingMode: viewStore.binding(
          get: \.shouldAnimateTrackingMode,
          send: MapFeatureAction.updateShouldAnimateTrackingMode
        )
      )
      .edgesIgnoringSafeArea(.all)
    }
  }
}

// MARK: Preview
struct MapFeatureView_Previews: PreviewProvider {
  static var previews: some View {
    MapFeatureView(
      store: Store<MapFeatureState, MapFeatureAction>(
        initialState: MapFeatureState(
          riders: [],
          userTrackingMode: UserTrackingState(userTrackingMode: .follow)
        ),
        reducer: mapFeatureReducer,
        environment: MapFeatureEnvironment(
          locationManager: .live
        )
      )
    )
  }
}
