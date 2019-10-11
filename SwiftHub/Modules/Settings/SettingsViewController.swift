//
//  SettingsViewController.swift
//  SwiftHub
//
//  Created by Sygnoos9 on 7/8/18.
//  Copyright © 2018 Khoren Markosyan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

//cellId
private let switchReuseIdentifier = R.reuseIdentifier.settingSwitchCell.identifier
private let reuseIdentifier = R.reuseIdentifier.settingCell.identifier
private let profileReuseIdentifier = R.reuseIdentifier.userCell.identifier

class SettingsViewController: TableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func makeUI() {
        super.makeUI()
        //切换语言设置标题
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.navigationTitle = R.string.localizable.settingsNavigationTitle.key.localized()
        }).disposed(by: rx.disposeBag)

        //注册cell
        tableView.register(R.nib.settingCell)
        tableView.register(R.nib.settingSwitchCell)
        tableView.register(R.nib.userCell)
        //刷新
        tableView.headRefreshControl = nil
        tableView.footRefreshControl = nil
    }

    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? SettingsViewModel else { return }

        //viewWillAppear
        let refresh = Observable.of(rx.viewWillAppear.mapToVoid(), languageChanged.asObservable()).merge()
        let input = SettingsViewModel.Input(trigger: refresh,
                                            selection: tableView.rx.modelSelected(SettingsSectionItem.self).asDriver())
        let output = viewModel.transform(input: input)

        //dataSource
        let dataSource = RxTableViewSectionedReloadDataSource<SettingsSection>(configureCell: { dataSource, tableView, indexPath, item in
            //item
            switch item {
            case .profileItem(let viewModel):
                let cell = (tableView.dequeueReusableCell(withIdentifier: profileReuseIdentifier, for: indexPath) as? UserCell)!
                cell.bind(to: viewModel)
                return cell
            case .bannerItem(let viewModel),
                 .nightModeItem(let viewModel):
                let cell = (tableView.dequeueReusableCell(withIdentifier: switchReuseIdentifier, for: indexPath) as? SettingSwitchCell)!
                cell.bind(to: viewModel)
                return cell
            case .themeItem(let viewModel),
                 .languageItem(let viewModel),
                 .contactsItem(let viewModel),
                 .removeCacheItem(let viewModel),
                 .acknowledgementsItem(let viewModel),
                 .whatsNewItem(let viewModel),
                 .logoutItem(let viewModel):
                let cell = (tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? SettingCell)!
                cell.bind(to: viewModel)
                return cell
            }
        }, titleForHeaderInSection: { dataSource, index in
            //Section:标题
            let section = dataSource[index]
            return section.title
        })

        //设置DataSource
        output.items.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        //点击cell
        output.selectedEvent.drive(onNext: { [weak self] (item) in
            switch item {
            case .profileItem:
                if let viewModel = viewModel.viewModel(for: item) as? UserViewModel {
                    self?.navigator.show(segue: .userDetails(viewModel: viewModel), sender: self, transition: .detail)
                }
            case .logoutItem:
                //注销
                self?.deselectSelectedRow()
                self?.logoutAction()
            case .bannerItem,
                 .nightModeItem:
                //广告和夜间模式
                self?.deselectSelectedRow()
            case .themeItem:
                //颜色主题
                if let viewModel = viewModel.viewModel(for: item) as? ThemeViewModel {
                    self?.navigator.show(segue: .theme(viewModel: viewModel), sender: self, transition: .detail)
                }
            case .languageItem:
                //语言
                if let viewModel = viewModel.viewModel(for: item) as? LanguageViewModel {
                    self?.navigator.show(segue: .language(viewModel: viewModel), sender: self, transition: .detail)
                }
            case .contactsItem:
                //邀请
                if let viewModel = viewModel.viewModel(for: item) as? ContactsViewModel {
                    self?.navigator.show(segue: .contacts(viewModel: viewModel), sender: self, transition: .detail)
                }
            case .removeCacheItem:
                //清理缓存
                self?.deselectSelectedRow()
            case .acknowledgementsItem:
                //致谢
                self?.navigator.show(segue: .acknowledgements, sender: self, transition: .detail)
                analytics.log(.acknowledgements)
            case .whatsNewItem:
                //新特性
                self?.navigator.show(segue: .whatsNew(block: viewModel.whatsNewBlock()), sender: self, transition: .modal)
                analytics.log(.whatsNew)
            }
        }).disposed(by: rx.disposeBag)
    }

    func logoutAction() {
        var name = ""
        //获取当前用户
        if let user = User.currentUser() {
            name = user.name ?? user.login ?? ""
        }

        let alertController = UIAlertController(title: name,
                                                message: R.string.localizable.settingsLogoutAlertMessage.key.localized(),
                                                preferredStyle: UIAlertController.Style.alert)
        //退出
        let logoutAction = UIAlertAction(title: R.string.localizable.settingsLogoutAlertConfirmButtonTitle.key.localized(),
                                         style: .destructive) { [weak self] (result: UIAlertAction) in
            self?.logout()
        }

        let cancelAction = UIAlertAction(title: R.string.localizable.commonCancel.key.localized(),
                                         style: .default) { (result: UIAlertAction) in
        }

        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        self.present(alertController, animated: true, completion: nil)
    }

    //注销
    func logout() {
        User.removeCurrentUser()
        AuthManager.removeToken()
        Application.shared.presentInitialScreen(in: Application.shared.window)

        analytics.log(.logout)
        analytics.reset()
    }
}
