//
//  ViewController.swift
//  swiftBountyHunter
//
//  Created by Developer on 4/18/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate {

    @IBOutlet var tableView: UITableView!
    
    let textCellidentifier = "TextCell"
        
    // Matriz de fugitivos
    var swiftFugitivos: Array<Array<String>> = []
    // Variable de base de datos
    var dbFugitivos: DBProvider?
    // Variable estática de control de pestañas y carga de información
    static var indexchange = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if self.dbFugitivos == nil {
            self.dbFugitivos = DBProvider(crear: true)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.tabBarController?.delegate = self as UITabBarControllerDelegate
        
        let funcion = {
            (error: Int) in
            if error != 1 {
                DispatchQueue.main.async {
                    self.cargarListadoFugitivos(estatus: String(self.tabBarController!.selectedIndex))
                    self.tableView.reloadData()
                }
            }
            else {
                DispatchQueue.main.async {
                    let alerta = UIAlertController(title: "Error", message: "Error al consumir el WebService verbo GET", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alerta, animated: true, completion: nil)
                }
            }
        }
        
        if (dbFugitivos?.contarFugitivos())! <= 0 {
            let ws: NetServices = NetServices()
            ws.connectGET(completado: funcion)
        }
        
        cargarListadoFugitivos(estatus: "0")
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Evento para cerrar la ventana modal cuando se le de click al botón "cancel" desde "Agregar" o "Detalle"
    @IBAction func Cancel(_ unwindSegue: UIStoryboardSegue) {
        // Imprime el nombre desde el cual se mandó llamar
        print(unwindSegue.identifier!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return swiftFugitivos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellidentifier)! as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = swiftFugitivos[row][1]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "DetalleFugitivos" || segue.identifier == "DetalleCapturados") {
            let detalleController: DetalleViewController = segue.destination as! DetalleViewController
            detalleController.NombreFugitivo = swiftFugitivos[tableView.indexPathForSelectedRow!.row][1]
            detalleController.id = swiftFugitivos[tableView.indexPathForSelectedRow!.row][0]
            detalleController.Estatus = String(self.tabBarController!.selectedIndex)
        }
        
    }
    
    // Método para cargar los datos de los fugitivos de la base de datos
    func cargarListadoFugitivos(estatus: String) {
        swiftFugitivos.removeAll()
        swiftFugitivos = dbFugitivos!.obtenerFugitivos(pEstatus: estatus)
    }
    
    // Evento para cerrar la ventana de agregar/eliminar/capturar y actualizar las listas
    @IBAction func segueInsUpdDel(_ unwindSegue: UIStoryboardSegue) {
        print(unwindSegue.identifier!)
        
        if unwindSegue.identifier == "Agregar" {
            ViewController.indexchange = 1
            viewDidAppear(false)
        }
        else {
            cargarListadoFugitivos(estatus: String(self.tabBarController!.selectedIndex))
            print("myUnwindAction: \(String(self.tabBarController!.selectedIndex))")
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if ViewController.indexchange == 1 {
            DispatchQueue.main.async {
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        ViewController.indexchange = 0
        
        cargarListadoFugitivos(estatus: String(self.tabBarController!.selectedIndex))
        self.tableView.reloadData()
        
        if self.tabBarController?.selectedIndex == 0 {
            viewWillAppear(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        DispatchQueue.main.async {
            self.cargarListadoFugitivos(estatus: String(self.tabBarController!.selectedIndex))
            self.tableView.reloadData()
        }
    }
    
    func Eliminar(tableView: UITableView, indexPath: IndexPath) {
        // Se elimina el fugitivo
        let dbFugitivos = DBProvider(crear: false)
        dbFugitivos.eliminarFugitivo(pID: self.swiftFugitivos[indexPath.row][0])
        self.swiftFugitivos.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
    func Capturar(tableView: UITableView, indexPath: IndexPath) {
        let dbFugitivos = DBProvider(crear: false)
        dbFugitivos.actualizarFugitivo(pID: self.swiftFugitivos[indexPath.row][0], pEstatus: "1")
        self.swiftFugitivos.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        
        let funncion = {
            (error: Int, mensaje: String?) in
            if error != 1 {
                DispatchQueue.main.async {
                    let alerta = UIAlertController(title: "Información", message: "\(mensaje)", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: {okPulso in print("pulsó el botón OK")} ))
                    self.present(alerta, animated: true, completion: nil)
                }
            }
            else {
                DispatchQueue.main.async {
                    let alerta = UIAlertController(title: "Error", message: "Error al consumir el WebService verbo POST", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: {
                        okPulso in
                        print("pulsó el botón OK")
                    }))
                    self.present(alerta, animated: true, completion: nil)
                }
            }
        }
        
        let ws: NetServices = NetServices()
        let udid = UIDevice.current.identifierForVendor?.uuidString
        ws.connectPOST(udid: udid!, completado: funncion)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let capturar = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Capturar", handler: {
            (action: UITableViewRowAction, indexPath: IndexPath!) -> Void in
            self.Capturar(tableView: tableView, indexPath: indexPath)
        })
        
        let eliminar = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Eliminar", handler: {
            (action: UITableViewRowAction, indexPath: IndexPath!) -> Void in
            self.Eliminar(tableView: tableView, indexPath: indexPath as IndexPath)
        })
        
        if self.tabBarController!.selectedIndex == 0 {
            return [capturar, eliminar]
        }
        
        return [eliminar]
    }
    
    @IBAction func showSheet(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Log de Eliminación", message: "Selecciona un elemento", preferredStyle: .actionSheet)
        
        let funcion = { (uiAlertAction: UIAlertAction) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LogEliminacionViewController")
            self.present(controller, animated: true, completion: nil)
        }
        
        
        alert.addAction(UIAlertAction(title: "Eliminados", style: .default, handler: funcion))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
}

