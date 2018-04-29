import std.socket;

import std.stdio;
import std.string;

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
    auto statusLine = data_.split("\r\n")[0];
    return statusLine.split(" ")[1];
  }

  string getMethod() {
    auto statusLine = data_.split("\r\n")[0];
    return statusLine.split(" ")[0];
  }

  void getHeader() {
  }

  void getBody() {
  }

}
