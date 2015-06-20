class Timer < Qt::Object
  slots 'on_timeout()'

  def initialize
    super

    @timer = Qt::Timer.new
    @elapsed_count = 0
  end

  def timer
    @timer
  end

  def on_elapsed(&block)
    @elapsed_callback = block
  end

  def on_timeout
    @elapsed_count = @elapsed_count + 1
    @elapsed_callback.call self
  end

  def start (timeout)
    @start_time = Time.now
    connect(@timer, SIGNAL('timeout()'), self, SLOT('on_timeout()'))
    @timer.start(timeout)
  end

  def elapsed_time
    Time.now - @start_time
  end

  def elapsed_count
    @elapsed_count
  end

  def to_s
    "#{@timer.timerId} elapsed #{@elapsed_count} with total #{elapsed_time}"
  end
end