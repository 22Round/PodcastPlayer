//
//  Extentions.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/19/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() ->MainTabBarController? {
        return shared.keyWindowInConnectedScenes?.rootViewController as? MainTabBarController
    }
}
