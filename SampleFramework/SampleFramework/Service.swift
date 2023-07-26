//
//  Service.swift
//  SampleFramework
//
//  Created by Bank-Genie PC3 on 26/07/23.
//

import Foundation

public class Service {
    private init() {}
    
    public static func doSomething() -> String {
        let scanner = ScannerViewController.init(verticalLabelMessage: "Test Welcome")
        scanner.navigationController?.pushViewController(scanner, animated: true)
        return "Welcome"
    }
}
