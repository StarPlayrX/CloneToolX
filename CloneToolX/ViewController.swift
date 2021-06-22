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
        
        print("sourceDiskInfo", sourceDiskInfo)
        
        print("targetDiskInfo", targetDiskInfo)
        
        print(["-s", sourceDisk, "-t", targetDisk, "-er", "-nov", "-nop"])
        let imageDisk = ["-s", sourceDiskInfo.MountPoint, "-t", targetDiskInfo.MountPoint, "-er", "-nov", "-nop"]
        runProcessDiskToDisk(binary: "/usr/sbin/asr", arguments: imageDisk, mountSourceDisk: [sourceDiskInfo.DeviceIdentifier], mountTargetDisk: [targetDiskInfo.DeviceIdentifier])
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
    
    override func viewDidLoad() {
        
        getDiskToImage = NotificationCenter.default.addObserver(self, selector: #selector(GotDiskToImage), name: .gotDiskToImage, object: nil)
        getDiskToDisk = NotificationCenter.default.addObserver(self, selector: #selector(GotDiskToDisk), name: .gotDiskToDisk, object: nil)
        
        schemaMenu.removeAllItems()
        sourceMenu.removeAllItems()
        targetMenu.removeAllItems()
        
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
    
    func getNameOfStartupDisk() -> String {
        let script = "get text 1 thru -2 of (path to startup disk as string)"
        if let startupDisk = performAppleScript(script: script) {
            return startupDisk.text
        } else {
            return ""
        }
    }
    
    @IBAction func schemaAction(_ sender: NSMenuItem) {
        let selection = sender.title as String
        let startupVolume = "/"
        let diskImageLabel = "Disk Image"
        let slashVolumes = "/Volumes"
        let ls = "/bin/ls"
        
        sourceMenu.removeAllItems()
        targetMenu.removeAllItems()
        
        volumes = runCommandReturnArray(binary: ls, arguments: [slashVolumes])
        
        if (selection == image2disk) {
            
            sourceMenu.addItem(withTitle: diskImageLabel)
            
            /// Get startup disk
            for targetName in volumes {
                if getNameOfStartupDisk() == targetName {
                    //targetMenu.addItem(withTitle: startupVolume)
                } else {
                    targetMenu.addItem(withTitle: targetName)
                }
            }
            
        } else if (selection == disk2image) {
            
            /// Get startup disk
            for sourceName in volumes {
                sourceMenu.addItem(withTitle: sourceName)
            }
            
            targetMenu.addItem(withTitle: diskImageLabel)
            
        } else if (selection == disk2disk) {
            
            for volume in volumes {
                if getNameOfStartupDisk() == volume {
                    sourceMenu.addItem(withTitle: startupVolume)
                } else {
                    sourceMenu.addItem(withTitle: volume)
                    targetMenu.addItem(withTitle: volume)
                }
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

