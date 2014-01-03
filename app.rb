require 'yaml'
require 'bundler'
Bundler.require

require './lib/scraper'

module Calendar
  class App < Sinatra::Application
    Scraper.new("http://www.timeanddate.com/holidays/us").save
    set :holidays, YAML::load(File.open('./lib/holidays.yaml'))
    Timezone::Configure.begin {|c| c.username = 'nixsticks'}

    get '/' do
      @holidays = settings.holidays
      erb :index
    end

    get '/birthday' do
      birthday = Time.new(1987, 07, 31).strftime("%b %-d")
      birthday == get_time ? @answer = "YES!" : @answer = "NO."
      erb :answer
    end

    get '/:event' do
      event = params[:event]
      @event = settings.holidays[event.to_s]

      if @event
        @event == get_time ? @answer = "YES!" : @answer = "NO."
        erb :answer
      else
        erb :not_found
      end
    end

    helpers do
      def get_time
        location = request.location
        lat = location.latitude
        long = location.longitude

        timezone = Timezone::Zone.new(:latlon => [lat, long])
        timezone.time(Time.now).strftime("%b %-d")
      end
    end
  end
end