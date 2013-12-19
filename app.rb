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
      birthday = Time.new(1987, 12, 18).strftime("%b %-d")
      birthday == settings.today ? @answer = "YES!" : @answer = "NO."
      erb :answer
    end

    get '/test' do
      location = request.location
      lat = location.latitude
      long = location.longitude

      Timezone::Configure.begin do |c|
        c.username = 'nixsticks'
      end

      timezone = Timezone::Zone.new :latlon => [lat, long]
      @today = timezone.time(Time.now).strftime("%b %-d")
      erb :test
    end

    get '/:event' do
      location = request.location
      lat = location.latitude
      long = location.longitude

      Timezone::Configure.begin do |c|
        c.username = 'nixsticks'
      end

      timezone = Timezone::Zone.new :latlon => [lat, long]
      @today = timezone.time(Time.now).strftime("%b %-d")

      location = request.location
      event = params[:event]
      @event = settings.holidays[event.to_s]
      if @event
        @event == @today ? @answer = "YES!" : @answer = "NO."
        erb :answer
      else
        erb :not_found
      end
    end
  end
end