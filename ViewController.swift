//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke
class TumblrCell: UITableViewCell {
    
    @IBOutlet weak var TumbrCellTitle: UILabel!
    
    @IBOutlet weak var TumbrCellPic: UIImageView!

}


class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var refreshButton: UIButton!
    var postType: Int?
    @objc func handleRefresh() {
            fetchPosts()
        }
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
            handleRefresh()
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TumblrCell", for: indexPath) as! TumblrCell
                
                // Get the post associated with this row
                let post = posts[indexPath.row]
                
                // Set the text for titleText and descriptionText
 
        cell.TumbrCellTitle.text = post.summary
        
        
        print(post.summary)
        
        if let firstPhoto = post.photos.first {

                        let imageUrl = firstPhoto.originalSize.url



                        // Use the Nuke library's load image function to (async) fetch and load the image from the image URL.

                        Nuke.loadImage(with: imageUrl, into: cell.TumbrCellPic)

                    }
            return cell
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1000.0
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            
        tableView.dataSource = self
        
        fetchPosts()
    }


    
    func fetchPosts() {
        let peopleurl = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk&limit=30")!
        let owlurl = URL(string:"https://api.tumblr.com/v2/blog/hungoverowls/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk&limit=30")!

        var url: URL?
        
        if postType! == 1{
            url = peopleurl
            
        }
        if postType! == 2{
            url = owlurl
        }
                
                
        
        print(url!)
        let session = URLSession.shared.dataTask(with: url!) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in


                    let posts = blog.response.posts
                    
                    
                    self?.posts = posts
                    self?.tableView.reloadData()
                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTumblr" {
            if let destinationVC = segue.destination as? ViewController {
                destinationVC.postType = postType!
                
                
                /*
                 // MARK: - Navigation
                 
                 // In a storyboard-based application, you will often want to do a little preparation before navigation
                 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                 // Get the new view controller using segue.destination.
                 // Pass the selected object to the new view controller.
                 }
                 */
                
            }
        }
        if segue.identifier == "ShowDetail" {
            
            if let destinationVC = segue.destination as? DetailVC {
                
                guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
                let selectedPost = posts[selectedIndexPath.row]
                if let firstPhoto = posts[selectedIndexPath.row].photos.first {
                    
                    let imageUrl = firstPhoto.originalSize.url
                    destinationVC.myPic = imageUrl
                }
                    
                    destinationVC.myCaption = selectedPost.caption
                    
                
            }
        }
    }
}
