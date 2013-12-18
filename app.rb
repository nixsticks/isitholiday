require 'yaml'
require 'bundler'
Bundler.require

module Calendar
  class App < Sinatra::Application
    set :today, Time.now.strftime("%b %-d")
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

    get '/:event' do
      event = params[:event]
      @event = settings.holidays[event.to_s]
      if @event
        @event == settings.today ? @answer = "YES!" : @answer = "NO."
        erb :answer
      else
        erb :not_found
      end
    end
  end
end