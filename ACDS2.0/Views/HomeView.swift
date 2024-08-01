//
//  HomeView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 31/07/24.
//

import SwiftUI

struct HomeView: View {
    let images = ["anounce1", "anounce2", "anounce3"]
    let cars = Array(repeating: "car", count: 10)

    var body: some View {
        ZStack{
            Color("BG").ignoresSafeArea()
            ScrollView{
                Text("Avisos recientes")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.black)
                
                TabView{
                    ForEach(images, id: \.self){ imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .cornerRadius(10)
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 220)
                
                Text("Mis autos")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)
                    .foregroundStyle(.black)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(0..<10) { _ in
                        VStack{
                            Image("car")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(10)
                            
                            Text("Lobo")
                                .bold()
                                .foregroundStyle(.black)
                            
                            Text("En progreso")
                                .bold()
                                .padding(.horizontal,15)
                                .font(.footnote)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                   }
               }
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
