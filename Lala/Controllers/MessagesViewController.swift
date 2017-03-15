//
//  MessagesViewController.swift
//  Lala
//
//  Created by Görkem Karahan on 21/02/2017.
//  Copyright © 2017 Görkem Karahan. All rights reserved.
//

import UIKit
import Alamofire

protocol MessagesViewControllerDelegate {
    func leaveButtonPressed(onController:MessagesViewController)
}

class MessagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    @IBOutlet weak var collectionVMessages: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityIndLoading: UIActivityIndicatorView!
    @IBOutlet weak var textVMessage: GKTextView!
    @IBOutlet weak var navigationIHeader: UINavigationItem!
    @IBOutlet weak var cnstraintComposerToBottom: NSLayoutConstraint!
    @IBOutlet weak var lblErrorDescription: UILabel!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var cnstraintTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewComposerContainer: UIView!
    
    var delegate:MessagesViewControllerDelegate?
    
    private let lblTempForCalculation:UILabel = UILabel()
    private var keyboardHeight:CGFloat = 0
    private let initialTextFHeight:CGFloat = 33
    
    public var user:User?
    
    let kMessagePositionLeftCellIdentifier = "MessagePositionLeftCollectionViewCell"
    let kMessagePositionRightCellIdentifier = "MessagePositionRightCollectionViewCell"
    
    var messages:[Message]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellsToCollectionView()
        prepareNavigationItems()
        prepareTempLabel()
        getMessagesFromServer()
        prepareSwipeGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getMessagesFromServer () {
        self.activityIndLoading.startAnimating()
        self.lblErrorDescription.alpha = 0
        Alamofire.request("https://jsonblob.com/api/jsonBlob/3cf871b2-f7cd-11e6-95c2-115605632e53").responseCollection{ (res : DataResponse<[Message]>) in
            if res.result.isFailure {
                self.activityIndLoading.stopAnimating()
                self.collectionVMessages.alpha = 0
                self.lblErrorDescription.text = "We encountered an error, please try again later or refresh from right top"
                UIView.animate(withDuration: 0.6, animations: {
                    self.lblErrorDescription.alpha = 1
                })
                
            } else {
                if let resultMessages = res.result.value {
                    self.messages = resultMessages
                    self.activityIndLoading.stopAnimating()
                    self.collectionVMessages.reloadData()
                    self.lblErrorDescription.alpha = 0
                    
                    UIView.animate(withDuration: 0.6, animations: {
                        self.collectionVMessages.alpha = 1
                    }, completion: { (_) in
                        self.scrollCollectionToBottom()
                    })
                }
            }
        }
        
    }
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        collectionVMessages.performBatchUpdates({
            self.messages?.append( Message(id: (self.messages?.count)!, text: self.textVMessage.text, timeStamp: Date().timeIntervalSince1970, user: self.user!))
            self.collectionVMessages.insertItems(at: [IndexPath(item: self.messages!.count-1, section: 0)])
            self.textVMessage.text = nil
        }) { (_) in
             self.textViewDidChange(self.textVMessage)
        }
    }
    
    func logOutButtonPressed() {
        if let delegat = delegate {
            delegat.leaveButtonPressed(onController: self)
        }
    }
    
    func scrollCollectionToBottom() {
        if (messages?.count)! > 0 {
            self.collectionVMessages.scrollToItem(at: IndexPath(item: self.messages!.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func prepareTempLabel() {
        lblTempForCalculation.numberOfLines = 0
        lblTempForCalculation.font = UIFont.systemFont(ofSize: 15.0)
    }
    
    func prepareSwipeGestureRecognizer() {
        let gestureRecognizerCloseKeyboard = UISwipeGestureRecognizer(target: self.textVMessage, action: #selector(resignFirstResponder))
        gestureRecognizerCloseKeyboard.direction = .down
        self.view.addGestureRecognizer(gestureRecognizerCloseKeyboard)
    }
    
    func prepareNavigationItems() {
        navigationIHeader.leftBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(logOutButtonPressed))
        navigationIHeader.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(getMessagesFromServer))
        navigationIHeader.title = user?.nickname
    }
    
    func registerCellsToCollectionView() {
        self.collectionVMessages.register(UINib(nibName: kMessagePositionLeftCellIdentifier, bundle: nil), forCellWithReuseIdentifier: kMessagePositionLeftCellIdentifier)
        self.collectionVMessages.register(UINib(nibName: kMessagePositionRightCellIdentifier, bundle: nil), forCellWithReuseIdentifier: kMessagePositionRightCellIdentifier)
    }
    
    // MARK: - UICollectionViewDataSource UICollectionViewDelegate Methods
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell:MessageCollectionViewCell
        if messages![indexPath.row].user.id != 6 {
            cell  = collectionView.dequeueReusableCell(withReuseIdentifier: kMessagePositionLeftCellIdentifier, for: indexPath) as! MessageCollectionViewCell
        } else {
            cell  = collectionView.dequeueReusableCell(withReuseIdentifier: kMessagePositionRightCellIdentifier, for: indexPath) as! MessageCollectionViewCell
        }
        cell.preparefor(message: messages![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //NOTE: Width except label:120  height except label:68
        lblTempForCalculation.text = self.messages?[indexPath.row].text
        let size = lblTempForCalculation.sizeThatFits(CGSize(width:self.view.frame.size.width - 120, height:CGFloat(MAXFLOAT)))
        return CGSize(width:self.view.frame.size.width , height:max(size.height, 18) + 68)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: Keyboard notification methods
    func keyboardWillShow(notification:NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect).height
        cnstraintComposerToBottom.constant = keyboardHeight
        UIView.animate(withDuration: duration.doubleValue) {
            self.setCollectionContentScollInsetsForHeight(height: (self.keyboardHeight + (self.cnstraintTextViewHeight.constant - self.initialTextFHeight)))
            self.scrollCollectionToBottom()
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        cnstraintComposerToBottom.constant = 0
        keyboardHeight = 0
        UIView.animate(withDuration: duration.doubleValue) {
            self.setCollectionContentScollInsetsForHeight(height: (self.cnstraintTextViewHeight.constant - self.initialTextFHeight))
            self.view.layoutIfNeeded()
        }
    }
    
    func setCollectionContentScollInsetsForHeight(height:CGFloat){
        collectionVMessages.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        collectionVMessages.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
    }
    
    // MARK: UITextviewDelegate Methods
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.characters.count > 0 {
            lblPlaceHolder.alpha = 0
        } else {
            lblPlaceHolder.alpha = 1
        }
        
        
        var finalHeight = textView.sizeThatFits(CGSize(width:textView.frame.width, height:CGFloat(MAXFLOAT))).height
        if finalHeight > 60 {
            finalHeight = 60
        }
        cnstraintTextViewHeight.constant = finalHeight
        self.setCollectionContentScollInsetsForHeight(height:keyboardHeight + (finalHeight-initialTextFHeight))
        self.scrollCollectionToBottom()
    }
    
    //MARK Rotation Methods
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.collectionVMessages.collectionViewLayout.invalidateLayout()
            self.collectionVMessages.reloadData()
            self.scrollCollectionToBottom()
        }, completion:nil)
    }
}
