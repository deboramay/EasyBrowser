//
//  ViewController.swift
//  EasyBrowser
//
//  Created by Anastasia on 15.04.2022.
//
import WebKit
import UIKit

class ViewController: UIViewController, WKNavigationDelegate {
  
  var webView: WKWebView!
  var progressView: UIProgressView!
  var websites = ["apple.com", "hackingwithswift.com"]
  
  //First, we create a new instance of Apple's WKWebView web browser component and assign it to the webView property.
  //Second - Delegation.
  //Third, we make our view (the root view of the view controller) that web view.
  override func loadView() {
    webView = WKWebView()
    webView.navigationDelegate = self
    view = webView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //The first line creates a new data type called URL, which is Swift’s way of storing the location of files. The second line does two things: it creates a new URLRequest object from that URL, and gives it to our web view to load.The third line enables a property on the web view that allows users to swipe from the left or right edge to move backward or forward in their web browsing.
    let url = URL(string: "https://" + websites[0])!
    webView.load(URLRequest(url: url))
    webView.allowsBackForwardNavigationGestures = true
    //The addObserver() method takes four parameters: who the observer is (we're the observer, so we use self), what property we want to observe (we want the estimatedProgress property of WKWebView), which value we want (we want the value that was just set, so we want the new one), and a context value.
    webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
    
    progressView = UIProgressView(progressViewStyle: .default)
    progressView.sizeToFit()
    let progressButton = UIBarButtonItem(customView: progressView)
    
    //We're creating a new bar button item using the special system item type .flexibleSpace, which creates a flexible space. It doesn't need a target or action because it can't be tapped.
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
    let goBack = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: webView, action: #selector(webView.goBack))
    let goForward = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: webView, action: #selector(webView.goForward))
    
    //The first creates an array containing the flexible space and the refresh button, then sets it to be our view controller's toolbarItems array. The second sets the navigation controller's isToolbarHidden property to be false, so the toolbar will be shown – and its items will be loaded from our current view.
    toolbarItems = [goBack, spacer, progressButton, spacer, refresh, spacer, goForward]
    navigationController?.isToolbarHidden = false
  }
  
  @objc func openTapped() {
    let ac = UIAlertController(title: "Open page…", message: nil, preferredStyle: .actionSheet)
    for website in websites {
      ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
    }
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    //popoverPresentationController?.barButtonItem property is used only on iPad, and tells iOS where it should make the action sheet be anchored
    ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
    present(ac, animated: true)
  }
  
  //What the method does is use the title property of the action (apple.com, hackingwithswift.com), put "https://" in front of it to satisfy App Transport Security, then construct a URL out of it. It then wraps that inside an URLRequest, and gives it to the web view to load.
  func openPage(action: UIAlertAction) {
    let url = URL(string: "https://" + action.title!)!
    webView.load(URLRequest(url: url))
  }
  
  //All this method does is update our view controller's title property to be the title of the web view, which will automatically be set to the page title of the web page that was most recently loaded.
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    title = webView.title
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "estimatedProgress" {
      progressView.progress = Float(webView.estimatedProgress)
    }
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    let url = navigationAction.request.url

    if let host = url?.host {
      for website in websites {
        if host.contains(website) {
          decisionHandler(.allow)
          return
        }
      }
      // If user somehow access a URL that isn't allowed, then show a blocking alert
      showBlockAlert()
    }
    decisionHandler(.cancel)
  }

  // Method to show a blocked website alert
  func showBlockAlert() {
    let ac = UIAlertController(title: "Blocked website", message: "Unfortunately, this website is not in the website catalog", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    present(ac, animated: true)
  }
  
  
}

