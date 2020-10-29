//
//  StreamListViewController.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih
//

import UIKit
import YTLiveStreaming
import RxCocoa
import RxDataSources
import RxSwift

struct Stream {
    var time: String
    var name: String
}

class StreamListViewController: BaseViewController {

    var viewModel: MainViewModel!

    enum CellIdentifier: String {
        case cell
    }

    @IBOutlet weak var createBroadcastButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var addNewStreamButton: UIButton!

    fileprivate var refreshControl: UIRefreshControl!

    var dataSource: Any?

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureLeftBarButtonItem()
        configureRightBarButtonItem()
    }
    
    private func configureView() {
        configureAddStreamButton()
        setUpRefreshControl()
        bindUserActivity()
        bindData()
        viewModel.loadData()
    }
    
    func startActivity() {
        DispatchQueue.performUIUpdate { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }

    func stopActivity() {
        DispatchQueue.performUIUpdate { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }

    private func close() {
        viewModel.closeView()
    }
    
    private func didSignOut() {
        self.stopActivity()
        self.close()
    }
    
    @objc private func signOut() {
        self.viewModel.signOut()
    }
    
    private func bindUserActivity() {
        addNewStreamButton
            .rx
            .tap
            .debounce(.milliseconds(Constants.UiConstraints.debounce), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.creadeBroadcast()
            }).disposed(by: disposeBag)
        viewModel
            .rxSignOut
            .subscribe(onNext: { [weak self] _ in
                self?.didSignOut()
            }).disposed(by: disposeBag)
    }
    
    private func bindData() {
        tableView.register(StreamListTableViewCell.self, forCellReuseIdentifier: CellIdentifier.cell.rawValue)
        tableView.delegate = self
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(
            configureCell: { (_, tableView, indexPath, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.cell.rawValue) as! StreamListTableViewCell
                cell.beginLabel.text = "start: \(element.snipped.publishedAt)"
                cell.nameLabel.text = element.snipped.title
                return cell
        },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
        }
        )
        viewModel
            .rxData
            .bind(to: tableView
                .rx
                .items(dataSource: dataSource as! RxTableViewSectionedReloadDataSource<SectionModel>))
            .disposed(by: disposeBag)
        viewModel
            .rxData
            .subscribe(onNext: { _ in
                DispatchQueue.performUIUpdate { [weak self] in
                    self?.refreshControl.endRefreshing()
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Configure View Items

extension StreamListViewController {
    
    private func configureLeftBarButtonItem() {
        let backButton = UIBarButtonItem.init(title: "Log Out",
                                              style: .plain,
                                              target: self,
                                              action: #selector(signOut))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    private func configureRightBarButtonItem() {
        let userNameLabel = UILabel(frame: CGRect.zero)
        userNameLabel.text = UserStorage.user?.fullName
        userNameLabel.textColor = .white
        let rightBarButton = UIBarButtonItem(customView: userNameLabel)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }

    private func configureAddStreamButton() {
        self.addNewStreamButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55.0, height: 55.0))
        addNewStreamButton.setImage(#imageLiteral(resourceName: "addStreamButton"), for: .normal)
        self.view.addSubview(addNewStreamButton)
        addNewStreamButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addNewStreamButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.0),
            addNewStreamButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.0)
        ])
    }
}

// MARK: Refresh Controller

extension StreamListViewController {

    fileprivate func setUpRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.red
        self.refreshControl.addTarget(self,
                                      action: #selector(StreamListViewController.refreshData(_:)),
                                      for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
    }

    @objc func refreshData(_ sender: AnyObject) {
        viewModel.loadData()
    }
}

// MARK: UiTableView delegates

extension StreamListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.launchStream(indexPath: indexPath, viewController: self)
    }
}
