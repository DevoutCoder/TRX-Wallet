//
//  WalletTableViewCell.swift
//  Wallet
//
//  Created by Maynard on 2018/5/14.
//  Copyright © 2018年 New Horizon Labs. All rights reserved.
//

import UIKit
import SwipeCellKit
import RxSwift
import RxCocoa

protocol WalletWalletTableViewCellDelegate: class {
    func confirmDelete(wallet: Wallet)
    
    func showInfoButtonClick(wallet: Wallet, view: UIView)
}

class WalletTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var watchImageView: UIImageView!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    weak var cellDelegate: WalletWalletTableViewCellDelegate?
    
    var wallet: Wallet?
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        exportButton.addTarget(self, action: #selector(WalletTableViewCell.exportClick), for: .touchUpInside)
        
        exportButton.setTitle(R.string.tron.walletsExportButtonTitle(), for: .normal)
        // Initialization code
    }
    
    @objc func exportClick() {
        if let w = wallet {
            self.cellDelegate?.showInfoButtonClick(wallet: w, view: self.exportButton)
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            super.setSelected(false, animated: true)
        }
        // Configure the view for the selected state
    }
    
    func configure(model: Wallet) {
        addressLabel.text = model.address.data.addressString
        
        if let wallet = EtherKeystore.shared.recentlyUsedWallet, wallet.address.data.addressString == model.address.data.addressString {
            tipView.isHidden = false
        } else {
            tipView.isHidden = true
        }
        wallet = model
        let a = TronAccount()
        a.address = model.address.data
        ServiceHelper.shared.getAccount(account: a)
        .asObservable()
            .subscribe(onNext: {[weak self] (account) in
                self?.balanceLabel.text = account.balance.balanceString
            })
        .disposed(by: disposeBag)
        
        if model.type == .address(model.address) {
            watchImageView.isHidden = false
        } else {
            watchImageView.isHidden = true
        }
    }
    
    func delete() {
        guard let wallet = wallet else {
            return
        }
        self.cellDelegate?.confirmDelete(wallet: wallet)
    }
    
    
    
}

extension WalletTableViewCell: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
                guard orientation == .right else { return nil }
        
                let deleteAction = SwipeAction(style: .default, title: R.string.tron.walletsDeleteButtonTitle()) {[weak self] action, indexPath in
                    self?.delete()
                }
        
                // customize the action appearance
                deleteAction.image = UIImage(named: "delete")
                deleteAction.backgroundColor = UIColor.mainRedColor
                deleteAction.textColor = UIColor.white
        return [deleteAction]
    }
    
    
    
}
