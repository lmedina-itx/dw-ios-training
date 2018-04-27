//
//  AcercaDeViewController.swift
//  swiftBountyHunter
//
//  Created by Developer on 4/18/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit

class AcercaDeViewController: UIViewController
{

    @IBOutlet weak var labelContador: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var udefault: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userdefault = UserDefaults.standard
        
        if let def = userdefault.string(forKey: "sliderValue") {
            udefault = String(def)
            slider.setValue(Float(udefault)!, animated: true)
            labelContador.text = udefault
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        labelContador.text = "\(currentValue)"
        
        let userdefault = UserDefaults.standard
        userdefault.set(currentValue, forKey: "sliderValue")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
