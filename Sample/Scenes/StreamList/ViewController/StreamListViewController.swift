//
//  StreamListViewController.swift
//  YouTubeLiveVideo
//

import UIKit
import YTLiveStreaming
import RxCocoa
import RxSwift

struct Stream {
    var time: String
    var name: String
}

class StreamListViewController: BaseViewController {

    var viewModel: StreamListViewModel!

    internal struct CellName {
        static let StreamItemCell = "TableViewCell"
    }

    @IBOutlet weak var createBroadcastButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var addNewStreamButton: UIButton!

    fileprivate var refreshControl: UIRefreshControl!

    fileprivate var upcomingStreams = [Stream]()
    fileprivate var currentStreams = [Stream]()
    fileprivate var pastStreams = [Stream]()

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
        configureTableView()
        loadData()
    }
    
    func present(content: (upcoming: [Stream], current: [Stream], past: [Stream])) {
        DispatchQueue.main.async {
            self.upcomingStreams = content.upcoming
            self.currentStreams = content.current
            self.pastStreams = content.past
            self.tableView.reloadData()
        }
    }
    
    func startActivity() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }

    func stopActivity() {
        DispatchQueue.main.async { [weak self] in
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
                guard let `self` = self else { return }
                self.viewModel.creadeBroadcast()
            }).disposed(by: disposeBag)
        viewModel
            .rxSignOut
            .subscribe(onNext: { [weak self] _ in
                self?.didSignOut()
            }).disposed(by: disposeBag)
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        present(content: ([], [], []))
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
        viewModel.reloadData { result in
            switch result {
            case .success(let (upcoming, current, past)):
                DispatchQueue.main.async { [weak self] in
                    self?.refreshControl.endRefreshing()
                    self?.present(content: (upcoming, current, past))
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.refreshControl.endRefreshing()
                }
                print(error.message())
            }
        }
    }
}

// MARK: UiTableView delegates

extension StreamListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Upcoming"
        case 1:
            return "Live now"
        case 2:
            return "Completed"
        default:
            assert(false, "Incorrect section number")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return upcomingStreams.count
        case 1:
            return currentStreams.count
        case 2:
            return pastStreams.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellName.StreamItemCell) as? StreamListTableViewCell
        let stream = getStreamData(indexPath: indexPath)
        cell?.beginLabel.text = stream.time
        cell?.nameLabel.text = stream.name

        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.launchStream(indexPath: indexPath, viewController: self)
    }
}

// MARK: - Private Methods

extension StreamListViewController {
    
    private func loadData() {
        viewModel.loadData { result in
            switch result {
            case .success(let (upcoming, current, past)):
                DispatchQueue.main.async { [weak self] in
                    self?.present(content: (upcoming, current, past))
                }
            case .failure(let error):
                print(error.message())
            }
        }
    }

    private func getStreamData(indexPath: IndexPath) -> Stream {
        var stream: Stream!
        switch indexPath.section {
        case 0:
            stream =  self.upcomingStreams[indexPath.row]
        case 1:
            stream =  self.currentStreams[indexPath.row]
        case 2:
            stream =  self.pastStreams[indexPath.row]
        default:
            assert(false, "Incorrect section number")
        }
        return stream
    }
}
