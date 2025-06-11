# Azure Quota and Capacity Management Documentation

This repository contains comprehensive documentation for Azure quota and capacity management, built with Jekyll and the Just the Docs theme for GitHub Pages.

## 🚀 Quick Start

### Local Development

1. Install Ruby (>= 3.2) and Bundler
2. Run:
   ```sh
   bundle install
   bundle exec jekyll serve --livereload
   ```
3. Visit [http://localhost:4000/azcapman/](http://localhost:4000/azcapman/) to preview the site

### GitHub Pages Deployment

This site is configured for automatic deployment to GitHub Pages using the remote theme feature. Push changes to the main branch to trigger deployment.

## Deployment

- The site is automatically built and deployed to GitHub Pages on every push to `main` via GitHub Actions.
- To update the site, edit Markdown files and push changes to `main`.

## Structure

- `index.md` — Home page
- `docs/` — Documentation content
- `_config.yml` — Jekyll/Just the Docs configuration
- `Gemfile` — Ruby dependencies
- `.github/workflows/gh-pages.yml` — GitHub Actions workflow for deployment

For more, see [Just the Docs documentation](https://just-the-docs.github.io/just-the-docs/docs/).