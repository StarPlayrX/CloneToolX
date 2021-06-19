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
    
    //task.launchPath = binary
    let file = "file://"
    task.executableURL = URL(fileURLWithPath: file + binary)

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
    
    //task.launchPath = binary
    let file = "file://"
    task.executableURL = URL(fileURLWithPath: file + binary)
    
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


//set volname to text 1 thru -2 of (path to startup disk as string)
/// Performs an AppleScript and return String and error NSDictionary.
/// - Parameter script: script to run as text
/// - Returns: returns a tuple with text as String ans error as an NSDirectionary
func performAppleScript(script: String) -> (text: String, error: NSDictionary?)? {
    
    var text : String = ""
    var error : NSDictionary?
    
    if let script = NSAppleScript(source: script) {
        let result = script.executeAndReturnError(&error) as NSAppleEventDescriptor
        if let str = result.stringValue {
            text = str
        }
    }
    
    return (text: text, error: error)
}
