//
//  ViewController.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit
import YTLiveStreaming

class ViewController: UIViewController {

   @IBOutlet weak var tableView: UITableView!
   
   var refreshControl: UIRefreshControl!
   
   var input: YTLiveStreaming!
   var presenter: Presenter!
   
   var upcoming = [LiveBroadcastStreamModel]()
   var current = [LiveBroadcastStreamModel]()
   var past = [LiveBroadcastStreamModel]()
   
   fileprivate var completedThreadsCount: Int = 0
   
   override func viewDidLoad() {
      super.viewDidLoad()

      let configurator = Configurator()
      configurator.configure(self)

      setUpRefreshControl()
   }

   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      loadData()      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }

   @IBAction func createBroadcastButtonTapped(_ sender: AnyObject) {
      let title = "Live video"
      let description = "Test broadcast video"
      let startDate = Helpers.dateAfter(Date(), after: (hour: 0, minute: 2, second: 0))
      
      Alert.sharedInstance.showConfirmCancel("YouTube Live Streaming API", message: "You realy want to create a new Live broadcast video?", onConfirm: {
         self.input.createBroadcast(title, description: description, startTime: startDate, completion: { broadcast in
            if broadcast != nil {
               Alert.sharedInstance.showOk("Done", message: "Please, refresh the table after pair seconds (pull down)")
            } else {
               Alert.sharedInstance.showOk("Sorry", message: "Something went wrong")
            }
         })
      })
   }
   
}

extension ViewController {
   
   fileprivate func loadData() {
      completedThreadsCount = 0
      input.getUpcomingBroadcasts(){ streams in
         self.addStreams("upcoming", streams: streams)
      }
      input.getLiveNowBroadcasts(){ streams in
         self.addStreams("current", streams: streams)
      }
      input.getCompletedBroadcasts(){ streams in
         self.addStreams("past", streams: streams)
      }
   }
   
   fileprivate func addStreams(_ type: String, streams: [LiveBroadcastStreamModel]?) {
      completedThreadsCount += 1
      if let broadcasts = streams {
         if type == "upcoming" {
            self.upcoming = self.upcoming + broadcasts
         } else if type == "current" {
            self.current = self.current + broadcasts
         } else if type == "past" {
            self.past = self.past + broadcasts
         }
      }
      if completedThreadsCount == 3 {
         self.tableView.reloadData()
      }
   }
   
}

// MARK: Refresh Control

extension ViewController {
   
   fileprivate func setUpRefreshControl() {
      self.refreshControl = UIRefreshControl()
      self.refreshControl.tintColor = UIColor.red
      self.refreshControl.addTarget(self, action: #selector(ViewController.refreshData(_:)), for: UIControlEvents.valueChanged)
      self.tableView.addSubview(refreshControl)
   }
   
   func refreshData(_ sender: AnyObject) {
      self.refreshControl.endRefreshing()
      refreshData()
   }
   
   fileprivate func refreshData() {
      self.upcoming.removeAll()
      self.current.removeAll()
      self.past.removeAll()
      DispatchQueue.main.async(execute: {
         self.tableView.reloadData()
      })
      self.loadData()
   }
   
}

// MARK: UiTableView delegate

extension ViewController: UITableViewDelegate, UITableViewDataSource {
   
   
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
         assert(false, "Incorrect number of sections")
      }
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      switch section {
      case 0:
         return self.upcoming.count
      case 1:
         return self.current.count
      case 2:
         return self.past.count
      default:
         return 0
      }
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
      var broadcast: LiveBroadcastStreamModel!
      switch indexPath.section {
      case 0:
         broadcast =  self.upcoming[indexPath.row]
      case 1:
         broadcast =  self.current[indexPath.row]
      case 2:
         broadcast =  self.past[indexPath.row]
      default:
         assert(false, "Incorrect number of sections")
      }
      let begin = broadcast.snipped.publishedAt
      cell.beginLabel.text = "start: \(begin)"
      
      cell.nameLabel.text = broadcast.snipped.title

      return cell
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      var broadcast: LiveBroadcastStreamModel!
      switch indexPath.section {
      case 0:
         broadcast = self.upcoming[indexPath.row]
         self.presenter.startBroadcast(broadcast, completed: { success in
            if success == false {
               Alert.sharedInstance.showOk("Failed attempt", message: "Can't create broadcast")
            }
         })
      case 1:
         broadcast = self.current[indexPath.row]
         YouTubePlayer.playYoutubeID(broadcast.id, viewController: self)
      case 2:
         broadcast = self.past[indexPath.row]
         YouTubePlayer.playYoutubeID(broadcast.id, viewController: self)
      default:
         assert(false, "Incorrect number of sections")
      }
      
   }
   
}

