module Collude
  class Scheduler
    def initialize(post)
      @post = post
    end

    def schedule!
      if existing_job
        existing_job.reschedule(15.seconds.from_now)
        puts "Rescheduling collude job for #{15.seconds.from_now}"
      else
        Jobs.enqueue :collude, post_id: @post.id
      end
    end

    private

    def existing_job
      @existing_job ||= Sidekiq::ScheduledSet.new.detect do |job|
        job.item['class'] == 'Jobs::Collude' && job.args['post_id'] == @post.id
      end
    end
  end
end
