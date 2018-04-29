import std.stdio;
import std.socket;
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
	// TODO: Fix it
	req.read();

	string method = req.getMethod();
	string path = req.getPath();
	HTTPResponse res = new HTTPResponse(method);
	res.setBodyFromPath(getLocalFile(path));
	auto data = res.generateData();
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

  string getLocalFile(string path) {
    const string root = "./public";
    if (path == "/") {
      return root  ~ "/index.html";
    }
    return root ~ buildNormalizedPath(path);
  }

}
