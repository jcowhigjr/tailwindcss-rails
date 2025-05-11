# Reproduction Steps: Propshaft + tailwindcss-rails Missing Tailwind CSS in Browser

---

## Why this script is needed (compared to user_install_test.sh)

My reproduction steps and test script are similar to `test/integration/user_install_test.sh`, but specifically target the Propshaft pipeline and explicitly remove any CDN fallback. This is important because:

- The default install test may use Sprockets, which does not always trigger the bug.
- My script ensures the CDN is not present, so any missing Tailwind CSS utilities are not masked by the CDN.
- It checks for both standard and custom Tailwind classes in the output.
- This approach matches real-world user setups and failures, and is more likely to catch asset pipeline or manifest issues that only appear with Propshaft.

Please see the included `propshaft_missing_tailwind_test.sh` for a step-by-step guide and a runnable test script.

---

This document describes the steps taken to reproduce the issue where Tailwind CSS utility classes are missing in the browser when using `tailwindcss-rails` with Propshaft and no CDN fallback. This can be submitted as part of a bug report or PR.

---

## Environment
- Rails 7.x
- tailwindcss-rails 4.2.3
- tailwindcss-ruby 4.1.5
- Propshaft asset pipeline
- No CDN fallback for Tailwind

## Steps to Reproduce

1. **Vendor the Gem**
   - Copy the gem source to your Rails app:
     ```sh
     git clone https://github.com/rails/tailwindcss-rails.git vendor/gems/tailwindcss-rails
     ```
   - Update your `Gemfile`:
     ```ruby
     gem 'tailwindcss-rails', path: 'vendor/gems/tailwindcss-rails'
     ```
   - Run `bundle install`.

2. **Add a Failing Integration Test**
   - In `vendor/gems/tailwindcss-rails/test/integration/`, add `propshaft_missing_tailwind_test.sh`:
     ```bash
     #!/bin/bash
     set -e
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
     kill -9 $(cat tmp/pids/server.pid)
     ```
   - Make script executable: `chmod +x propshaft_missing_tailwind_test.sh`

3. **Run the Test Script**
   - From the gem root:
     ```sh
     cd test/integration
     ./propshaft_missing_tailwind_test.sh
     ```
   - The script should fail with `ERROR: Tailwind .text-xl class missing` if the bug is present.

4. **Document Results**
   - If the script fails, this confirms the bug. If it passes, the bug may be environment-specific.

---

## Notes
- This test mimics a real Rails app using Propshaft, with no CDN fallback, and verifies that standard Tailwind utility classes are delivered to the browser.
- If the Tailwind CSS is missing, it is a strong reproducible case for maintainers.
- For further debugging, check the input file path, asset pipeline configuration, and ensure the Tailwind directives are present in `application.css`.

---

*Generated as part of a bug report for tailwindcss-rails Propshaft integration.*
