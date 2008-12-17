class Host
  attr_accessor :scheme, :host, :port, :path
  # Host.new(url)
  # Host.new(scheme, host, port, path)
  def initialize *args
    if args.size == 1
      require 'uri'
      uri = URI.parse(args[0])
      @scheme = uri.scheme
      @host = uri.host
      @port = uri.port
      @path = uri.path
    else
      @scheme = args[0]
      @host = args[1]
      @port = args[2]
      @path = args[3]
    end
  end
  def to_s
    s = "#{@scheme}://#{@host}"
    s += ":#{@port}" if @port != 0
    s += "#{@path}" if @path
    s
  end
end
