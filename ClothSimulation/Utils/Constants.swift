//
//  Constants.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/19.
//

struct K {
    static let appName = "BestFit"
    
    // Segue Names
    static let registerToFitSegue = "RegisterToHome"
    static let loginInToFitSegue = "LogInToHome"
    static let welcomeToFitSegue = "WelcomeToHome"
    static let welcomeToLogInSegue = "WelcomeToLogIn"
    static let fitToWelcome = "FitToWelcome"
    static let welcomeToRegister = "welcomeToRegister"
    static let tabBarToWelcome = "tabBarToWelcome"
    
    // Firebase Storage
    static let storageURL = "gs://clothsimulation-3af50.appspot.com/"
    
    // Model Info
    static let dancingMan = "art.scnassets/FinalBaseMesh.obj"
    static let ordinaryMan = "art.scnassets/FinalBaseMesh.obj"
    static let SMPLMan = "art.scnassets/SMPL_male.obj"
    static let SMPLWoman = "art.scnassets/SMPL_female.obj"
}
