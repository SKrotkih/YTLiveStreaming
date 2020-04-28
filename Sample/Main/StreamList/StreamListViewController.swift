//
//  StreamListViewController.swift
//  YouTubeLiveVideo
//

import UIKit
import YTLiveStreaming
import RxSwift

// NEW: 1052952934375-9c5i3ar8b197eg7rnqdd39mf7l585ihi.apps.googleusercontent.com
// OLD: 495403403209-heee4af4qefp6ujvi216ar5rockjnr6l.apps.googleusercontent.com

struct Stream {
    var time: String
    var name: String
}

class StreamListViewController: UIViewController {
    
    var input: YTLiveStreaming!
    var presenter: Presenter!
    var eventHandler: Presenter!
    
    private var signInView: GoogleSignInViewInterface!
    
    internal struct CellName {
        static let StreamItemCell = "TableViewCell"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signInBackgroundView: UIView!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var upcomingStreams = [Stream]()
    fileprivate var currentStreams = [Stream]()
    fileprivate var pastStreams = [Stream]()
    
    let rxSignInNeeded: PublishSubject<Bool> = PublishSubject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dependencies = Dependencies()
        dependencies.configure(self)
        
        configureView()
        
        signInView.didLoad()
    }
    
    @IBAction func createBroadcastButtonTapped(_ sender: AnyObject) {
        creadeBroadcast()
    }
    
    private func configureView() {
        addSignInView()
        setUpRefreshControl()
    }
    
    private func addSignInView() {
        // TODO: Here should be Factory
        signInView = GoogleSignInView(viewController: self)
    }
    
    func presentUserInfo(connected: Bool, userInfo: String ) {
        DispatchQueue.main.async {
            if connected {
                self.signInButton.isHidden = true
                self.userInfoLabel.isHidden = false
                self.userInfoLabel.text = userInfo
                self.signOutButton.isHidden = false
            } else {
                self.signInButton.isHidden = false
                self.userInfoLabel.isHidden = true
                self.signOutButton.isHidden = true
            }
        }
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
        signInView.reloadData()
    }
}

// MARK: - Private methods

extension StreamListViewController {
    
    fileprivate func creadeBroadcast() {
        Alert.sharedInstance.showConfirmCancel("YouTube Live Streaming API", message: "You realy want to create a new Live broadcast video?", onConfirm: {
            self.eventHandler.createBroadcast() { error in
                if let error = error {
                    Alert.sharedInstance.showOk("Error", message: error.localizedDescription)
                } else {
                    Alert.sharedInstance.showOk("Done", message: "Please, refresh the table after pair seconds (pull down)")
                }
            }
        })
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CellName.StreamItemCell) as! TableViewCell
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
        eventHandler.launchLiveStream(section: indexPath.section, index: indexPath.row)
    }
}
