//
//  StreamListViewController.swift
//  YouTubeLiveVideo
//

import UIKit
import YTLiveStreaming
import RxSwift

struct Stream {
    var time: String
    var name: String
}

class StreamListViewController: UIViewController {
    
    unowned var signInInteractor: GoogleSignInInteractor!
    
    var signInViewModel: GoogleSessionViewModel!
    var streamListViewModel: StreamListViewModel!
    
    internal struct CellName {
        static let StreamItemCell = "TableViewCell"
    }
    
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var createBroadcastButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    fileprivate var refreshControl: UIRefreshControl!
    
    fileprivate var upcomingStreams = [Stream]()
    fileprivate var currentStreams = [Stream]()
    fileprivate var pastStreams = [Stream]()

    let dependencies = StreamListDependencies()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dependencies.configure(self)
        
        configureView()
        signInViewModel.didLoad()
    }
    
    private func configureView() {
        setUpRefreshControl()
    }

    func present(content: (upcoming: [Stream], current: [Stream], past: [Stream])) {
        DispatchQueue.main.async() {
            self.upcomingStreams = content.upcoming
            self.currentStreams = content.current
            self.pastStreams = content.past
            self.tableView.reloadData()
        }
    }
    
    func startActivity() {
        DispatchQueue.main.async() { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
    
    func stopActivity() {
        DispatchQueue.main.async() { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: Refresh Controller

extension StreamListViewController {
    
    fileprivate func setUpRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.red
        self.refreshControl.addTarget(self, action: #selector(StreamListViewController.refreshData(_:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func refreshData(_ sender: AnyObject) {
        self.refreshControl.endRefreshing()
        streamListViewModel.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CellName.StreamItemCell) as! StreamListTableViewCell
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
        cell.beginLabel.text = stream.time
        cell.nameLabel.text = stream.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        streamListViewModel.launchStream(section: indexPath.section, index: indexPath.row)
    }
}
