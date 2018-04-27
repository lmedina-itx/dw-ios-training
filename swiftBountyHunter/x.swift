//
//  NetServices.swift
//  swiftBountyHunter
//
//  Created by Developer on 4/20/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import Foundation

class NetServices {
    let urlfugitivos = "http://201.168.207.210/Services/droidBHServices.svc/fugitivos"
    let urlatrapadosx = "http://201.168.207.210/Services/droidBHServices.svc/atrapados"
    
    func connectGET(completado: @escaping (_ error: Int) -> Void) {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        let dataTask = session.dataTask(with: URL(string: urlfugitivos)!, completionHandler: {
            data, urlResponse, error in
            var dialogError: Int = 0
            if data != nil {
                do {
                    let fugitivosJSON: Any? = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let fugitivos: NSArray = fugitivosJSON as! NSArray
                    let dbFugitivos: DBProvider = DBProvider(crear: false)
                    
                    for cnt in 0 ..< fugitivos.count {
                        let fugitivo = fugitivos[cnt]
                        let nombre:Dictionary<String, String> = fugitivo as! Dictionary<String, String>
                        dbFugitivos.insertarFugitivo(nombre: nombre["name"]!)
                    }
                }
                catch {
                    dialogError = 1
                }
            }
            else {
                dialogError = 1
            }
            completado(dialogError)
        })
        dataTask.resume()
    }
    
    func connectPOST(udid: String, completado: @escaping (_ error: Int, _ mensaje: String?) -> Void) {
        let diccionario: NSDictionary = NSDictionary(dictionary: ["UDIDString" : "\(udid)"])
        let parametrosData = try! JSONSerialization.data(withJSONObject: diccionario, options: JSONSerialization.WritingOptions(rawValue: 0))
        let parametros = String(data: parametrosData, encoding: String.Encoding.utf8)
        
        let configuracion = URLSessionConfiguration.default
        let session = URLSession(configuration: configuracion)
        
        var request = URLRequest(url: URL(string: urlatrapadosx)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = parametros!.data(using: String.Encoding.utf8)
        let dataTask = session.dataTask(with: request, completionHandler:
        {
            data, urlResponse, error in
            var msg: String?
            var dialogError: Int = 0
            if data != nil {
                do {
                    let mensajeJSON: Any? = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let mensaje:Dictionary<String, String> = mensajeJSON as! Dictionary<String, String>
                    print(mensaje["mensaje"]!)
                    msg = String(mensaje["mensaje"]!)
                }
                catch {
                    dialogError = 1
                }
            }
            else {
                dialogError = 1
            }
            completado(dialogError, msg)
        })
        dataTask.resume()
    }
}
