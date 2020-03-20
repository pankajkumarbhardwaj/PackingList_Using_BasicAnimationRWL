//
//  ViewController.swift
//  PackingList
//
//  Created by Pankaj Kumar on 19/03/20.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  //MARK:- IB outlets
  @IBOutlet var tableView: UITableView!
  @IBOutlet var menuButton: UIButton!
  @IBOutlet var titleLabel: UILabel!
    
 @IBOutlet var menuViewHeightConstant:NSLayoutConstraint!
  
    @IBOutlet weak var menuButtonTrallingConstant: NSLayoutConstraint!
    
    //MARK:- further class variables
    var slider: HorizontalItemList!
    var menuIsOpen = false
    var items: [Int] = [5, 6, 7]
  
    override func viewDidLoad() {
      super.viewDidLoad()
      makeSlider()
      self.tableView?.rowHeight = 54.0
    }
  
    @IBAction func toggleMenu(_ sender: AnyObject) {
        menuIsOpen = !menuIsOpen
        
        titleLabel.text = menuIsOpen ? "Select Item" : "Packing List"
        self.view.layoutIfNeeded()
        
        titleLabel.superview?.constraints.forEach({ (constraint) in
            
            if constraint.firstItem === titleLabel &&
                constraint . firstAttribute == .centerX {
                constraint.constant = menuIsOpen ? -100.0 : 0.0
                return
            }
            
            if constraint.identifier == "titleCenterY" {
                //Remove orizonal constraints
                constraint.isActive = false
                //Create new Constraints
                let newConstraints = NSLayoutConstraint(item: titleLabel,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: titleLabel.superview!,
                                                        attribute: .centerY,
                                                        multiplier: menuIsOpen ? 0.67 : 1.0,
                                                        constant: 0.0)
                newConstraints.identifier = "titleCenterY"
                newConstraints.priority = .defaultHigh
                newConstraints.isActive = true
            }
            
        })
        
        
//        titleLabel.constraints.forEach({ (constraints) in
//            print("titleLabel.constraints ->",constraints.description)
//        })
        
        menuViewHeightConstant.constant = menuIsOpen ? 200:80
        menuButtonTrallingConstant.constant = menuIsOpen ? 16:8
        
        UIView.animate(withDuration: 0.30, delay: 0.0, options: .curveEaseOut, animations: {
            let angle:CGFloat = self.menuIsOpen ? .pi / 4 : 0.0
            self.menuButton.transform = CGAffineTransform(rotationAngle: angle)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func makeSlider() {
      slider = HorizontalItemList(inView: view)
      slider.didSelectItem = {index in
        self.items.append(index)
        self.tableView.reloadData()
        self.transitionCloseMenu()
      }
      self.titleLabel.superview?.addSubview(slider)
    }
  
    func showItem(_ index: Int) {
        let imageView = makeImageView(index: index)
        let containerView = UIView(frame: imageView.frame)
        view.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
                
        let conX = containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let conBottom = containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: containerView.frame.height)
        let conWidth = containerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.33, constant: -50)
        let conHeight = containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor)
        
        let imageY = imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        let imageX = imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        let imageWidth = imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor)
        let imageHeight = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        
        NSLayoutConstraint.activate([conX,conBottom,conWidth,conHeight, imageY, imageX, imageWidth, imageHeight])
        self.view.layoutIfNeeded()
        
        //Spring Animation
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: [], animations: {
            conBottom.constant = -imageView.frame.height * 2
            conWidth.constant = 0.0
            self.view.layoutIfNeeded()
        }) { _ in
            
        }
//        //Simple Animation
//        UIView.animate(withDuration: 0.67, delay: 2.0, animations: {
//            conBottom.constant = imageView.frame.height
//            conWidth.constant = -50
//            self.view.layoutIfNeeded()
//        }) { (completion) in
//            imageView.removeFromSuperview()
//        }
        
        //Transition Animation
        delay(seconds: 1) {
            UIView.transition(with: containerView,
                              duration: 1.0,
                              options: .transitionFlipFromBottom,
                              animations: {
                                imageView.removeFromSuperview()
            }) { _ in
                containerView.removeFromSuperview()
            }
        }
        
       
        
    }
    
    func makeImageView(index: Int) -> UIImageView {
      let imageView = UIImageView(image: UIImage(named: "summericons_100px_0\(index).png"))
      imageView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
      imageView.layer.cornerRadius = 5.0
      imageView.layer.masksToBounds = true
      imageView.translatesAutoresizingMaskIntoConstraints = false
      return imageView
    }

  func transitionCloseMenu() {
    delay(seconds: 0.35, completion: {
      self.toggleMenu(self)
    })
    
    let titlebar = slider.superview!
    UIView.transition(with: titlebar, duration: 0.5, options: .transitionFlipFromBottom, animations: {
        self.slider.isHidden = true
    }) {_ in
        self.slider.isHidden = false
    }
    
	}
}



let itemTitles = ["Icecream money", "Great weather", "Beach ball", "Swim suit for him", "Swim suit for her", "Beach games", "Ironing board", "Cocktail mood", "Sunglasses", "Flip flops"]

// MARK:- Table View Delegate And Datasource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
    cell.accessoryType = .none
    cell.textLabel?.text = itemTitles[items[indexPath.row]]
    cell.imageView?.image = UIImage(named: "summericons_100px_0\(items[indexPath.row]).png")
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    showItem(items[indexPath.row])
  }
  
}
