require "json"
require "redis"

module MsgQ
 CFG_SRC = File.expand_path(File.dirname(__FILE__) + "/../redis.yml")
 CFG = YAML.load_file(CFG_SRC)[ENV["RAILS_ENV"] || "development"][:mq]
 @mq = Redis.new(CFG)

 # Messages live for 3 days
 MSG_TTL = 60 * 60 * 24 * 3
 BLOCK_TIMEOUT = 10

 class Msg
   attr_reader :q, :id, :body

   def initialize(q, id, body)
     @q = q
     @id = id
     @body = body
   end

   def fail(e)
     MsgQ.fail(@q, @id, e)
   end

   def delete
     MsgQ.delete(@q, @id)
   end
 end

 def self.enqueue(q, data)
   @mq.sadd("q", q)
   mid = @mq.incr("mid")
   @mq.multi do
     @mq.setex("m:#{mid}", MSG_TTL, data)
     @mq.lpush("q:#{q}", mid)
   end
   return mid
 end

 def self.dequeue(q)
   mid = @mq.brpoplpush("q:#{q}", "p:#{q}", BLOCK_TIMEOUT)
   if mid.nil?
     return
   end
   body = @mq.get("m:#{mid}")
   if body.nil?
     return
   end

   return Msg.new(q, mid, body)
 end

 def self.delete(q, mid)
   @mq.multi do
     @mq.lrem("p:#{q}", 1, mid)
     @mq.del("m:#{mid}")
     @mq.del("error:#{mid}")
   end
 end

 def self.fail(q, mid, e)
   @mq.multi do
     @mq.lrem("p:#{q}", 1, mid)
     @mq.lpush("f:#{q}", mid)
     if e
       err_trace = "#{e.inspect}\n#{e.backtrace.join("\n")}"
       @mq.setex("error:#{mid}", MSG_TTL, err_trace)
     else
       @mq.del("error:#{mid}")
     end
   end
 end

 def self.retry(q, mid)
   @mq.multi do
     @mq.lrem("f:#{q}", 1, mid)
     @mq.lpush("q:#{q}", mid)
   end
 end

 def self.get_error(mid)
   @mq.get("error:#{mid}")
 end

 def self.is_empty(q)
   arr = @mq.multi do
     @mq.llen("p:#{q}")
     @mq.llen("q:#{q}")
   end
   return (arr[0] + arr[1]) == 0
 end

 def self.clear(q)
   @mq.multi do
     @mq.srem("q", q)
     @mq.del("q:#{q}")
     @mq.del("p:#{q}")
     @mq.del("f:#{q}")
   end
 end

 def self.new_progress_tracker
   prog_id = @mq.incr("progress:")
   set_progress(prog_id, 0)
   return prog_id
 end

 def self.new_progress_message_tracker
   prog_id = @mq.incr("progress_message:")
   set_message_progress(prog_id, 0, "initial errors", 0)
   return prog_id
 end

 def self.get_progress(prog_id)
   n = @mq.get("progress:#{prog_id}")
   if n.nil?
     return nil
   end
   return n.to_i
 end

 def self.get_progress_message(prog_id)
   begin
     n = JSON.parse(@mq.get("progress_message:#{prog_id}"))
   rescue JSON::ParserError
     return { :progress => @mq.get("progress_message:#{prog_id}"), :message => "parse error" }
   end
   if n.nil?
     return { :progress => 0, :message => "" }
   end
   return n
 end

 def self.set_progress(prog_id, progress)
   @mq.setex("progress:#{prog_id}", MSG_TTL, progress)
 end

 def self.set_message_progress(prog_id, progress, message, idx)
   msg = {}
   msg[:message] = message
   msg[:progress] = progress
   msg[:index] = idx
   @mq.setex("progress_message:#{prog_id}", MSG_TTL, msg.to_json)
 end

 def self.delete_progress_tracker(prog_id)
   @mq.del("progress:#{prog_id}")
 end

 def self.new_status_tracker
   tracker_id = @mq.incr("status_tracker:")
   set_status_tracker(tracker_id, :started, 0.0)
   return tracker_id
 end

 def self.set_status_tracker(tracker_id, status=nil, progress=nil)
   return false if status.nil? && progress.nil?
   original = get_status_tracker(tracker_id)
   msg = {}
   msg[:status] = status || original[:status]
   msg[:progress] = progress || original[:progress]
   @mq.setex("status_tracker:#{ tracker_id }", MSG_TTL, msg.to_json)
 end

 def self.get_status_tracker(tracker_id)
   msg = @mq.get("status_tracker:#{ tracker_id }")
   return nil if msg.blank?
   response = JSON.parse(msg).deep_symbolize_keys!
   response[:status] = response[:status].to_sym
   response
 end

 def self.flush_db(flag=false)
   @mq.flushdb if flag
 end

end