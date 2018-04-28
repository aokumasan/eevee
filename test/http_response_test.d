import BDD;
import http_request;
import core.thread;
import std.socket;

import http_response;

unittest {
  describe("HTTPResponse#getContentType",
    it("Should return correct mime type", delegate() {
      string[string] table = [
        "index.html": "text/html; charset=utf-8",
        "style.css": "text/css",
        "parrot.png": "image/png",
        "parrot.jpg": "image/jpeg",
        "parrot.jpeg": "image/jpeg",
        "parrot.JPEG": "image/jpeg",
        "bundle.js": "text/javascript",
      ];
      HTTPResponse res = new HTTPResponse();
      foreach (key; table.keys()) {
        res.getContentType(key).shouldEqual(table[key]);
      }
    })
  );
}

int main() {
  return BDD.printResults();
}
