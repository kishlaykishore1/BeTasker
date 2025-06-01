//
//  TutorialVC.swift
//  EasyAC
//
//  Created by MAC3 on 26/04/23.
//

import UIKit
import AdvancedPageControl

class TutorialVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var pgControl: AdvancedPageControlView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var viewWhite: UIView!
    @IBOutlet weak var stackView: UIStackView!
    //MARK: Properties
    let arrImg = [#imageLiteral(resourceName: "tutorial1"), #imageLiteral(resourceName: "tutorial2"), #imageLiteral(resourceName: "tutorial3")]
    let arrTitle = ["Prenez le contrôle".localized, "Suivez les opérations".localized, "Mode critique".localized]
    let arrSubTitle = ["Avec BeTasker, vous gérez\nle planning de vos équipes.".localized, "Recevez les rapports réguliers\nde vos équipes.".localized, "Prévenez vos équipes\ndans les situations d’urgences.".localized]
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.collView.delegate = self
        self.collView.dataSource = self
        
        btnNext.layer.cornerRadius = btnNext.frame.height / 2
        btnLogin.layer.cornerRadius = btnLogin.frame.height / 2
        
        DispatchQueue.main.async { [self] in
            stackView.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        }
        
        self.pgControl.drawer = ExtendedDotDrawer(numberOfPages: 3, height: 10, width: 10, space: 5, raduis: 5, currentItem: 0, indicatorColor: #colorLiteral(red: 1, green: 0.8156862745, blue: 0.1176470588, alpha: 1), dotsColor: #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1), isBordered: false, borderColor: .clear, borderWidth: 0, indicatorBorderColor: .clear, indicatorBorderWidth: 0)
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = viewWhite.frame
        self.viewWhite.insertSubview(blurEffectView, at: 0)
    }
    
}

//MARK: Button Actions
extension TutorialVC {
    @IBAction func btnLoginTapAction(_ sender: UIButton) {
        Global.setVibration()
        self.jumpToVC()
    }
    
    @IBAction func btnSuivantTapAction(_ sender: UIButton) {
        Global.setVibration()
        let visibleItems: NSArray = self.collView.indexPathsForVisibleItems as NSArray
        let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        let nextItem: IndexPath = IndexPath(item: currentItem.item + 1, section: 0)
        if nextItem.row < arrTitle.count {
            self.collView.scrollToItem(at: nextItem, at: .left, animated: true)
            pgControl.setPage(nextItem.row)
            
            self.imgBack.alpha = 0.4
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                self.imgBack.alpha = 1.0
                self.imgBack.image = self.arrImg[nextItem.row]
            }, completion: { finished in
                
            })
        } else {
            self.jumpToVC()
        }
    }
    
    func jumpToVC(){
        let vc = Constants.Main.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: UICollectionViewDelegate
extension TutorialVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
}

//MARK: UICollectionViewDataSource
extension TutorialVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TutorialCollViewCell", for: indexPath) as! TutorialCollViewCell
        cell.lblTitle.text = arrTitle[indexPath.item]
        cell.lblSubTitle.text = arrSubTitle[indexPath.item]
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pg = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        pgControl.setPage(pg)
        if pg == 2 {
            btnNext.setTitle("Démarrer".localized, for: .normal)
        } else {
            btnNext.setTitle("Suivant".localized, for: .normal)
        }
        
        self.imgBack.alpha = 0.4
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            self.imgBack.alpha = 1.0
            self.imgBack.image = self.arrImg[pg]
        }, completion: { finished in
            
        })
      
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension TutorialVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}

//MARK: UICollectionViewCell
class TutorialCollViewCell: UICollectionViewCell{
    //MARK: Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
}

