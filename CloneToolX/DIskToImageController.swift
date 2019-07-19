//
//  DIskToImageController.swift
//  CloneToolX
//
//  Created by todd on 6/28/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//
import AppKit

class DiskToImage: NSViewController {
    
    @IBOutlet weak var diskToImageParentFolder: NSTextField!
    @IBOutlet weak var diskimageName: NSTextField!
    
    @IBAction func chooseFolder(_ sender: Any) {
        
        diskFolderModal.message = "Choose a parent folder for your disk image."
        if (diskFolderModal.runModal() == NSApplication.ModalResponse.OK) {
            if let result = diskFolderModal.url {
                disk2imageFolder = result.path + folderSlash
                diskToImageParentFolder.stringValue = disk2imageFolder
            }
        }
    }
    
    @IBAction func ok(_ sender: Any) {
        if diskimageName.stringValue != "" && diskToImageParentFolder.stringValue != "" {
            
            disk2imageFolder = diskToImageParentFolder.stringValue
            diskImageName = diskimageName.stringValue
            NotificationCenter.default.post(name: .gotDiskToImage, object: nil)
            dismiss(self)
        }
    }
    
    //Cancel button called
    @IBAction func cancel(_ sender: Any) {
        dismiss(self)
    }
    
    override func viewDidAppear() {
        
        let fieldEditor = diskimageName.currentEditor()
        
        let full = diskImageName + dmgSuffix
        let sub = (full).range(of: diskImageName)!
        let range = NSRange(sub, in: full)
        
        fieldEditor?.selectedRange = range
    }
    override func viewWillAppear() {
        diskimageName.stringValue = diskImageName + dmgSuffix
        disk2imageFolder = disk2imageFolder + folderSlash
        diskToImageParentFolder.stringValue = disk2imageFolder
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Hello")
        
    }
}
