//
//  main.cpp
//  art_001_003
//
//  Created by Jaime Rios on 2019-06-1.
//  Copyright © 2019 Jaime Rios. All rights reserved.
//

// The C++ STD Library headers
#include <iostream>
#include <string>

// The Microsoft Headers
#include <cpprest/filestream.h>
#include <cpprest/http_client.h>

using namespace std::string_literals;

// The address to our server
const auto server_url = "http://localhost:3000"s;

// Function that will attempt to connect to a REST endpoint
auto connect_to_server()
{
    std::cout << "Function connect_to_server called" << std::endl;
    
    // The connection to our server
    auto client = web::http::client::http_client(server_url);
    
    // The stream to capture our incoming JSON data
    auto json_data = std::make_shared< concurrency::streams::ostream >();
    
    //
    // You'll notice that the naming of the following lambda's are verbs,
    // to describe what they intend on doing
    //
    
    // Lambda to capture the incoming stream and return the client request
    auto create_request = [&](concurrency::streams::ostream incoming_data) {
        std::cout << "Lambda request called" << std::endl;
        *json_data = incoming_data;
        
        // Return a request object, appending the events path component
        return client.request(web::http::methods::GET, U("/events"));
    };
    
    // Lambda to handle the HTTP response, directing the data to our json_data
    auto handle_response = [&json_data](web::http::http_response response) {
        std::cout << "Lambda handle_response called" << std::endl;
        std::cout << "Response status code: " << response.status_code() << std::endl;
        return response.body().read_to_end(json_data->streambuf());
    };
    
    // Lambda to close the json_data once the stream is done
    auto close_down = [&json_data](size_t) {
        std::cout << "Lambda close_down called" << std::endl;
        return json_data->close();
    };
    
    // The bool to make our code wait
    auto done = false;
    // The lambda that breaks the code out of the nasty loop
    auto signal_done = [&done]() {
        std::cout << "Lambda signal_done called" << std::endl;
        done = true;
    };
    
    // Now, let's put them all together
    auto output_result_file = concurrency::streams::fstream::open_ostream(U("results.html"));
    output_result_file // First open the output result file, then ...
        .then(create_request)
        .then(handle_response)
        .then(close_down)
        .then(signal_done);
    
    // You should see a pattern here how the process flow works
    // with cpprestsdk
    
    // The nasty loop
    
}

int main(int argc, const char* argv[])
{
    std::cout << "Application is starting\n";

    connect_to_server();
    
    std::cout << "Application will exit now\n";
    return 0;
}
