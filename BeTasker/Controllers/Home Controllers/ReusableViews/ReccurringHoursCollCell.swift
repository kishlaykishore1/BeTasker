//
//  ReccurringHoursCollCell.swift
//  BeTasker
//
//  Created by kishlay kishore on 31/03/25.
//

import UIKit

protocol ReccuringHoursDelegate: AnyObject {
    func sendSelectedHours(section: Int, arrHours: [String])
}

class ReccurringHoursCollCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variables
    var arrTimes: [String] = []
    var section: Int = 0
    weak var delegate: ReccuringHoursDelegate?
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(UINib(nibName: "SelectTimeCollCell", bundle: nil), forCellWithReuseIdentifier: "SelectTimeCollCell")
        self.collectionView.register(UINib(nibName: "AddMoreTimeCollCell", bundle: nil), forCellWithReuseIdentifier: "AddMoreTimeCollCell")
    }
    
    func configure(with times: [String]) {
        self.arrTimes = times
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
}

// MARK: - Collection View Delegate methods
extension ReccurringHoursCollCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTimes.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == arrTimes.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMoreTimeCollCell", for: indexPath) as! AddMoreTimeCollCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectTimeCollCell", for: indexPath) as! SelectTimeCollCell
            cell.btnDelete.isHidden = arrTimes.count <= 1
            cell.configure(with: arrTimes[indexPath.row])
            cell.updateTimeClosure = { [weak self] (time) in
                self?.arrTimes[indexPath.row] = time
                self?.delegate?.sendSelectedHours(section: self?.section ?? 0, arrHours: self?.arrTimes ?? [])
            }
            cell.removeActionClosure = { [weak self] in
                self?.arrTimes.remove(at: indexPath.row)
                self?.delegate?.sendSelectedHours(section: self?.section ?? 0, arrHours: self?.arrTimes ?? [])
                self?.collectionView.reloadData()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == arrTimes.count {
            self.arrTimes.append("")
            self.collectionView.reloadData()
        }
    }
}

// MARK: - Collection View DelegateFlowLayout Methods
extension ReccurringHoursCollCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == arrTimes.count {
            return CGSize(width: 185.0, height: 50.0)
        } else {
            return CGSize(width: 115.0, height: 80.0)
        }
    }
}

