require 'yaml'
require 'bundler'
Bundler.require

module Calendar
  class App < Sinatra::Application
    Scraper.new("http://www.timeanddate.com/holidays/us").save if Time.now.strftime("%b %-d") == "Jan 1"
    set :holidays, YAML::load(File.open('./lib/holidays.yaml'))

    get '/' do
      @holidays = settings.holidays
      erb :index
    end

    get '/birthday' do
      @today = get_time

      birthday = Time.new(1987, 07, 31).strftime("%b %-d")
      birthday == @today ? @answer = "YES!" : @answer = "NO."
      erb :answer
    end

    get '/:event' do
      @today = get_time
      event = params[:event]
      @event = settings.holidays[event.to_s]

      if @event
        @event == @today ? @answer = "YES!" : @answer = "NO."
        erb :answer
      else
        erb :not_found
      end
    end

    helpers do
      def get_time
        Timezone::Configure.begin do |c|
          c.username = 'nixsticks'
        end

        location = request.location
        lat = location.latitude
        long = location.longitude

        timezone = Timezone::Zone.new(:latlon => [lat, long])
        timezone.time(Time.now).strftime("%b %-d")
      end
    end
  end
end