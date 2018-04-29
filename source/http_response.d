import std.stdio;
import core.stdc.string : strlen;
import std.conv : to;
import std.string;
import std.path;
import std.file;

class HTTPResponse {
  private:
  string method_;
  string[string] header_;
  ubyte[] body_;

  public:
  this(string method="GET") {
    method_ = method;
  }

  void setHeader(string key, string value) {
    header_[key] = value;
  }

  int calcContentLength() {
    return cast(int)(body_.length);
  }

  string generateHeader() {
    header_["Content-Length"] = to!string(calcContentLength());
    string header = "";
    foreach (key; header_.keys()) {
      header ~= (key ~ ": " ~ header_[key]);
      header ~= "\r\n";
    }
    return header;
  }

  string generateStatusLine(int code) {
    string[int] table = [
      200: "OK",
      400: "Bad Request",
      404: "Not Found",
      405: "Method Not Allowed"
    ];
    return "HTTP/1.0 " ~ to!string(code) ~ " " ~ to!string(table[code]) ~ "\r\n";
  }

  void deleteHeader(string key) {
    header_.remove(key);
  }

  void setBody(ubyte[] body) {
    body_ = body;
  }

  string getContentType(string filepath) {
    string ext = toLower(extension(filepath));
    // TODO: Fix it
    string[string] contentTypes = [
      ".html": "text/html; charset=utf-8",
      ".css": "text/css",
      ".png": "image/png",
      ".gif": "image/gif",
      ".jpeg": "image/jpeg",
      ".jpg": "image/jpeg",
      ".js": "text/javascript"
    ];
    // default content type is text/plain
    return contentTypes.get(ext, "text/plain");
  }

  void setBodyFromPath(string filepath) {
    string contentType = getContentType(filepath);
    setHeader("Content-Type", contentType);
    setBody(cast(ubyte[])read(filepath));
  }

  string generateData(int code) {
    string data = "";
    data ~= generateStatusLine(code);
    data ~= generateHeader();
    data ~= "\r\n";
    if (method_ == "HEAD") {
      return data;
    }
    data ~= cast(string)body_;
    return data;
  }

}
