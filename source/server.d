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
import std.parallelism;

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
  string[string] cache_;

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

    while(true) {
      Socket client = server_.accept();
      auto task = task(&process, client);
      task.executeInNewThread();
    }
  }

  void process(Socket client) {
      HTTPRequest req = new HTTPRequest(client);
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
        if (cache_.get(path, null) != null) {
	  writeln("using cache");
	  res.setBody(cast(ubyte[])cache_[path]);
	} else {
	  res.setBodyFromPath(getLocalFile(path));
	  cache_[path] = cast(string)res.data;
	}
        string data = res.generateData(200);
        logf(LogLevel.info, "%s %s HTTP/1.0 200", method, path);
        client.send(data);
      } catch (FileException e) {
        if (indexOf(e.msg, "No such file or directory") == -1) {
          logf(LogLevel.info, "%s %s HTTP/1.0 500", method, path);
          handleInternalServerError(client);
        } else {
	  logf(LogLevel.info, "%s %s HTTP/1.0 404", method, path);
	  handleNotFoundError(client);
	}
      } catch (MethodNotAllowedException e) {
	logf(LogLevel.info, "%s %s HTTP/1.0 405", method, path);
	handleMethodNotAllowedError(client);
      } catch (Exception e) {
	writeln(e);
	logf(LogLevel.info, "%s %s HTTP/1.0 500", method, path);
	handleInternalServerError(client);
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

  void handleNotFoundError(Socket client) {
    HTTPResponse res = new HTTPResponse();
    res.setHeader("Content-Type", "text/html; charset=utf-8");
    res.setBody(cast(ubyte[])"<h1>Not Found</h1>");
    string data = res.generateData(404);
    client.send(data);
  }

  void handleMethodNotAllowedError(Socket client) {
    HTTPResponse res = new HTTPResponse();
    res.setHeader("Content-Type", "text/html; charset=utf-8");
    res.setBody(cast(ubyte[])"<h1>Method Not Allowed</h1>");
    auto data = res.generateData(405);
    client.send(data);
  }

  void handleInternalServerError(Socket client) {
    HTTPResponse res = new HTTPResponse();
    res.setHeader("Content-Type", "text/html; charset=utf-8");
    res.setBody(cast(ubyte[])"<h1>Internal Server Error</h1>");
    string data = res.generateData(500);
    client.send(data);
  }

}
