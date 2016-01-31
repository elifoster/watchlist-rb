require 'terminal-notifier'
require 'mediawiki/butt'

class MediaWikiWatchlist
  attr_reader :watchlist
  attr_reader :api_url
  attr_reader :content_url

  def initialize(args = {})
    @api_url = args['api_url']
    @content_url = args['content_url']
    @client = MediaWiki::Butt.new(@api_url)
    @client.login(args['username'], args['password'])
    @last_time = nil
    #   TODO
  end

  def run
    loop do
      @watchlist = @client.get_full_watchlist
      time = Time.now.utc
      unless @last_time.nil?
        rc = @client.get_recent_changes(nil, time, @last_time)
        prev_id = 0
        rc.each do |a|
          if @watchlist.include?(a[:title])
            if prev_id <= a[:rcid]
              TerminalNotifier.notify(a[:comment],
                                      title: 'Watchlist page edited'.freeze,
                                      subtitle: a[:title].freeze,
                                      open: "#{@content_url}/#{a[:title]}".freeze,
                                      sound: 'default'.freeze)
              prev_id = a[:rcid]
            else
              break
            end
          end
        end
      end
      @last_time = time
      sleep(10)
    end
  end
end