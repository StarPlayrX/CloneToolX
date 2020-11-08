//
//  ViewController.swift
//  CloneToolX
//
//  Created by Todd on 6/12/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import AppKit

class ViewController: NSViewController {
    
    @objc func GotDiskToImage(_ notification:Notification){
        diskImagePath.stringValue = disk2imageFolder + diskImageName
        diskImageString = disk2imageFolder + diskImageName
        
        let targetVolume = ["list", "/Volumes/" + sourceMenu.title]
        
        statusTextView.string = runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: targetVolume)
        
        let unMountTarget = ["unmountDisk", "/Volumes/" + sourceMenu.title]
        
        statusTextView.string = runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: unMountTarget)
        
        let unmountString = statusTextView.string.replacingOccurrences(of: "\n", with: "")
        let unMountArray = unmountString.components(separatedBy: " ") //as [String]
        
        if unMountArray.last == "successful" {
            disk = "/dev/" + unMountArray[5]
            print(disk)
            print(diskImageString)
            
            //using Zlib compression. May offer options later\
            //-ov overwrites an existing disk image
            let imageDisk = ["create","-format","UDZO","-srcdevice", disk, diskImageString, "-ov"]
            runProcess(binary: "/usr/bin/hdiutil", arguments: imageDisk)
        } else {
            let unMountTarget = ["mountDisk", disk]
            statusTextView.string = runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: unMountTarget)
        }
    }
    
    /* Disk to Disk Action */
    @objc func GotDiskToDisk(_ notification:Notification){
        
        let sourceDiskInfo = diskInfo(volume: sourceDisk)
        let targetDiskInfo = diskInfo(volume: targetDisk)
        
        var unmountSourceDevice = ""
        var unmountTargetDevice = ""
        
        var unMountSource = ["", ""]
        var unMountTarget = ["", ""]
        var MountSource = ["", ""]
        var MountTarget = ["", ""]

        if ( sourceDiskInfo.TypeBundle == "apfs" ) {
            unmountSourceDevice = "/dev/" + sourceDiskInfo.PartofWhole
            unMountSource = ["unmountDisk", unmountSourceDevice]
            MountSource = ["mountDisk", unmountSourceDevice]

        } else {
            unmountSourceDevice = sourceDiskInfo.DeviceNode
            unMountSource = ["unmount", unmountSourceDevice]
            MountSource = ["mount", unmountSourceDevice]

        }
        
        if ( targetDiskInfo.TypeBundle == "apfs" ) {
            unmountTargetDevice = "/dev/" + targetDiskInfo.PartofWhole
            unMountTarget = ["unmountDisk", unmountTargetDevice]
            MountTarget = ["mountDisk", unmountTargetDevice]

        } else {
            unmountTargetDevice = targetDiskInfo.DeviceNode
            unMountTarget = ["unmount", unmountTargetDevice]
            MountTarget = ["mount", unmountTargetDevice]

        }
        
        //statusTextView.string = statusTextView.string + runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: unMountSource)
        //let unmountSourceString = statusTextView.string.replacingOccurrences(of: "\n", with: "")
        //let unMountSourceArray = unmountSourceString.components(separatedBy: " ")
        
        statusTextView.string = statusTextView.string  + runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: unMountTarget)
        let unmountTargetString = statusTextView.string.replacingOccurrences(of: "\n", with: "")
        let unMountTargetArray = unmountTargetString.components(separatedBy: " ")
        if (unMountTargetArray.last == "successful" || unMountTargetArray.last == "unmounted") {
            statusTextView.string = statusTextView.string + runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: MountTarget)
            let imageDisk = ["-s", sourceDiskInfo.MountPoint, "-t", targetDiskInfo.MountPoint, "-er", "-nov", "-nop"]
            runProcessDiskToDisk(binary: "/usr/sbin/asr", arguments: imageDisk, mountSourceDisk: MountSource, mountTargetDisk: MountTarget)
        } else {
            //statusTextView.string = statusTextView.string + runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: MountSource)
            statusTextView.string = statusTextView.string + runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: MountTarget)
        }

    }

    let image2disk = "Image to Disk"
    let disk2image = "Disk to Image"
    let disk2disk  = "Disk to Disk"
    let schemas = ["Select a Scheme", "Image to Disk", "Disk to Image", "Disk to Disk"]

    var disk = ""
    var source_disk = ""
    var target_disk = ""
    
    var volumes = Array<String>()
    var diskImageString = "";
    
    override func viewWillAppear() {
        //print("HEY U!")
    }
    
    
 
    override func viewDidLoad() {
    
        
        
        
        //view.wantsLayer = true
        //self.view.layer?.backgroundColor = .black

        
        
    
        //self.view.window?.minSize = NSSize(width: 1200, height: 1200)
        //self.view.window?.maxSize = NSSize(width: 1200, height: 1200)
        
        
        getDiskToImage = NotificationCenter.default.addObserver(self, selector: #selector(GotDiskToImage), name: .gotDiskToImage, object: nil)
        
        getDiskToDisk = NotificationCenter.default.addObserver(self, selector: #selector(GotDiskToDisk), name: .gotDiskToDisk, object: nil)
        
        schemaMenu.removeAllItems()
        sourceMenu.removeAllItems()
        targetMenu.removeAllItems()
        //statusTextView.font = NSFont(name: "Andale Mono", size: 11.0)
        
        //cloneToolX_itemMenu.button?.title = "X"
        //cloneToolX_itemMenu.menu = cloneToolX_menu
        
        self.view.window?.title = "CloneToolX"
        
        for s in schemas {
            schemaMenu.addItem(withTitle: s as String)
        }
    }

    // disk image path text field
    @IBOutlet weak var diskImagePath: NSTextField!
    @IBOutlet weak var schemaMenu: NSPopUpButton!
    @IBOutlet weak var sourceMenu: NSPopUpButton!
    @IBOutlet weak var targetMenu: NSPopUpButton!
    @IBOutlet var statusTextView: NSTextView!
    
    @IBAction func cloneAdisk(_ sender: Any) {
        
        let scheme = schemaMenu.title
        
        if scheme == image2disk {
            setupDiskImageModal()
            diskImageModal.message = "Choose a bootable disk image.dmg"
            
            if (diskImageModal.runModal() == NSApplication.ModalResponse.OK) {
                if let result = diskImageModal.url {
                    
                    targetDisk = targetMenu.title

                    diskImageString = result.path
                    diskImagePath.stringValue = diskImageString
                    
                    if diskImageString != "" {
                        
                        let targetDiskInfo = diskInfo(volume: targetDisk)

                        var unmountTargetDevice = ""
                        
                        var unMountTarget = ["", ""]
                        var MountTarget = ["", ""]
                        
                        if ( targetDiskInfo.TypeBundle == "apfs" ) {
                            unmountTargetDevice = "/dev/" + targetDiskInfo.PartofWhole
                            unMountTarget = ["unmountDisk", unmountTargetDevice]
                            MountTarget = ["mountDisk", unmountTargetDevice]
                            
                        } else {
                            unmountTargetDevice = targetDiskInfo.DeviceNode
                            unMountTarget = ["unmount", unmountTargetDevice]
                            MountTarget = ["mount", unmountTargetDevice]
                            
                        }
                        
                        statusTextView.string = runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: unMountTarget)
                        
                        let unmountString = statusTextView.string.replacingOccurrences(of: "\n", with: "")
                        let unMountArray = unmountString.components(separatedBy: " ") as [String]
                        if unMountArray.last == "successful" {
                            

                            let imageDisk = ["-s", diskImageString, "-t", targetDiskInfo.MountPoint, "-er", "-nov", "-nop"]
                            
                            runProcess(binary: "/usr/sbin/asr", arguments: imageDisk)
                        } else {
                            statusTextView.string = statusTextView.string + runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: MountTarget)
                        }
                    }
                }
            }
        } else if scheme == disk2image {
            setupFolderModal()
            diskFolderModal.message = "Choose a folder that will store your disk image."
            if (diskFolderModal.runModal() == NSApplication.ModalResponse.OK) {
                if let result = diskFolderModal.url {
                    diskImageName = sourceMenu.titleOfSelectedItem!
                    disk2imageFolder = result.path
                    performSegue(withIdentifier: "disk2image", sender: self)
                }
            }
        } else if scheme == disk2disk {
            sourceDisk = sourceMenu.title
            targetDisk = targetMenu.title
            performSegue(withIdentifier: "disk2disk", sender: self)
        }
    }
    
    @IBAction func schemaAction(_ sender: NSMenuItem) {
        let selection = sender.title as String
        
        sourceMenu.removeAllItems()
        targetMenu.removeAllItems()

        volumes = runCommandReturnArray(binary:"/bin/ls", arguments: ["/Volumes"])

        if (selection == image2disk) {
            
            sourceMenu.addItem(withTitle: "Disk Image")
            
            for t in volumes {
                targetMenu.addItem(withTitle: t as String)
            }
            
        } else if (selection == disk2image) {
            
            for s in volumes {
                sourceMenu.addItem(withTitle: s as String)
            }
            
            targetMenu.addItem(withTitle: "Disk Image")
            
        } else if (selection == disk2disk) {
            
            for v in volumes {
                sourceMenu.addItem(withTitle: v as String)
                targetMenu.addItem(withTitle: v as String)
            }
        }
    }
    
    
    
    
    func runProcessDiskToDisk(binary: String, arguments: [String], mountSourceDisk: [String], mountTargetDisk:[String] ) {
        self.statusTextView.string = ""
        
        DispatchQueue.global(qos: .background).async {
            let process = Process()
            process.launchPath = binary
            process.arguments = arguments
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            let handler =  { (file: FileHandle!) -> Void in
                let data = file.availableData
                guard let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    else { return}
                
                DispatchQueue.main.async {
                    self.statusTextView.string = self.statusTextView.string + (output as String)
                }
            }
            
            pipe.fileHandleForReading.readabilityHandler = handler
            
            //Finish the Job
            process.terminationHandler = { (task: Process?) -> () in
                pipe.fileHandleForReading.readabilityHandler = nil
                
                let sourceDisk = runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: mountSourceDisk)
                let targetDisk = runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: mountTargetDisk)

                DispatchQueue.main.async {
                    self.statusTextView.string = self.statusTextView.string + sourceDisk
                    self.statusTextView.string = self.statusTextView.string + targetDisk

                    self.statusTextView.string = self.statusTextView.string  + "\n Job Finished."
                }
            }
            
            process.launch()
            process.waitUntilExit()
        }
    }
    
    
    
    
    
    func runProcess(binary: String, arguments: [String]) {
        self.statusTextView.string = ""
        
        DispatchQueue.global(qos: .background).async {
            let process = Process()
            process.launchPath = binary
            process.arguments = arguments
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            let handler =  { (file: FileHandle!) -> Void in
                let data = file.availableData
                guard let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    else { return}
                
                DispatchQueue.main.async {
                    self.statusTextView.string = self.statusTextView.string + (output as String)
                }
            }
            
            pipe.fileHandleForReading.readabilityHandler = handler
            
            //Finish the Job
            process.terminationHandler = { (task: Process?) -> () in
                pipe.fileHandleForReading.readabilityHandler = nil
                
                let unMountTarget = ["mountDisk", self.disk]
                
                let mountDisk = runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: unMountTarget)
                DispatchQueue.main.async {
                    self.statusTextView.string = self.statusTextView.string + mountDisk
                    self.statusTextView.string = self.statusTextView.string  + "\n Job Finished."
                }
            }
            
            process.launch()
            process.waitUntilExit()
        }
    }
}

