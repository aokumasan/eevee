import BDD;
import http_request;
import core.thread;
import std.socket;

unittest {
  describe("HTTPRequest#getPath",
    it("Should return root path (/) from request status line", delegate() {
	auto socket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
	HTTPRequest req = new HTTPRequest(socket);
	req.data = "GET / HTTP/1.0\r\nContent-Type: text/html; charset=uth-8\r\n\r\n";
	string path = req.getPath();
	path.shouldEqual("/");
	socket.close();
    }),
    it("Should return specified path (/hello.html) from request status line", delegate() {
	auto socket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
	HTTPRequest req = new HTTPRequest(socket);
	req.data = "GET /hello.html HTTP/1.0\r\nContent-Type: text/html; charset=uth-8\r\n\r\n";
	string path = req.getPath();
	path.shouldEqual("/hello.html");
	socket.close();
    }),
    it("Should return directory hierarchy (/test/index.html) from request status line", delegate() {
	auto socket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
	HTTPRequest req = new HTTPRequest(socket);
	req.data = "GET /test/index.html HTTP/1.0\r\nContent-Type: text/html; charset=uth-8\r\n\r\n";
	string path = req.getPath();
	path.shouldEqual("/test/index.html");
	socket.close();
    }),
  );

  describe("HTTPRequest#getMethod",
    it("Should return correct method", delegate() {
      auto socket = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
      HTTPRequest req = new HTTPRequest(socket);
      string[] methods = [
        "GET", "POST", "PUT", "DELETE", "HEAD"
      ];
      foreach (method; methods) {
        req.data = method ~ " /test/index.html HTTP/1.0\r\nContent-Type: text/html; charset=uth-8\r\n\r\n";
        req.getMethod().shouldEqual(method);
      }
    })
  );
}

int main() {
  return BDD.printResults();
}
