require 'sinatra'
require 'sinatra/flash'
require 'recaptcha'
require 'sendgrid-ruby'
require 'newrelic_rpm'

Recaptcha.configure do |config|
  config.site_key  = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
end

include Recaptcha::ClientHelper
include Recaptcha::Verify
include SendGrid

enable :sessions

set :erb, layout: :layout, format: :html5

get '/' do
  erb :index
end

get '/about_us' do
  @active_tab = 'about_us'
  erb :about_us
end

get '/contact' do
  @active_tab = 'contact'
  erb :contact
end

post '/send_email' do
  if verify_recaptcha
    @from_email = params['email']
    @subject = "BUJIN-RETAIL WEBSITE EMAIL: #{params['subject']}"
    @body = params['body']
    from = Email.new(email: @from_email)
    to = Email.new(email: 'lkhagvatangad@yahoo.com')
    content = Content.new(type: 'text/plain', value: @body)
    mail = Mail.new(from, @subject, to, content)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    if response.status_code != '202'
      flash['alert alert-danger'] = "There was a problem sending your email. Please try again later."
    else
      flash['alert alert-success'] = "Thank you for your email. We will respond as quickly as possible!"
    end
  else
    flash['alert alert-danger'] = "Please verify that you are a human with the Recaptcha widget."
  end

  redirect '/contact'
end
