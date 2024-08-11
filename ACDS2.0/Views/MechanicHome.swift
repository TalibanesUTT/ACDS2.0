//
//  MechanicHome.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 09/08/24.
//

import SwiftUI

struct MechanicHome: View {
    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            TabView{
                OrdersView().tabItem({
                    Image(systemName: "house")
                    Text("Inicio")
                        .foregroundStyle(.black)
                })
                
                ProfileView().tabItem {
                    Image(systemName:"line.horizontal.3")
                    Text("Perfil")
                        .foregroundStyle(.black)
                }
            }
        }
    }
}

#Preview {
    MechanicHome()
}
