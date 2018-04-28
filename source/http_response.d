import std.stdio;
import core.stdc.string : strlen;
import std.conv : to;

class HTTPResponse {
  private:
  string[string] header_;
  ubyte[] body_;

  int calc_content_length() {
    return cast(int)(body_.length);
  }

  string generate_header() {
    header_["Content-Length"] = to!string(calc_content_length());
    string header = "";
    foreach (key; header_.keys()) {
      header ~= (key ~ ": " ~ header_[key]);
      header ~= "\r\n";
    }
    return header;
  }

  string generate_status_line() {
    return "HTTP/1.0 200 OK\r\n";
  }

  public:
  void set_header(string key, string value) {
    header_[key] = value;
  }

  void delete_header(string key) {
    header_.remove(key);
  }

  void set_body(ubyte[] body) {
    body_ = body;
  }

  string generate_data() {
    string data = "";
    data ~= generate_status_line();
    data ~= generate_header();
    data ~= "\r\n";
    data ~= cast(string)body_;
    return data;
  }

}
