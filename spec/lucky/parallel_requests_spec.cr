{% skip_file unless Fiber.has_constant?(:ExecutionContext) && Fiber::ExecutionContext.has_constant?(:Parallel) %}

require "../spec_helper"
require "wait_group"

private PARALLEL_WORKERS    =   8
private PARALLEL_ITERATIONS = 250
private RATE_LIMIT          =  50

class ParallelRequests::Show < TestAction
  get "/parallel_requests/:number" do
    session.set(:number, number)
    cookies.set(:number, number)
    flash.success = number
    plain_text "#{number}:#{session.get(:number)}:#{cookies.get(:number)}:#{flash.success}"
  end
end

class ParallelRequests::Limited::Index < TestAction
  include Lucky::RateLimit
  rate_limit to: RATE_LIMIT, within: 1.minute

  get "/parallel_requests/limited" do
    plain_text "ok"
  end

  private def rate_limit_identifier : String
    "parallel"
  end
end

private def in_parallel(&block : Int32 ->)
  context = Fiber::ExecutionContext::Parallel.new("lucky-spec", PARALLEL_WORKERS)
  errors = Channel(Exception).new(PARALLEL_WORKERS)
  group = WaitGroup.new(PARALLEL_WORKERS)

  PARALLEL_WORKERS.times do |worker|
    context.spawn do
      block.call(worker)
    rescue ex
      errors.send(ex)
    ensure
      group.done
    end
  end

  group.wait
  errors.close
  if error = errors.receive?
    raise error
  end
end

private def perform(app : HTTP::Handler, path : String) : HTTP::Client::Response
  io = IO::Memory.new
  context = HTTP::Server::Context.new(HTTP::Request.new("GET", path), HTTP::Server::Response.new(io))
  app.call(context)
  context.response.close
  HTTP::Client::Response.from_io(io.rewind)
end

private def build_app : HTTP::Handler
  HTTP::Server.build_middleware([
    Lucky::RequestIdHandler.new,
    Lucky::LogHandler.new,
    Lucky::RouteHandler.new,
  ] of HTTP::Handler)
end

describe "parallel requests" do
  it "keeps params, session, cookies, and flash separate for each request" do
    app = build_app

    in_parallel do |worker|
      PARALLEL_ITERATIONS.times do |i|
        number = "#{worker}-#{i}"
        response = perform(app, "/parallel_requests/#{number}")

        response.status.should eq(HTTP::Status::OK)
        response.body.should eq("#{number}:#{number}:#{number}:#{number}")
        response.headers.get("Set-Cookie").size.should eq(2)
      end
    end

    Lucky::Events::RequestCompleteEvent.logged_events.size.should eq(PARALLEL_WORKERS * PARALLEL_ITERATIONS)
  end

  it "allows exactly the rate limit across threads" do
    app = build_app
    allowed = Atomic(Int32).new(0)
    limited = Atomic(Int32).new(0)

    LuckyCache.temp_config(storage: LuckyCache::MemoryStore.new) do
      in_parallel do |_worker|
        PARALLEL_ITERATIONS.times do
          case perform(app, "/parallel_requests/limited").status
          when .ok?                then allowed.add(1)
          when .too_many_requests? then limited.add(1)
          end
        end
      end
    end

    allowed.get.should eq(RATE_LIMIT)
    limited.get.should eq(PARALLEL_WORKERS * PARALLEL_ITERATIONS - RATE_LIMIT)
  end
end
