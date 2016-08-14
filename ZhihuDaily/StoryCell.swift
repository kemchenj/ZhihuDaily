//
//  StoryCell.swift
//  Zhihu Daily
//
//  Created by kemchenj on 7/23/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

@IBDesignable
class StoryCell: UITableViewCell {
    
    @IBOutlet weak var thumbNail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var story: Story! {
        didSet {
            self.titleLabel.text = story.title
            getThumbnail(of: story)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .gray
    }

    func configure(for story: Story) {
        self.story = story
    }

    func getThumbnail(of story: Story) {
        let request = URLRequest(
            url: URL(string: story.thumbNailURL.replacingOccurrences(of: "http",
                                                                     with: "https"))!,
            cachePolicy: .returnCacheDataElseLoad)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data,
                let tempImage = UIImage(data: data) else {
                    print("data Error")
                    return
            }
            
            DispatchQueue.main.async {
                self.thumbNail.image = tempImage
            }
        }.resume()
    }
}
