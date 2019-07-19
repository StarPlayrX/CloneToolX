//
//  Global.swift
//  CloneToolX
//
//  Created by todd on 6/30/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import AppKit

var disk2imageFolder = ""
var diskImageName = ""
var sourceDisk = ""
var targetDisk = ""
let dmgSuffix = ".dmg"
let folderSlash = "/"
let diskFolderModal = NSOpenPanel()
let diskImageModal = NSOpenPanel()

var getDiskToImage : ()? = nil
var getDiskToDisk : ()? = nil

func setupDiskImageModal() {
    diskImageModal.showsResizeIndicator    = true
    diskImageModal.showsHiddenFiles        = false
    diskImageModal.canChooseDirectories    = false
    diskImageModal.canCreateDirectories    = false
    diskImageModal.allowsMultipleSelection = false
    diskImageModal.canChooseFiles          = true
    diskImageModal.allowedFileTypes        = ["dmg","img","raw"]
}

func setupFolderModal() {
    diskFolderModal.showsResizeIndicator    = true
    diskFolderModal.showsHiddenFiles        = false
    diskFolderModal.canChooseDirectories    = true
    diskFolderModal.canCreateDirectories    = true
    diskFolderModal.allowsMultipleSelection = false
    diskFolderModal.canChooseFiles          = false
    diskFolderModal.allowedFileTypes        = ["Folder"]
}

extension Notification.Name {
    static let gotDiskToImage = Notification.Name("gotDiskToImage")
    static let gotDiskToDisk = Notification.Name("gotDiskToDisk")
}


