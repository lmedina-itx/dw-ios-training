//
//  DetalleViewController.swift
//  swiftBountyHunter
//
//  Created by Developer on 4/19/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit

class DetalleViewController: UIViewController {
    
    var NombreFugitivo: String!
    var Estatus: String!
    var id: String!
    
    @IBOutlet weak var NavigationBar: UINavigationBar!
    
    @IBOutlet weak var labelMensaje: UILabel!
    
    @IBOutlet weak var btnCapturar: UIButton!
    
    @IBOutlet weak var btnEliminar: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NavigationBar.topItem!.title = "\(NombreFugitivo!) - [\(id!)]"
        
        if Estatus == "0" {
            labelMensaje.text = "El fugitivo sigue suelto..."
        } else {
            btnCapturar.isHidden = true
            labelMensaje.text = "Atrapado!!!"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tabCapturar() {
        let dbFugitivos = DBProvider(crear: false)
        dbFugitivos.actualizarFugitivo(pID: id!, pEstatus: "1")
        
        let funcion = {
            (error: Int, mensaje: String?) in
            if error != 1 {
                DispatchQueue.main.async {
                    let alerta = UIAlertController(title: "Información", message: "\(mensaje!)", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: {
                        okPulso in
                            self.performSegue(withIdentifier: "Capturar", sender: nil)
                    }))
                    self.present(alerta, animated: true, completion: nil)
                }
            }
            else {
                DispatchQueue.main.async {
                    let alerta = UIAlertController(title: "Error", message: "Error al consumir el WebService verbo POST", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: {
                        okPulso in
                            self.performSegue(withIdentifier: "Capturar", sender: nil)
                    }))
                    self.present(alerta, animated: true, completion: nil)
                }
            }
        }
        
        let ws: NetServices = NetServices()
        let udid = UIDevice.current.identifierForVendor?.uuidString
        ws.connectPOST(udid: udid!, completado: funcion)
        btnCapturar.isHidden = true
        btnEliminar.isHidden = true
    }
    
    @IBAction func tabEliminar() {
        let dbFugitivos = DBProvider(crear: false)
        dbFugitivos.eliminarFugitivo(pID: id!)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
