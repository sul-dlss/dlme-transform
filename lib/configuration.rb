# frozen_string_literal: true

require 'config'

Config.load_and_set_settings(
  File.join(File.expand_path('..', __dir__), 'settings.yml')
)
