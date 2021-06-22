//
//  DiskToDiskController.swift
//  CloneToolX
//
//  Created by todd on 6/30/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import AppKit

class DiskToDisk: NSViewController {
    
    @IBOutlet weak var multiLabel: NSTextField!
    
    @IBAction func ok(_ sender: Any) {
        dismiss(self)
        NotificationCenter.default.post(name: .gotDiskToDisk, object: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(self)
    }
    
    override func viewWillAppear() {
        if sourceDisk == targetDisk {
            let warningText = "The source and the target disk must be different."
            multiLabel.stringValue = warningText
        } else {
            let warningText = "Are you sure you want to erase " + targetDisk + " with " + sourceDisk +
                "? There is no undo."
            multiLabel.stringValue = warningText
        }
    }
}
