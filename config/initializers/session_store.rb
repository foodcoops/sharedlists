# Be sure to restart your server when you modify this file.

SharedLists::Application.config.session_store :cookie_store, key: '_sharedLists_session', secure: true, path: ENV['RAILS_RELATIVE_URL_ROOT'] || '/'
