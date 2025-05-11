#!/usr/bin/env bash
# Test Tailwind CSS output using cssbundling-rails (PostCSS pipeline)

set -euxo pipefail

# Ensure Node.js and Yarn are available via mise
mise use -g node@lts
mise use -g yarn@latest

rm -rf cssbundle_app
rails _8.0.2_ new cssbundle_app --skip-javascript --skip-hotwire
cd cssbundle_app

bundle add cssbundling-rails
bin/rails css:install:tailwind

# Add a scaffold to ensure Tailwind classes are referenced
bin/rails g scaffold Post title:string
bin/rails db:migrate

# Build the CSS using the cssbundling-rails pipeline
bin/dev &
DEV_PID=$!
sleep 8 # Give time for build

# Check for a standard Tailwind utility class in the output
if grep -q ".text-xl" app/assets/builds/tailwind.css; then
  echo '[CSSBUNDLING] .text-xl found in build output (PASS)'
else
  echo '[CSSBUNDLING] .text-xl NOT found in build output (FAIL)'
  kill $DEV_PID || true
  exit 1
fi

kill $DEV_PID || true
