# Be sure to restart your server when you modify this file.

Sharedlists::Application.config.session_store :cookie_store, key: '_sharedLists_session', secure: Rails.env.production?, path: ENV['RAILS_RELATIVE_URL_ROOT'] || '/'
