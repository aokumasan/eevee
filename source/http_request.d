import std.socket;
import std.stdio;
import std.string;
import std.conv : to;

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

  string read() {
    // TODO: Fix buffer length to read
    char[1024] buffer;
    long received = client_.receive(buffer);
    string b = to!string(buffer[0 .. received]);
    data_ = b;
    return b;
  }

  string getPath() {
    string statusLine = data_.split("\r\n")[0];
    string p = statusLine.split(" ")[1];
    return p;
  }

  string getMethod() {
    string statusLine = data_.split("\r\n")[0];
    string m = statusLine.split(" ")[0];
    return m;
  }

  void getHeader() {
  }

  void getBody() {
  }

}
