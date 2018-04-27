//
//  LogEliminacionViewController.swift
//  swiftBountyHunter
//
//  Created by Developer on 4/27/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit

class LogEliminacionTableViewCell: UITableViewCell {
    @IBOutlet weak var labelNombre: UILabel!
    @IBOutlet weak var labelEstatus: UILabel!
}

class LogEliminacionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // Matriz de fugitivos
    var eliminados: [Fugitivo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        let dbFugitivos = DBProvider(crear: false)
        eliminados.removeAll()
        eliminados = dbFugitivos.obtenerFugitivosEliminados()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eliminados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCellNombre")! as! LogEliminacionTableViewCell
        
        let row = indexPath.row
        
        cell.labelNombre?.text = eliminados[row].nombre
        
        if eliminados[row].estatus == "0" {
            cell.labelEstatus?.text = "Fugitivo"
        }
        else {
            cell.labelEstatus?.text = "Capturado"
        }
        
        return cell
    }

}
