import BDD;
import core.thread;
import core.stdc.stdlib;
import core.stdc.time;
import requests;
import std.experimental.logger;
import std.file;

import std.stdio;

import server;

unittest {
  Server srv = new Server(8080);
  Thread th = new Thread(() => srv.run());
  th.start;

  // Workaround for suppress the request log (https://github.com/ikod/dlang-requests/issues/9#issuecomment-219279562)
  globalLogLevel(LogLevel.error);

  describe("Server#run",
    it("Should return index.html with request path / ", delegate() {
	Request rq = Request();
	Response rs = rq.get("http://localhost:8080/");
	rs.code.shouldEqual(200);
	rs.responseHeaders["content-type"].shouldEqual("text/html; charset=utf-8");
	rs.responseBody.shouldEqual(readText("./public/index.html"));
    }),
    it("Should return success response with request path /hello.html", delegate() {
	Request rq = Request();
	Response rs = rq.get("http://localhost:8080/hello.html");
	rs.code.shouldEqual(200);
	rs.responseHeaders["content-type"].shouldEqual("text/html; charset=utf-8");
	rs.responseBody.shouldEqual(readText("./public/hello.html"));
    }),
    it("Should ignore previous path like /../index.html", delegate() {
	Request rq = Request();
	Response rs = rq.get("http://localhost:8080/../index.html");
	rs.code.shouldEqual(200);
	rs.responseHeaders["content-type"].shouldEqual("text/html; charset=utf-8");
	rs.responseBody.shouldEqual(readText("./public/index.html"));
    }),
    it("Should return css", delegate() {
	Request rq = Request();
	Response rs = rq.get("http://localhost:8080/css/style.css");
	rs.code.shouldEqual(200);
	rs.responseHeaders["content-type"].shouldEqual("text/css");
	rs.responseBody.shouldEqual(readText("./public/css/style.css"));
    }),
    it("Should return png image", delegate() {
	Request rq = Request();
	Response rs = rq.get("http://localhost:8080/img/parrot.png");
	rs.code.shouldEqual(200);
	rs.responseHeaders["content-type"].shouldEqual("image/png");
	auto image = cast(ubyte[])read("./public/img/parrot.png");
	rs.responseBody.shouldEqual(cast(string)image);
    }),
    it("Should return HEAD response", delegate() {
	Request rq = Request();
	Response rs = rq.exec!"HEAD"("http://localhost:8080/");
	rs.code.shouldEqual(200);
	rs.responseHeaders["content-type"].shouldEqual("text/html; charset=utf-8");
	rs.responseBody.shouldEqual("");
    }),
    it("Should return 404 (Not Found) if specified path is not found", delegate() {
	Request rq = Request();
	Response rs = rq.exec!"HEAD"("http://localhost:8080/notfoundpath.html");
	rs.code.shouldEqual(404);
	rs.responseHeaders["content-type"].shouldEqual("text/html; charset=utf-8");
	rs.responseBody.shouldEqual("<h1>Not Found</h1>");
    }),
    it("Should return 405 (Method Not Allowed) if specified method is not GET or HEAD", delegate() {
	Request rq = Request();
	Response rs = rq.post("http://localhost:8080/");
	rs.code.shouldEqual(405);
	rs.responseHeaders["content-type"].shouldEqual("text/html; charset=utf-8");
	rs.responseBody.shouldEqual("<h1>Method Not Allowed</h1>");
    })
  );
}

void main() {
  auto ret = BDD.printResults();
  exit(ret);
}
