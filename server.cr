require "kemal"
require "./src/apm"

get "/hello" do
  "Hello World!"
end

Kemal.run
