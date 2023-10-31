require 'rubygems'
require "sinatra"
require "sinatra/streaming"

set :server, 'thin'

ascii_frames = []

(0..7).each do |i|
  ascii_frames.push(IO.read("ascii_frames/frame#{i}.txt"))
end

ansi_clear = "\033[2J\033[3J\033[H"

def chunk(str)
  "#{str.length.to_s(16)}\r\n#{str}\r\n"
end

get '/live' do
  return "use curl: `curl #{[request.host,request.port].join(':')}#{request.path}`" unless request.user_agent && request.user_agent.include?('curl')

  # Set chunked transfer encoding and plain text for ANSI support
  headers "Content-Type" => "text/plain"
  headers "Transfer-Encoding" => "chunked"
  headers "Connection" => "keep-alive"
  stream do |out|
    while out
      ascii_frames.each do |frame|
        out << chunk(ansi_clear)
        out << chunk(frame)
        out.flush
        sleep 0.1
      end
    end
  rescue IOError
    puts "client disconnected"
  ensure
    out.close
  end
end
