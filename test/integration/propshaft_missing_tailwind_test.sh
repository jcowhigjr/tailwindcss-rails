#!/bin/bash
set -e

# Create a new Rails app with Propshaft and Tailwind
rails new repro_app --skip-javascript --skip-hotwire --css=tailwind --asset-pipeline=propshaft
cd repro_app
bundle add tailwindcss-rails --path=../../
bin/rails tailwindcss:install
bin/rails g scaffold Post title:string
bin/rails db:migrate

# Remove CDN from layout
sed -i.bak '/cdn.tailwindcss.com/d' app/views/layouts/application.html.erb

bin/rails server -d
sleep 5

curl -s http://localhost:3000/posts > page.html
grep "text-xl" page.html || (echo "ERROR: Tailwind .text-xl class missing" && exit 1)

echo "Test passed: .text-xl class found in output."
kill -9 $(cat tmp/pids/server.pid)
