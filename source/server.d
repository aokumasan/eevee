import std.stdio;
import std.socket;
import std.path;
import std.file;

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

  void run(int maxClient=1) {
    server_.bind(new InternetAddress(port_));
    server_.listen(maxClient);
    while(1) {
      Socket client = server_.accept();
      HTTPRequest req = new HTTPRequest(client);
      // TODO: Fix it
      req.read();

      string method;
      string path;
      try {
	method = req.getMethod();
	path = req.getPath();
	HTTPResponse res = new HTTPResponse(method);
	res.setBodyFromPath(getLocalFile(path));
	auto data = res.generateData(200);
	client.send(data);
      } catch (FileException e) {
	HTTPResponse res = new HTTPResponse(method);
	res.setHeader("Content-Type", "text/html; charset=utf-8");
	res.setBody(cast(ubyte[])"<h1>Not Found</h1>");
	auto data = res.generateData(404);
	client.send(data);
      } catch (Exception e) {
	writeln(e);
      } finally {
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
