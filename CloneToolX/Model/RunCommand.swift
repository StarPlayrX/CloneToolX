//
//  RunCommand.swift
//  CloneToolX
//
//  Created by todd on 6/30/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import AppKit

func runCommandReturnArray(binary: String, arguments: [String]) -> [String] {
    
    let task = Process()
    task.launchPath = binary
    task.arguments = arguments
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output =  String(data: data, encoding: String.Encoding.utf8)!
    
    var array1 = output.components(separatedBy: "\n")
    array1 = array1.dropLast()
    
    var array : [String] = []
    
    for i in array1 {
        if !i.contains(" - Data") {
            array.append(i)
        }
    }
    
    return array
}


func runCommandReturnString(binary: String, arguments: [String]) -> String {
    
    let task = Process()
    task.launchPath = binary
    task.arguments = arguments
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output =  String(data: data, encoding: String.Encoding.utf8)!
    
    return output
    
}
