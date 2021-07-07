module Apm
  record Span, label : String = "", start : Time::Span? = nil, finish : Time::Span? = nil do
    def to_s
      "#{label}: #{start} - #{finish}: #{interval == Float64::NAN ? "unfinished" : interval.as(Time::Span).total_seconds.humanize}"
    end

    def interval
      if (_finish = finish) && (_start = start)
        _finish - _start
      else
        Float64::NAN
      end
    end

    def add_finish_time(finished_at)
      new_timing = copy_with(finish: finished_at)
      new_timing.report

      new_timing
    end

    def report
      puts "#{self}"
    end
  end

  Timings = Hash(UInt64, Hash(String, Apm::Span)).new do |h, k|
    h[k] = {} of String => Apm::Span
  end

  VERSION = "0.1.0"
end

class HTTP::Server
  private def handle_client(io : IO)
    io_object_id = io.object_id
    label = "Total Request/Reponse Time"
    Apm::Timings[io_object_id][label] = Apm::Span.new(label: label, start: Time.monotonic)
    previous_def
    Apm::Timings[io_object_id][label].add_finish_time(finished_at: Time.monotonic)

    Apm::Timings.delete(io_object_id)
  end
end

module Kemal
  class LogHandler
    def call(context : HTTP::Server::Context)
      object_id = context.object_id
      label = "Time To Run Inner Request Handler and Flush IO Response"
      Apm::Timings[object_id][label] = Apm::Span.new(label: label, start: Time.monotonic)
      previous_def
      Apm::Timings[object_id][label].add_finish_time(finished_at: Time.monotonic)
    end
  end
end
