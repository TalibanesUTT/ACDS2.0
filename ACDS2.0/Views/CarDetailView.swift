//
//  CarDetailView.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 05/08/24.
//

import SwiftUI

struct CarDetailView: View {
    let car: Car
    @State var selectedView: subViews = .Detail
    var body: some View {
        VStack{
            Text("\(car.model["model"]!) - \(car.year)")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Image("\(car.model["brand"]!)")
                .resizable().scaledToFit()
                .aspectRatio(0.4, contentMode: .fit)
            
            
            Picker("", selection: $selectedView){
                ForEach(subViews.allCases, id: \.self){
                    Text($0.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            SegmentView(selectedView: selectedView, car: car)
        }
        .padding()
        .onAppear(perform: {
            print(car)
        })
    }
}

enum subViews: String, CaseIterable{
    case Services = "Servicios"
    case Detail = "Detalle"
}

struct SegmentView: View {
    var selectedView: subViews
    var car: Car
    var body: some View {
        switch selectedView {
            case .Detail:
                DetailView(car: car)
            case .Services:
                Text("Servicios")
        }
        
    }
}

struct DetailView: View {
    var car: Car
    var body: some View {
        VStack{
            HStack{
                Text("Auto")
                    .bold()
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(car.model["model"]!)").font(.title3)
            }
            Divider()
            HStack{
                Text("Marca")
                    .bold()
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(car.model["brand"]!)").font(.title3)
            }
            Divider()
            HStack{
                Text("Año")
                    .bold()
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(String(car.year))").font(.title3)
            }
            Divider()
            HStack{
                Text("Placas")
                    .bold()
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(car.plates)").font(.title3)
            }
            Divider()
            HStack{
                Text("Numero de serie")
                    .bold()
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(car.serialNumber)").font(.title2)
            }
            Divider()
        }
    }
}

#Preview {
    CarDetailView(car: Car(id: "2",
                           color: "Negro",
                           plates: "FPS-123-256",
                           model: ["id": "4", "model": "Lobo","brand": "Ford"],
                           owner: "Luis Zapata",
                           year: 2023,
                           serialNumber: "0120239103"))
}
