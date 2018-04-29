import std.stdio;
import std.socket;
import std.conv;
import std.path;
import std.string;
import std.file;
import std.typecons : No;
import core.thread;
import std.algorithm: canFind;
import std.experimental.logger;

import http_request;
import http_response;

const string[] availableMethods = [
  "GET", "HEAD"
];

class MethodNotAllowedException : Exception
{
  this(string msg, string file = __FILE__, size_t line = __LINE__) {
    super(msg, file, line);
  }
}

class Server {
  private:
  Socket server_;

  public:
  this() {
    server_ = new TcpSocket();
    server_.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    setupLogger();
  }

  void run(ushort port=8080, int maxConnections=512) {
    server_.bind(new InternetAddress(port));
    server_.listen(maxConnections);

    log(LogLevel.info, "Eevee listening on " ~ port.to!string);

    while(1) {
      Socket client = server_.accept();
      new Thread(() => process(client)).start;
      // Workaround for using socket in thread
      Thread.sleep( dur!("usecs")(1000) );
    }
  }

  void process(Socket client) {
      HTTPRequest req = new HTTPRequest(client);
      // TODO: Fix it
      req.read();

      string method;
      string path;
      try {
	method = req.getMethod();
	if (!availableMethods.canFind(method)) {
	  throw new  MethodNotAllowedException("The specified method is not allowed");
	}
	path = req.getPath();
	HTTPResponse res = new HTTPResponse(method);
	res.setBodyFromPath(getLocalFile(path));
	auto data = res.generateData(200);
	logf(LogLevel.info, "%s %s HTTP/1.0 200", method, path);
	// log(LogLevel.trace, req.data);
	client.send(data);
      } catch (FileException e) {
	if (indexOf(e.msg, "No such file or directory") == -1) {
	  HTTPResponse res = new HTTPResponse();
	  res.setHeader("Content-Type", "text/html; charset=utf-8");
	  res.setBody(cast(ubyte[])"<h1>Internal Server Error</h1>");
	  auto data = res.generateData(500);
	  logf(LogLevel.info, "%s %s HTTP/1.0 500", method, path);
	  client.send(data);
	} else {
	  HTTPResponse res = new HTTPResponse();
	  res.setHeader("Content-Type", "text/html; charset=utf-8");
	  res.setBody(cast(ubyte[])"<h1>Not Found</h1>");
	  auto data = res.generateData(404);
	  logf(LogLevel.info, "%s %s HTTP/1.0 404", method, path);
	  client.send(data);
	}
      } catch (MethodNotAllowedException e) {
	HTTPResponse res = new HTTPResponse();
	res.setHeader("Content-Type", "text/html; charset=utf-8");
	res.setBody(cast(ubyte[])"<h1>Method Not Allowed</h1>");
	auto data = res.generateData(405);
	logf(LogLevel.info, "%s %s HTTP/1.0 405", method, path);
	client.send(data);
      } catch (Exception e) {
	writeln(e);
	HTTPResponse res = new HTTPResponse();
	res.setHeader("Content-Type", "text/html; charset=utf-8");
	res.setBody(cast(ubyte[])"<h1>Internal Server Error</h1>");
	auto data = res.generateData(500);
	logf(LogLevel.info, "%s %s HTTP/1.0 500", method, path);
	client.send(data);
      } finally {
	client.shutdown(SocketShutdown.BOTH);
	client.close();
      }
  }

  string getLocalFile(string path) {
    const string root = "./public";
    if (path == "/") {
      return root  ~ "/index.html";
    }
    return root ~ buildNormalizedPath(path);
  }

  void setupLogger() {
    string type = "stderr";
    string level = "info";

    switch(level) {
      case "trace":
        stdThreadLocalLog.logLevel = LogLevel.trace;
        break;
      case "info":
        stdThreadLocalLog.logLevel = LogLevel.info;
        break;
      case "warning":
        stdThreadLocalLog.logLevel = LogLevel.warning;
        break;
      case "error":
        stdThreadLocalLog.logLevel = LogLevel.error;
        break;
      default:
        stdThreadLocalLog.logLevel = LogLevel.info;
        break;
    }

    if (type == "file") {
      string logfile = "log/eevee.log";
      sharedLog = new FileLogger(logfile);
    }
  }

}
