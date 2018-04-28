import std.socket;

class HTTPRequest {
  private:
  Socket client_;

  public:
  this(Socket client) {
    client_  = client;
  }

  char[1024] read() {
    char[1024] buffer;
    client_.receive(buffer);
    return buffer;
  }
}
