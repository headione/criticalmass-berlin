//
//  File.swift
//  
//
//  Created by Malte on 28.06.21.
//

import ComposableArchitecture
import MapFeature
import Styleguide
import SwiftUI

public struct AppNavigationView: View {
  let store: Store<AppState, AppAction>
  @ObservedObject var viewStore: ViewStore<AppState, AppAction>
  @Environment(\.colorScheme) var colorScheme
  
  let minHeight: CGFloat = 56
  
  public init(store: Store<AppState, AppAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  public var body: some View {
    HStack {
      UserTrackingButton(
        store: store.scope(
          state: { $0.mapFeatureState.userTrackingMode },
          action: { AppAction.map(.userTracking($0)) }
        )
      )
      .frame(maxWidth: .infinity, minHeight: minHeight)
      
      menuSeperator
      
      Button(
        action: {
          //TODO: send open chat and twitter navigation action
        },
        label: {
          Image(systemName: "bubble.left")
            .iconModifier()
            .accessibility(hidden: true)
        }
      )
      .accessibility(label: Text(NSLocalizedString("navigation.chat", bundle: .module, comment: "")))
      .frame(maxWidth: .infinity, minHeight: minHeight)
      
      menuSeperator
      
      Button(
        action: {},
        label: {
          Image(systemName: "exclamationmark.square")
            .iconModifier()
            .accessibility(hidden: true)
        }
      )
      .frame(maxWidth: .infinity, minHeight: minHeight)
      .accessibility(label: Text(NSLocalizedString("navigation.rules", bundle: .module, comment: "")))
      
      menuSeperator
      Button(
        action: {},
        label: {
          Image(systemName: "gearshape")
            .iconModifier()
            .accessibility(hidden: true)
        }
      )
      .frame(maxWidth: .infinity, minHeight: minHeight)
      .accessibility(label: Text(NSLocalizedString("navigation.settings", bundle: .module, comment: "")))
    }
    .background(colorScheme == .light ? .white : Color.hex(0x45474D))
    .clipShape(RoundedRectangle(cornerRadius: 18))
    .modifier(ShadowModifier())
  }
  
  var menuSeperator: some View {
    Color.hex(0xDADCE0)
      .frame(width: 1, height: minHeight)
  }
}

struct ShadowModifier: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  
  func body(content: Content) -> some View {
    if colorScheme == .light {
      content
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0.0, y: 0.0)
    } else {
      content
    }
  }
}

// MARK: Preview
struct AppNavigationView_Previews: PreviewProvider {
  static var previews: some View {
    AppNavigationView(store: Store<AppState, AppAction>(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        service: .noop,
        idProvider: .noop,
        mainQueue: .failing
      )
    )
    )
  }
}