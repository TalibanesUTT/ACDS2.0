//
//  ContentView.swift
//  ACdSWatch Watch App
//
//  Created by Luis Angel Zapata Zuñiga on 12/08/24.
//

import SwiftUI

struct ContentView: View {
    @State var token : String = ""
    var body: some View {
        VStack {
           Text("Received Token: \(token)")
               .padding()
       }
       .onAppear {
           NotificationCenter.default.addObserver(forName: .didReceiveToken, object: nil, queue: .main) { notification in
               if let receivedToken = notification.object as? String {
                   self.token = receivedToken
               }
           }
       }
    }
    
}

#Preview {
    ContentView()
}
