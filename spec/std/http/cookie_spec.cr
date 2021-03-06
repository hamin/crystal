require "spec"
require "http/cookie"

module HTTP
  describe Cookie do
    it "parses key=value" do
      cookie = HTTP::Cookie.parse("key=value")
      cookie.name.should eq("key")
      cookie.value.should eq("value")
      cookie.to_header.should eq("key=value; path=/")
    end

    it "parses key=key=value" do
      cookie = HTTP::Cookie.parse("key=key=value")
      cookie.name.should eq("key")
      cookie.value.should eq("key=value")
      cookie.to_header.should eq("key=key%3Dvalue; path=/")
    end

    it "parses key=key%3Dvalue" do
      cookie = HTTP::Cookie.parse("key=key%3Dvalue")
      cookie.name.should eq("key")
      cookie.value.should eq("key=value")
      cookie.to_header.should eq("key=key%3Dvalue; path=/")
    end

    it "parses path" do
      cookie = HTTP::Cookie.parse("key=value; path=/test")
      cookie.name.should eq("key")
      cookie.value.should eq("value")
      cookie.path.should eq("/test")
      cookie.to_header.should eq("key=value; path=/test")
    end

    it "parses Secure" do
      cookie = HTTP::Cookie.parse("key=value; Secure")
      cookie.name.should eq("key")
      cookie.value.should eq("value")
      cookie.secure.should eq(true)
      cookie.to_header.should eq("key=value; path=/; Secure")
    end

    it "parses HttpOnly" do
      cookie = HTTP::Cookie.parse("key=value; HttpOnly")
      cookie.name.should eq("key")
      cookie.value.should eq("value")
      cookie.http_only.should eq(true)
      cookie.to_header.should eq("key=value; path=/; HttpOnly")
    end

    it "parses domain" do
      cookie = HTTP::Cookie.parse("key=value; domain=www.example.com")
      cookie.name.should eq("key")
      cookie.value.should eq("value")
      cookie.domain.should eq("www.example.com")
      cookie.to_header.should eq("key=value; path=/; domain=www.example.com")
    end

    it "parses expires rfc1123" do
      cookie = HTTP::Cookie.parse("key=value; expires=Sun, 06 Nov 1994 08:49:37 GMT")
      time = Time.new(1994, 11, 6, 8, 49, 37)

      cookie.name.should eq("key")
      cookie.value.should eq("value")
      cookie.expires.should eq(time)
    end

    it "parses expires rfc1036" do
      cookie = HTTP::Cookie.parse("key=value; expires=Sunday, 06-Nov-94 08:49:37 GMT")
      time = Time.new(1994, 11, 6, 8, 49, 37)

      cookie.name.should eq("key")
      cookie.value.should eq("value")
      cookie.expires.should eq(time)
    end

    it "parses expires ansi c" do
      cookie = HTTP::Cookie.parse("key=value; expires=Sun Nov  6 08:49:37 1994")
      time = Time.new(1994, 11, 6, 8, 49, 37)

      cookie.name.should eq("key")
      cookie.value.should eq("value")
      cookie.expires.should eq(time)
    end

    it "parses full" do
      cookie = HTTP::Cookie.parse("key=value; path=/test; domain=www.example.com; HttpOnly; Secure; expires=Sun, 06 Nov 1994 08:49:37 GMT")
      time = Time.new(1994, 11, 6, 8, 49, 37)

      cookie.name.should eq("key")
      cookie.value.should eq("value")
      cookie.path.should eq("/test")
      cookie.domain.should eq("www.example.com")
      cookie.http_only.should eq(true)
      cookie.secure.should eq(true)
      cookie.expires.should eq(time)
    end
  end

  describe Cookies do
    it "allows adding cookies and retrieving" do
      cookies = Cookies.new
      cookies << Cookie.new("a", "b")
      cookies["c"] = Cookie.new("c", "d")
      cookies["d"] = "e"

      cookies["a"].value.should eq "b"
      cookies["c"].value.should eq "d"
      cookies["d"].value.should eq "e"
      cookies["a"]?.should_not be_nil
      cookies["e"]?.should be_nil
      cookies.has_key?("a").should be_true
    end

    it "disallows adding inconsistent state" do
      cookies = Cookies.new

      expect_raises ArgumentError do
        cookies["a"] = Cookie.new("b", "c")
      end
    end

    it "allows to iterate over the cookies" do
      cookies = Cookies.new
      cookies["a"] = "b"
      cookies.each do |cookie|
        cookie.name.should eq "a"
        cookie.value.should eq "b"
      end

      cookie = cookies.each.next
      cookie.should eq Cookie.new("a", "b")
    end
  end
end

