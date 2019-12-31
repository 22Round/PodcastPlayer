//
//  PlayerDetailsView+Gestures.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/19/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import UIKit

extension PlayerDetailsView {
    
    func setupGestures(){
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTabMaximize)))
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan)))
    }
    
    @objc func handleDismissPan(gesture:UIPanGestureRecognizer){
        if gesture.state == .changed {
            let translation = gesture.translation(in: self.superview)
            self.transform = CGAffineTransform(translationX: 0, y: translation.y)
            
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: self.superview)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.transform = .identity
                
                if translation.y > 50  {
                    
                    UIApplication.mainTabBarController()?.minimizePlayerDetails()
                }
                
            })
        }
    }
    
    
    @objc func handlePan(gesture:UIPanGestureRecognizer){
        
        if gesture.state == .changed {
            handlePanChanged(gesture: gesture)
            
        } else if gesture.state == .ended {
            handlePanEnded(gesture: gesture)
        }
    }
    
    fileprivate func handlePanChanged(gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    fileprivate func handlePanEnded(gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.translation(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            
            if translation.y < -200 || velocity.y < -500 {
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
            }else {
                self.miniPlayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        })
    }
    
    @objc func handleTabMaximize() {
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
    }
    
}
