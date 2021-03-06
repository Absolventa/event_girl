# configure me in config/config.yml
config_file = File.join(Rails.root, 'config', 'config.yml')

env_config  = if File.exists? config_file
                erb_config = ERB.new(File.read(config_file)).result
                (YAML.load(erb_config)[Rails.env] rescue {}).symbolize_keys
              else
                {
                  host:       ENV['EREIGNISHORIZONT_HOST']       || 'ereignishorizont.example.com',
                  url_scheme: ENV['EREIGNISHORIZONT_URL_SCHEME'] || 'http',
                  mail_from:  ENV['EREIGNISHORIZONT_MAIL_FROM']  || 'ereignishorizont@example.com'
                }
              end
APP_CONFIG = env_config.freeze

if Rails.env.production? or Rails.env.staging?
  ActionMailer::Base.smtp_settings = {
    address:        'smtp.sendgrid.net',
    port:           '587',
    authentication: :plain,
    user_name:      ENV['SENDGRID_USERNAME'],
    password:       ENV['SENDGRID_PASSWORD'],
    domain:         'heroku.com'
  }
  ActionMailer::Base.delivery_method = :smtp

  Ereignishorizont::Application.configure do
    config.force_ssl = APP_CONFIG[:url_scheme] == 'https'
  end

elsif Rails.env.development?
  ActionMailer::Base.delivery_method = :sendmail
  #Mail.register_interceptor(MailInterceptor)
end
