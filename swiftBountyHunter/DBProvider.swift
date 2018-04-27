//
//  DBProvider.swift
//  swiftBountyHunter
//
//  Created by Developer on 4/19/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DBProvider {
    // Apuntador de la base de datos
    var db: OpaquePointer? = nil
    // Variable para capturar los errores provenientes de la base de datos
    var error: String? = nil
    
    // Definición de constantes para el manejo de gestión de la base de datos
    let DATA_BASE_NAME = "swiftBH.sqlite"
    let DATA_TABLE_NAME = "Fugitivos"
    let COLUMN_NAME_ID = "id"
    let COLUMN_NAME_NAME = "nombre"
    let COLUMN_NAME_STATUS = "estatus"
    
    init(crear: Bool) {
        // Se evaluará si se creará la base de datos. Si es false, retornará sin crear la base de datos
        if !crear {
            return
        }
        // Se inicializa la base de datos esperando no ocurra un error
        if dbCreate() {
            // Se ejecuta la sentencia DDL de creación de la tabla
            if !createDDL() {
                print("DBProvider:init() --> Error devuelto por el método createDDL()")
            }
            // Se cierra la base de datos
            if !dbClose() {
                print("DBProvider:init() --> Error devuelto por el método dbClose()")
            }
        }
    }
    
    // Método para la creación o apertura de la base de datos
    func dbCreate() -> Bool {
        // Se obtiene el path del sandbox de la aplicación (carpeta de documentos)
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        // Se adjunta al path el nombre del archivo de la base de datos
        let fileURI = documents.appendingPathComponent("\(DATA_BASE_NAME)")
        
        // Se imprime la ruta en la que se guardará la base de datos.
        print(fileURI)
        
        // Se crea la base de datos y si ya existe solemente la abre
        if sqlite3_open(fileURI.path, &db) != SQLITE_OK {
            print("DBProvider:dbInitial() --> Error al tratar de crear/abrir la base de datos")
            return false
        }
        return true
    }
    
    // Método para cerrar la base de datos
    func dbClose() -> Bool {
        // Se cierra la base de datos
        if sqlite3_close(db) != SQLITE_OK {
            print("DBProvider:dbClose --> Error al cerrar la base de datos")
            return false
        }
        return true
    }
    
    // Método para la creación de la tabla Fugitivos
    func createDDL() -> Bool {
        // Se ejecuta la sentencia de ejecución de la tabla
        if sqlite3_exec(db, "create table if not exists \(DATA_TABLE_NAME) (\(COLUMN_NAME_ID) integer primary key autoincrement, \(COLUMN_NAME_NAME) text, \(COLUMN_NAME_STATUS) integer)", nil, nil, nil) != SQLITE_OK {
            
            error = String(cString: sqlite3_errmsg(db))
            print("DBProvider:createDDL() --> Error creando la tabla fugitivos: \(error)")
            error = nil
            return false
        }
        return true
    }
    
    // Método para insertar los fugitivos
    func insertarFugitivo(nombre: String) {
        // Se realiza la apertura de la base de datos
        if dbCreate() {
            // Se crea el apuntador para la sentencia
            var sentencia: OpaquePointer? = nil
            // Se crea la sentencia insert
            if sqlite3_prepare_v2(db, "insert into \(DATA_TABLE_NAME) (\(COLUMN_NAME_NAME), \(COLUMN_NAME_STATUS)) values (?, 0)", -1, &sentencia, nil) == SQLITE_OK {
                // Se adjunta la variable nombre a la sentencia insert
                if sqlite3_bind_text(sentencia, 1, "\(nombre)", -1, nil) == SQLITE_OK {
                    // Se ejecuta la sentencia insert
                    if sqlite3_step(sentencia) != SQLITE_DONE {
                        error = String(cString: sqlite3_errmsg(db))
                    }
                }
                else {
                    error = String(cString: sqlite3_errmsg(db))
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else {
                error = String(cString: sqlite3_errmsg(db))
            }
            // Se imprime el error y se limpia la variable en caso de que no es nil o out of memory
            if error != nil && error! != "out of memory" {
                print("DBProvider:insertarFugitivos() --> Error en la creación/ejecución de la sentencia insert: \(error)")
                error = nil
            }
            // Se cierra la base de datos
            if !dbClose() {
                print("DBprovider:insertarFugitivos() --> Error devuelto por el método dbClose()")
            }
        }
    }
    
    // Método para actualizar el estatus del fugitivo
    func actualizarFugitivo(pID: String, pEstatus: String) {
        // Se realiza la apertura de la base de datos
        if dbCreate() {
            // Se crea el apuntador para la sentencia
            var sentencia: OpaquePointer? = nil
            // Se crea la sentencia update
            if sqlite3_prepare_v2(db, "update \(DATA_TABLE_NAME) set \(COLUMN_NAME_STATUS) = ? where \(COLUMN_NAME_ID) = ?", -1, &sentencia, nil) == SQLITE_OK {
                // Se adjunta la variable estatus para colocarlo como capturado
                if sqlite3_bind_int(sentencia, 1, Int32(pEstatus)!) == SQLITE_OK {
                    // Se adjunta la variable id para colocarlo en el where como filtro
                    if sqlite3_bind_int(sentencia, 2, Int32(pID)!) == SQLITE_OK {
                        if sqlite3_step(sentencia) != SQLITE_DONE {
                            error = String(cString: sqlite3_errmsg(db))
                        }
                    }
                    else {
                        error = String(cString: sqlite3_errmsg(db))
                    }
                }
                else {
                    error = String(cString: sqlite3_errmsg(db))
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else {
                error = String(cString: sqlite3_errmsg(db))
            }
            // Se imprime el error y se limpia la variable en caso de no sea nil o out of memory
            if error != nil && error! != "out of memory" {
                print("DBProvider:actializarFugitivo() --> Error en la creación/ejecución de la sentencia update: \(error)")
                error = nil
            }
            // Se cierra la base de datos
            if !dbClose() {
                print("DBProvider:actializarFugitivo() --> Error devuelto por el método dbClose()")
            }
        }
    }
    
    func getFugitivoById(pId: String) -> (nombre: String, estatus: String) {
        // Se crea el apuntador para la sentencia
        dbCreate()
        var sentenciaSelect: OpaquePointer? = nil
        sqlite3_prepare_v2(db, "select \(COLUMN_NAME_NAME), \(COLUMN_NAME_STATUS) from \(DATA_TABLE_NAME) where \(COLUMN_NAME_ID) = ?", -1, &sentenciaSelect, nil)
        sqlite3_bind_int(sentenciaSelect, 1, Int32(pId)!)
        sqlite3_step(sentenciaSelect)
        let nombre = String(cString: sqlite3_column_text(sentenciaSelect, 0))
        let estatus = String(cString: sqlite3_column_text(sentenciaSelect, 1))
        sqlite3_finalize(sentenciaSelect)
        dbClose()
        
        return (nombre, estatus)
    }
    
    func guardarFugitivoEnEliminidos(nombre: String, estatus: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fugitivoEntity = NSEntityDescription.entity(forEntityName: "Fugitivo", in: managedContext)!
        
        let fugitivo = NSManagedObject(entity: fugitivoEntity, insertInto: managedContext)
        
        fugitivo.setValue(nombre, forKey: "nombre")
        fugitivo.setValue(estatus, forKey: "estatus")
        
        do {
            try managedContext.save()
            print("Se ha eliminado........")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
        let fugitivos = obtenerFugitivosEliminados()
        
        print("-------------------------")
        for fugitivo in fugitivos {
            let nombreFugitivo = fugitivo.nombre
            let estatusFugitivo = fugitivo.estatus
            
            print("Name: \(nombreFugitivo!)")
            print("Estatus: \(estatusFugitivo!)")
        }
        print("-------------------------")
    }
    
    func obtenerFugitivosEliminados() -> [Fugitivo] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fugitivoFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Fugitivo")
        
        let fugitivos = try! managedContext.fetch(fugitivoFetch) as! [Fugitivo]
        
        return fugitivos
    }
    
    // Método para eliminar el fugitivo
    func eliminarFugitivo(pID: String) {
        // Recuperamos nombre y estatus para guardar el registro eliminado en la base de datos de eliminados
        let fugitivoEliminado = getFugitivoById(pId: pID)
        
        // Se realiza la apertura de la base de datos
        if (dbCreate()) {
            // Se crea el apuntador para la sentendia
            var sentencia: OpaquePointer? = nil
            // Se crea la sentencia delete
            if sqlite3_prepare_v2(db, "delete from \(DATA_TABLE_NAME) where \(COLUMN_NAME_ID) = ?", -1, &sentencia, nil) == SQLITE_OK {
                // Se adjunta la variable id para colocarla en el where como filtro
                if sqlite3_bind_int(sentencia, 1, Int32(pID)!) == SQLITE_OK {
                    
                    if sqlite3_step(sentencia) != SQLITE_DONE {
                        error = String(cString: sqlite3_errmsg(db))
                    }
                    else {
                        guardarFugitivoEnEliminidos(nombre: fugitivoEliminado.nombre, estatus: fugitivoEliminado.estatus)
                    }
                }
                else {
                    error = String(cString: sqlite3_errmsg(db))
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else {
                error = String(cString: sqlite3_errmsg(db))
            }
            // Se imprime el error y se limpia la variable en caso de que no sea nil o out of memory
            if error != nil && error! != "out of memory" {
                print("DBProvider:eliminarFugitivo() --> Error en la creación/ejecución de la sentencia delete: \(error)")
                error = nil
            }
            // Se cierra la base de datos
            if !dbClose() {
                print("DBProvider:eliminarFugitivo() --> Error devuelto por el método dbClose()")
            }
        }
    }
    
    // Método para obtener los fugitivos
    func obtenerFugitivos(pEstatus: String) -> Array<Array<String>> {
        var datosFugitivos = Array<Array<String>>()
        // Se realiza la apertura de la base de datos
        if dbCreate() {
            // Se crea el apuntador para la sentencia
            var sentencia: OpaquePointer? = nil
            // Se crea la sentencia select
            if sqlite3_prepare_v2(db, "select * from \(DATA_TABLE_NAME) where \(COLUMN_NAME_STATUS) = ?", -1, &sentencia, nil) == SQLITE_OK {
                // Se adjunta la variable estatus
                if sqlite3_bind_int(sentencia, 1, Int32(pEstatus)!) == SQLITE_OK {
                    // Ejecución de la sentencia por row y obtención de la información
                    while sqlite3_step(sentencia) == SQLITE_ROW {
                        let id = String(sqlite3_column_int(sentencia, 0))
                        let nombre = String(cString: sqlite3_column_text(sentencia, 1))
                        datosFugitivos.append(Array(arrayLiteral: id, nombre))
                    }
                }
                else {
                    error = String(cString: sqlite3_errmsg(db))
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else {
                error = String(cString: sqlite3_errmsg(db))
            }
            // Se imprime el error
            if error != nil && error! != "out of memory" {
                print("DBProvider:obtenerFugitivos() -> Error en la creación/ejecución de la sentencia: \(error)")
            }
            // Se cierra la base de datos
            if !dbClose() {
                print("DBProvider:obtenerFugitivos() -> Error devuelto por el método dbClose()")
            }
        }
        return datosFugitivos
    }
    
    func contarFugitivos() -> Int {
        var dato: Int?
        
        if dbCreate() {
            var sentencia: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, "select count(*) from \(DATA_TABLE_NAME)", -1, &sentencia, nil) == SQLITE_OK {
                if sqlite3_step(sentencia) == SQLITE_ROW {
                    let id = sqlite3_column_int(sentencia, 0)
                    dato = Int(id)
                }
                if sqlite3_finalize(sentencia) != SQLITE_OK {
                    error = String(cString: sqlite3_errmsg(db))
                }
            }
            else {
                error = String(cString: sqlite3_errmsg(db))
            }
            if error != nil && error! != "out of memory" {
                print("DBProvider:contarFugitivos() --> Error en la creación/ejecución de la sentencia select: \(error)")
                error = nil
            }
            if !dbClose() {
                print("DBProvider:contarFugitivos() --> Error devuelto por el método dbClose()")
            }
        }
        return dato!
    }
    
}
