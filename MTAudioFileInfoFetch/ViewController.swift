//
// ViewController.swift
//
// 日期：2018/9/27.
// 作者：Nolan   

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let filePath = Bundle.main.path(forResource: "heyhey_music_2390491_1528196707_662", ofType: "mp3")
        let info = MTMp3FileInfo(filePath: filePath!)
        debugPrint(info)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

