//
//  QRCodeGenerate.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 10/08/24.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGenerate: View {
    
    var data: [String:Any]
    
    var body: some View {
        Image(uiImage: generateQR(data))
            .interpolation(.none)
            .resizable()
            .frame(width: 200, height: 200)
            
    }
    
    func generateQR(_ json: [String:Any]) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            
            // Asignar el JSON Data al filtro
            filter.setValue(jsonData, forKey: "inputMessage")
            
            // Configurar el filtro
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            
            // Generar la imagen QR
            if let qrcode = filter.outputImage {
                if let qrCodeImage = context.createCGImage(qrcode, from: qrcode.extent) {
                    return UIImage(cgImage: qrCodeImage)
                }
            }
            } catch {
                print("Error serializando JSON: \(error)")
            }
        return UIImage(systemName: "xmark") ?? UIImage()
    }
}

#Preview {
    QRCodeGenerate(data: ["id" : "1", "cancelled" : false])
}
