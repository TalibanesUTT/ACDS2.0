//
//  MainView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 31/07/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            TabView{
                HomeView()
                    .tabItem {
                        Image(systemName:"house")
                        Text("Inicio")
                }
                
                AppointmentsView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Citas")
                    }
                
                ProfileView().tabItem {
                    Image(systemName:"line.horizontal.3")
                    Text("Perfil")
                }
            }
        }
    }
}

#Preview {
    MainView()
}
