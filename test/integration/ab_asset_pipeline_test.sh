#!/usr/bin/env bash
# A/B test: Compare Tailwind CSS delivery with Sprockets vs Propshaft asset pipeline in Rails 8
# This script creates two Rails apps (one with Sprockets, one with Propshaft), installs tailwindcss-rails, and checks for Tailwind utility classes in the output.
# Run from a directory outside any existing Rails app (e.g. /tmp)
set -euxo pipefail

# Clean up from previous runs
rm -rf abtest_sprockets abtest_propshaft

# Rails version
RAILS_VERSION="8.0.2"

# Create Sprockets app
rails _${RAILS_VERSION}_ new abtest_sprockets --skip-javascript --skip-hotwire --css=tailwind --asset-pipeline=sprockets
cd abtest_sprockets
bin/rails tailwindcss:install
bin/rails g scaffold Post title:string
bin/rails db:migrate
bin/rails tailwindcss:build
# Check for .text-xl in build output
if grep -q ".text-xl" app/assets/builds/tailwind.css; then
  echo "[SPROCKETS] .text-xl found in build output (PASS)"
else
  echo "[SPROCKETS] .text-xl NOT found in build output (FAIL)" && exit 1
fi
cd ..

# Create Propshaft app
rails _${RAILS_VERSION}_ new abtest_propshaft --skip-javascript --skip-hotwire --css=tailwind --asset-pipeline=propshaft
cd abtest_propshaft
bin/rails tailwindcss:install
bin/rails g scaffold Post title:string
bin/rails db:migrate
bin/rails tailwindcss:build
# Check for .text-xl in build output
if grep -q ".text-xl" app/assets/builds/tailwind.css; then
  echo "[PROPSHAFT] .text-xl found in build output (PASS)"
else
  echo "[PROPSHAFT] .text-xl NOT found in build output (FAIL)" && exit 2
fi
cd ..

echo "A/B asset pipeline test complete."
