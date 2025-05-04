require "rails"

module Tailwindcss
  class Engine < ::Rails::Engine
    initializer "tailwindcss.disable_generator_stylesheets" do
      Rails.application.config.generators.stylesheets = false
    end

    initializer "tailwindcss.exclude_asset_path", before: "propshaft.append_assets_path" do
      if Rails.application.config.assets.excluded_paths # the app may not be using Propshaft
        Rails.application.config.assets.excluded_paths << Rails.root.join("app/assets/tailwind")
      end
    end

    initializer "tailwindcss.include_builds_path" do
      # Include Tailwind CSS build outputs in Rails asset paths
      Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")
    end

    config.app_generators do |g|
      g.template_engine :tailwindcss
    end
  end
end
