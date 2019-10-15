require "rack"

use Rack::Reloader, 0  
use Rack::ContentLength

app = proc do |env|  
  [200, {'Content-Type' => 'text/plain'}, ['Test app ok']]
end

run app  
