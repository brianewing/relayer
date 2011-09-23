class Relayer::Event::Event
  attr_accessor :time
  
  def time!
    @time = Time.now
  end
end