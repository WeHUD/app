//
//  ModalViewController.swift
//  Gzone_App
//
//  Created by Tracy Sablon on 09/07/2017.
//  Copyright © 2017 Tracy Sablon. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController ,UIWebViewDelegate {

    var webV:UIWebView! = nil
    var closeWebView : UIButton!
    var videoURL : String!
    var videoId : String!
    var ai : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set ModalView transparancy
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.isOpaque = false
        
        self.webV = UIWebView(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
        self.webV.delegate = self;
        // Play video with native player
        webV.allowsInlineMediaPlayback = true
        webV.mediaPlaybackRequiresUserAction = false
        webV.backgroundColor = UIColor.black
        webV.isOpaque = false
        self.view.addSubview(webV)
        
        self.closeWebView = UIButton(frame: CGRect(x: 0, y: 10, width: self.view.frame.width, height: 100))
        self.closeWebView.setImage(UIImage(named:"closeIcon"), for: UIControlState.normal)
        self.closeWebView.setTitle("  Return to feeds", for: UIControlState.normal)
        self.view.addSubview(closeWebView)
        
        // Set webView constraints
        webV.translatesAutoresizingMaskIntoConstraints = false
        setupWebViewConstraints()
        
        // Create a UIActivityIndicatorView with the
        ai = UIActivityIndicatorView(frame: self.webV.frame)
        ai.color = UIColor.red
        // Add the UIActivityIndicatorView as a subview on the cell
        webV.addSubview(ai)
        
        // Extract youtube ID from URL
        videoId = videoURL.youtubeID
        
        print("video ID :" + videoId)
        
        // Load video data from Youtube from Utils extension
        loadYoutube(videoID : videoId)
        
        // Tap Gesture for closeWebView button
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(self.closeYoutubeModal(_:)))
        closeWebView.addGestureRecognizer(tapGesture)
    }
    
    func closeYoutubeModal(_ sender : UITapGestureRecognizer) {
        
        webV.stopLoading()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupWebViewConstraints() {
        
        let widthConstraint = NSLayoutConstraint(item: self.webV, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300)
        
        let heightConstraint = NSLayoutConstraint(item: self.webV, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200)
        
        let xConstraint = NSLayoutConstraint(item: self.webV, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yConstraint = NSLayoutConstraint(item: self.webV, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
        
        self.view.addConstraint(xConstraint)
        self.view.addConstraint(yConstraint)
    }
    
    
    
    func loadYoutube(videoID:String) {
    
        // Start the UIActivityIndicatorView animating
        ai.startAnimating()
        
        // Create a custom youtubeURL with the video ID
        guard
            let youtubeURL = NSURL(string: "https://www.youtube.com/embed/\(videoID)")
            else { return }
        // Load your web request
        self.webV.loadRequest( NSURLRequest(url: youtubeURL as URL) as URLRequest )
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ai.stopAnimating()
        ai.removeFromSuperview()
    }

}
