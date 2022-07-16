//
//  SideMenuViewModel.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/05/03.
//

import UIKit

class SideMenuViewModel {
    var defaultHighlightedCell: Int = 0
    
    var menu: [SideMenuModel] = [
        SideMenuModel(icon: UIImage(systemName: "house.fill")!, title: "Home"),
        SideMenuModel(icon: UIImage(systemName: "music.note")!, title: "Music"),
        SideMenuModel(icon: UIImage(systemName: "film.fill")!, title: "Movies"),
        SideMenuModel(icon: UIImage(systemName: "book.fill")!, title: "Books"),
        SideMenuModel(icon: UIImage(systemName: "person.fill")!, title: "Profile"),
        SideMenuModel(icon: UIImage(systemName: "slider.horizontal.3")!, title: "Settings"),
        SideMenuModel(icon: UIImage(systemName: "rectangle.portrait.and.arrow.right")!, title: "Logout")
    ]
    
    func setInitialView(emailLabel: UILabel, sideMenuTableView: UITableView, footerLabel: UILabel) {
        emailLabel.text = "\(UserInfo.shared.name!)님 반갑습니다."
        
        sideMenuTableView.backgroundColor = .systemBlue
        sideMenuTableView.separatorStyle = .none
        
        // Set Highlighted Cell
        DispatchQueue.main.async {
            let defaultRow = IndexPath(row: self.defaultHighlightedCell, section: 0)
            sideMenuTableView.selectRow(at: defaultRow, animated: false, scrollPosition: .none)
        }

        // Footer
        footerLabel.textColor = UIColor.white
        footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        footerLabel.text = "Developed by Yoo Seungwon"

        // Register TableView Cell
        sideMenuTableView.register(SideMenuCell.nib, forCellReuseIdentifier: SideMenuCell.identifier)

        // Update TableView with the data
        sideMenuTableView.reloadData()
    }
    
    func logout() {
        CategoryViewModel.shared.logout()
        ClothesViewModel.shared.logout()
    }
}
