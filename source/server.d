import std.stdio;
import std.socket;

import http_request;
import http_response;


class Server {
  private:
  Socket server_;
  ushort port_;

  public:
  this(ushort port) {
    server_ = new TcpSocket();
    server_.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    port_ = port;
  }

  @property {
    int port() const { return port_; }
  }

  void run(int max_client=1) {
    server_.bind(new InternetAddress(port_));
    server_.listen(max_client);
    while(1) {
      Socket client = server_.accept();
      HTTPRequest req = new HTTPRequest(client);
      auto body = req.read();
      writeln(body);
      HTTPResponse res = new HTTPResponse();
      res.set_header("Content-Type", "text/html; charset=utf-8");
      res.set_body("<h1>Hello, world!!</h1>");
      auto data = res.generate_data();
      writeln(data);
      client.send(data);
      client.shutdown(SocketShutdown.BOTH);
      client.close();
    }
  }
}
