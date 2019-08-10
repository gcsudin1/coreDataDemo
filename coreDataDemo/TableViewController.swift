//
//  TableViewController.swift
//  coreDataDemo
//
//  Created by IMCS2 on 8/6/19.
//  Copyright © 2019 IMCS2. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    var titleArray = [String]()
    var urlArray = [String]()
    var savtitleArray: [NSManagedObject] = []
    let blogSegueIdentifier = "showBlogSegue"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == blogSegueIdentifier,
            let destination = segue.destination as? ViewController,
            let blogIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.blogUrlArray = urlArray[blogIndex]
            destination.headingArray = titleArray[blogIndex]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchBlogData()
        fetchFromCoreData()
    }
    func fetchFromCoreData(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Blogs")
        do {
            savtitleArray = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for NewBlogs in savtitleArray{
                titleArray = (NewBlogs.value(forKeyPath: "title") as? [String])!
                urlArray = (NewBlogs.value(forKeyPath: "url") as? [String])!
                print(titleArray)
                print(urlArray)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func save(title: [String], url: [String]) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Blogs",
                                       in: managedContext)!
        let NewBlogs  = NSManagedObject(entity: entity,
                                        insertInto: managedContext)
        NewBlogs.setValue(title, forKeyPath: "title")
        NewBlogs.setValue(url, forKeyPath: "url")
        do {
            try managedContext.save()
            savtitleArray.append(NewBlogs)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text =  titleArray[indexPath.row]
        return cell
    }
    
    func fetchBlogData(){
        let urlAddress = "https://www.googleapis.com/blogger/v3/blogs/2399953/posts?key=AIzaSyBDOic0RLLLgTRB9tgppEg6My5EADNtU1Y"
        let url = URL(string: urlAddress)
        let task = URLSession.shared.dataTask(with: url!){(data,response,error) in
            if error == nil{
                if let unwrappedData = data{
                    do{
                        let jsonResult = try JSONSerialization.jsonObject(with: unwrappedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                        DispatchQueue.main.async{
                            let item = jsonResult?["items"] as? NSArray
                            
                            for i in 0...9{
                                let blogItem =  item?[i] as? NSDictionary
                                let title = blogItem?["title"] as! String
                                self.titleArray.append(title)
                                print(self.titleArray)
                                let url = blogItem?["url"] as! String
                                self.urlArray.append(url)
                                //print(self.urlArray)
                            }
                            self.save(title: self.titleArray, url:self.urlArray )
                            self.tableView.reloadData()
                        }
                    }catch{
                        print("Error")
                        
                    }
                    
                }
            }
        }
        task.resume()
        
    }
}
