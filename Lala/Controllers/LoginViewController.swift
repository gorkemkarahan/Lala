//
//  LoginViewController.swift
//  Lala
//
//  Created by Görkem Karahan on 21/02/2017.
//  Copyright © 2017 Migros. All rights reserved.
//

import UIKit
import KeychainSwift

class LoginViewController: UIViewController, MessagesViewControllerDelegate {
    
    @IBOutlet weak var textFNickname: UITextField!
    @IBOutlet weak var activityIndLoading: UIActivityIndicatorView!
    @IBOutlet weak var viewFormContrainer: UIView!
    @IBOutlet weak var cnstrntFormContainerCenterY:NSLayoutConstraint!
    
    override func viewDidAppear(_ animated: Bool) {
        let keychain = KeychainSwift()
        textFNickname.attributedPlaceholder = NSAttributedString(string: "Nickname", attributes: [NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)])
        textFNickname.layer.masksToBounds = true
        textFNickname.layer.cornerRadius = 4
        textFNickname.layer.borderWidth = 1
        textFNickname.layer.borderColor = UIColor.white.cgColor
        
        if let nick = keychain.get("nickname") {
            let storyboard = UIStoryboard(name:"Main", bundle:nil)
            let controller:MessagesViewController = storyboard.instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
            controller.delegate = self
            controller.user = User(id: 6, nickname: nick, avatarUrl: "https://randomuser.me/api/portraits/med/women/86.jpg")
            self.present(controller, animated: true, completion: nil)
            
        } else {
            self.activityIndLoading.stopAnimating()
            UIView.animate(withDuration: 0.6, animations: {
                self.viewFormContrainer.alpha = 1
            })
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if (textFNickname.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count)! > 2 {
            let storyboard = UIStoryboard(name:"Main", bundle:nil)
            let controller:MessagesViewController = storyboard.instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
            
            let keychain = KeychainSwift()
            keychain.set(self.textFNickname.text!, forKey: "nickname")
            
            controller.user = User(id: 6, nickname: textFNickname.text!, avatarUrl: "https://randomuser.me/api/portraits/med/women/86.jpg")
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else {
            self._shake(times: 10, direction: 1, currentTimes: 0, withDelta: 2, speed: 0.02, completion: nil)
        }
    }
    
    //MARK: MessagesViewControllerDelegate Methods
    func leaveButtonPressed(onController: MessagesViewController) {
        let keychain = KeychainSwift()
        keychain.delete("nickname")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK Keyboard notifications methods
    func keyboardWillShow(notification:NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let change = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        
        let centerY = self.view.center.y
        if centerY < change.size.height + (viewFormContrainer.frame.size.height/2) {
            cnstrntFormContainerCenterY.constant = -(change.size.height + (viewFormContrainer.frame.size.height/2) - centerY)
            UIView.animate(withDuration: duration.doubleValue) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        cnstrntFormContainerCenterY.constant = 0
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    
    //NOTE: imported and refactored from https://github.com/King-Wizard/UITextField-Shake-Swift
    private func _shake(times: Int, direction: Int, currentTimes current: Int, withDelta delta: CGFloat, speed interval: TimeInterval, completion handler: (() -> Void)?) {
        
        UIView.animate(withDuration: interval, animations: {
            self.textFNickname.transform = CGAffineTransform(translationX:delta * CGFloat(direction), y:0)
        }) { (finished) in
            if current >= times {
                UIView.animate(withDuration:interval, animations: {
                    () -> Void in
                    self.textFNickname.transform = CGAffineTransform.identity
                }, completion: {
                    (finished: Bool) in
                    if let handler = handler {
                        handler()
                    }
                })
                return
            }
            self._shake(times: times - 1,
                        direction: direction * -1,
                        currentTimes: current + 1,
                        withDelta: delta,
                        speed: interval,
                        completion: handler)
        }
    }
}
