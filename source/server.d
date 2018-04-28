import std.stdio;
import std.socket;
import std.file;
import std.path;

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
      try {
	HTTPRequest req = new HTTPRequest(client);
	auto body = req.read();
	writeln("* request acceptted");

	HTTPResponse res = new HTTPResponse();
	res.set_header("Content-Type", "text/html; charset=utf-8");
	string path = req.getPath();
	string filepath;
	if (path == "/") {
	  filepath = "./public/index.html";
	} else {
	  filepath = "./public" ~ buildNormalizedPath(path);
	}
	res.set_body(cast(ubyte[])read(filepath));
	auto data = res.generate_data();
	writeln("* response sending");
	client.send(data);
      } catch (Exception e) {
	writeln(e);
      }
      finally {
	client.shutdown(SocketShutdown.BOTH);
	client.close();
      }
    }
  }
}
