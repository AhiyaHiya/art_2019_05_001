//
//  main.swift
//  Art_001_002
//
//  Created by Jaime Rios on 2019-05-24.
//  Copyright © 2019 Jaime Rios. All rights reserved.
//

import Foundation

// The address to our server
let serverURL = "http://localhost:3000"
// The variable that lets the loop know it is time to stop
var processIsDone = false

// Typealiases to make our function parameters look neater
typealias Success = () -> Void
typealias Failure = (_ error: Error?) -> Void

// Function that will attempt to connect to a REST endpoint
func connectToServer(callWhenDone success: @escaping Success, callWhenError failure: Failure?) {

    // Create a URL from our string path
    guard let urlPath = URL(string: serverURL) else { print("Failure to create a URL path"); return }
    
    // Set up the request object
    var request = URLRequest(url: urlPath)
    request.httpMethod = "GET"
    
    // Create a data task that will be processed asynchronously
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: {
        (data, response, error) in

        // A closure to handle the task process
        
        // If we have an error, well, that's a problem
        guard error == nil else { failure?(error); return }
        // If we can't get the data, that's a problem too
        guard let received = data else { failure?(error); return }
        // And, if we can't get the response, we shouldn't proceed
        guard let httpResponse = response as? HTTPURLResponse else { print("Could not get theHTTP response"); return }

        // If we made it to this point, then we are golden
        print(httpResponse)
        print(received.description)

        success()
    })

    // This is the line that tells the task to start it's job
    task.resume()
}

// Call the function, passing in a success and failure closure
connectToServer(callWhenDone: {
    () in
    
    // The closure that will tell the app that
    // it is ready to move on from the loop
    print("Task is done; connectToServer called")
    processIsDone = true
}, callWhenError: {
    ( error ) in
    
    // A closure to handle when an error was detected
    
    if let err = error {
        print("Detected error: \(err.localizedDescription)")
    }
    processIsDone = true
})

// Loop to give the asynchronous data task enough time to get
// a response from the server
var x = 0
while processIsDone == false {
    // We have to do something, right?
    x += 1
}

print("Application will exit now")
