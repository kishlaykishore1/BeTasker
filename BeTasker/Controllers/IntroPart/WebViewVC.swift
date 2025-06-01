//
//  WebViewVC.swift
//  EasyAC
//
//  Created by MAC3 on 04/05/23.
//

import UIKit
import WebKit

class WebViewVC: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: Properties
    public var url = ""
    var titleString = ""
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if url != "" {
            if let strWithoutSpace = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
                if let url = URL(string: strWithoutSpace) {
                    webView.load(URLRequest(url: url))
                }
            }
        }
        
        webView.navigationDelegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        
        setBackButton(isImage: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationBarImage(color: UIColor.colorFFFFFF000000, txtcolor: UIColor.color262626, requireShadowLine: true)
        self.navigationItem.title = titleString
        
    }
    
    override func backBtnTapAction() {
        Global.setVibration()
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: UIWebViewDelegate
extension WebViewVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Global.showLoadingSpinner()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Global.dismissLoadingSpinner()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Global.dismissLoadingSpinner()
        print(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, url.absoluteString != self.url else {
            decisionHandler(.allow)
            return
        }

        if url.scheme == "http" || url.scheme == "https" {
            // It's an HTML link with an HTTP or HTTPS scheme
            print("Detected link: \(url.absoluteString)")
            // Perform any additional handling as needed
            let vc = Constants.Main.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            vc.titleString = ""
            vc.url = url.absoluteString
            let nvc = UINavigationController(rootViewController: vc)
            if #available(iOS 13.0, *) {
                nvc.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            self.present(nvc, animated: true, completion: nil)
            // Allow the navigation to proceed
            decisionHandler(.cancel)
        } else {
            // It's a different type of link (e.g., file, tel, mailto)
            // You can choose to handle it or ignore it
            decisionHandler(.cancel)
        }
    }

}
