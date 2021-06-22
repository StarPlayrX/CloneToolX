//
//  diskInfo.swift
//  CloneToolX
//
//  Created by Todd on 7/7/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation

typealias diskInfoType = (DeviceIdentifier: String,     DeviceNode: String,     Whole: String,      PartofWhole: String,
    VolumeName: String,           Mounted: String,        MountPoint: String,
    TypeBundle: String,           Owners: String,
    OSCanBeInstalled: String)

func diskInfo (volume: String) -> diskInfoType {
    
    //diskutil info -plist /Volumes/Install
    var diskInfo = [String]()
    if volume == "/" {
        diskInfo = ["info", "/"]
    } else {
        diskInfo = ["info", "/Volumes/\(volume)"]
    }
    
    let diskArrayInfo = runCommandReturnString(binary: "/usr/sbin/diskutil", arguments: diskInfo)
    
    let diskArray = diskArrayInfo.components(separatedBy: "\n") //as [String]
    
    print(diskArrayInfo)
    
    var DeviceIdentifier = ""
    var DeviceNode = ""
    var Whole = ""
    var PartofWhole = ""
    
    var VolumeName = ""
    var Mounted = ""
    var MountPoint = ""
    
    var TypeBundle = ""
    var Owners = ""
    
    var OSCanBeInstalled = ""
    
    /*
 
     2019-07-07 21:19:32.776617-0400 CloneToolX[3228:84726] Metal API Validation Enabled
     Device Identifier:         disk10s3
     Device Node:               /dev/disk10s3
     Whole:                     No
     Part of Whole:             disk10
     
     Volume Name:               Blank
     Mounted:                   Yes
     Mount Point:               /Volumes/Blank
     
     Partition Type:            Apple_HFS
     File System Personality:   Journaled HFS+
     Type (Bundle):             hfs
     Name (User Visible):       Mac OS Extended (Journaled)
     Journal:                   Journal size 40960 KB at offset 0xed0000
     Owners:                    Disabled
     
     OS Can Be Installed:       Yes
     Media Type:                Generic
     Protocol:                  SATA
     SMART Status:              Verified
     Volume UUID:               699699B5-6977-34CC-BC60-1FE4CB4FB0C6
     Disk / Partition UUID:     BE650025-7586-45E6-AF07-07FE1ECF9166
     Partition Offset:          3343949824 Bytes (6531152 512-Byte-Device-Blocks)
     
     Disk Size:                 508.6 GB (508632002560 Bytes) (exactly 993421880 512-Byte-Units)
     Device Block Size:         512 Bytes
     
     Volume Total Space:        508.6 GB (508632002560 Bytes) (exactly 993421880 512-Byte-Units)
     Volume Used Space:         448.8 MB (448786432 Bytes) (exactly 876536 512-Byte-Units) (0.1%)
     Volume Free Space:         508.2 GB (508183216128 Bytes) (exactly 992545344 512-Byte-Units) (99.9%)
     Allocation Block Size:     4096 Bytes
     
     Read-Only Media:           No
     Read-Only Volume:          No
     
     Device Location:           External
     Removable Media:           Fixed
     
     Solid State:               Yes
     Hardware AES Support:      No
     
     
     Device Identifier:         disk9s1
     Device Node:               /dev/disk9s1
     Whole:                     No
     Part of Whole:             disk9
     
     Volume Name:               Cat C3
     Mounted:                   Yes
     Mount Point:               /
     
     Partition Type:            41504653-0000-11AA-AA11-00306543ECAC
     File System Personality:   APFS
     Type (Bundle):             apfs
     Name (User Visible):       APFS
     Owners:                    Enabled
     
     OS Can Be Installed:       No
     Booter Disk:               disk9s3
     Recovery Disk:             disk9s4
     Media Type:                Generic
     Protocol:                  SATA
     SMART Status:              Verified
     Volume UUID:               BBBD8772-7009-45B8-B9F8-C89F14423226
     Disk / Partition UUID:     BBBD8772-7009-45B8-B9F8-C89F14423226
     
     Disk Size:                 249.7 GB (249693204480 Bytes) (exactly 487682040 512-Byte-Units)
     Device Block Size:         4096 Bytes
     
     Container Total Space:     249.7 GB (249693204480 Bytes) (exactly 487682040 512-Byte-Units)
     Container Free Space:      197.7 GB (197689094144 Bytes) (exactly 386111512 512-Byte-Units)
     Allocation Block Size:     4096 Bytes
     
     Read-Only Media:           No
     Read-Only Volume:          Yes
     
     Device Location:           Internal
     Removable Media:           Fixed
     
     Solid State:               No
     Hardware AES Support:      No
     Device Location:           "Bay 4"
     
     This disk is an APFS Volume.  APFS Information:
     APFS Container:            disk9
     APFS Physical Store:       disk4s7
     Fusion Drive:              No
     APFS Volume Group:         1DF1676B-C2C3-49DA-A77B-D5DD382643A0
     FileVault:                 No
     Locked:                    No
     
     
     targetDiskInfo (DeviceIdentifier: "disk10s3", DeviceNode: "/dev/disk10s3", Whole: "No", PartofWhole: "disk10", VolumeName: "Blank", Mounted: "Yes", MountPoint: "/Volumes/Blank", PartitionType: "Apple_HFS", TypeBundle: "hfs", Owner: "Disabled", OSCanBeInstalled: "Yes")
     sourceDiskInfo (DeviceIdentifier: "disk9s1", DeviceNode: "/dev/disk9s1", Whole: "No", PartofWhole: "disk9", VolumeName: "C3", Mounted: "Yes", MountPoint: "/", PartitionType: "41504653-0000-11AA-AA11-00306543ECAC", TypeBundle: "apfs", Owner: "Enabled", OSCanBeInstalled: "No")
  */
    
    
    //We are going to parse what we need long hand until we adopt reading in a plist file
    //For now this just easier to parse this out even though it's ugly
    for i in diskArray {
        //First
        if i.contains("Device Identifier") {
            DeviceIdentifier = i.components(separatedBy: "         ").last! //as [String]
        } else if i.contains("Device Node") {
            DeviceNode = i.components(separatedBy: "               ").last! //as [String]
        } else if i.contains("  Whole") {
            Whole = i.components(separatedBy: "                     ").last! //as [String]
        } else if i.contains("Part of Whole") {
            PartofWhole = i.components(separatedBy: "             ").last! //as [String]
            
            //Second
        } else if i.contains("Volume Name") {
            VolumeName = i.components(separatedBy: "               ").last! //as [String]
        } else if i.contains("Mounted") {
            Mounted = i.components(separatedBy: "                   ").last! //as [String]
        } else if i.contains("Mount Point") {
            MountPoint = i.components(separatedBy: "               ").last! //as [String]
            
        //Third
        } else if i.contains("Type (Bundle)") {
            TypeBundle = i.components(separatedBy: "             ").last! //as [String]
        } else if i.contains("Owners") {
            Owners = i.components(separatedBy: " ").last! //as [String]
            
        //Fourth
        } else if i.contains("OS Can Be Installed") {
            OSCanBeInstalled = i.components(separatedBy: "       ").last! //as [String]
        }
        
    }
    
    let returnData = (DeviceIdentifier: DeviceIdentifier,   DeviceNode: DeviceNode,     Whole: Whole,      PartofWhole: PartofWhole,
                      VolumeName: VolumeName,               Mounted: Mounted,           MountPoint: MountPoint,
                      TypeBundle: TypeBundle,               Owners: Owners,
                      OSCanBeInstalled: OSCanBeInstalled) as diskInfoType
    
    print(returnData)
    
    return returnData
}
