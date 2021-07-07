require "sinatra"

# This is the Sinatra equivalent of the Kemal app that serves as the testbed
# for our tiny APM module. It is offered just because it is an interesting comparison.

get "/hello" do
  "Hello World!"
end
