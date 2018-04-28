import std.socket;

import std.stdio;
import std.string;
import std.array : array;

class HTTPRequest {
  private:
  Socket client_;
  string data_;

  public:
  this(Socket client) {
    client_  = client;
  }

  @property
  {
    string data() const { return data_; }
    void data(string data) { data_ = data; }
  }

  char[1024] read() {
    // TODO: Fix buffer length to read
    char[1024] buffer;
    client_.receive(buffer);
    data_ = cast(string)buffer;
    return buffer;
  }

  string getPath() {
    auto statusLine = lineSplitter(data_).array[0];
    writeln(statusLine);
    auto path = statusLine.split(" ")[1];
    return path;
  }

  void getHeader() {

  }

  void getBody() {

  }

}
