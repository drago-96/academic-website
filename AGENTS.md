# AGENTS.md

Source of the personal website [zanot.to](https://zanot.to), built with Jekyll on the [al-folio](https://github.com/alshedivat/al-folio) v1 starter.

## How the template works

- This repo is a thin starter. Layouts, includes, styles and JavaScript come from versioned gems: `theme: al_folio_core` plus the `al_*` / `al_folio_*` plugins. Don't copy theme files into this repo.
- To change something the gems own, prefer config (`_config.yml`), data (`_data/`) or content. A local override in `_layouts/`, `_includes/` or `_sass/` is possible, but then run `bundle exec al-folio upgrade overrides audit` and commit `.al-folio-overrides.yml`.
- Plugins are listed twice: in `Gemfile` (pinned versions) and in `plugins:` in `_config.yml`. Keep both in sync.
- Keep the v1 config keys (the `al_folio:` block and the `third_party_libraries:` pins); `al-folio upgrade audit` requires them.
- Features are switched on by config flags and page front matter. A disabled feature fails silently: no error, nothing rendered.
- Template documentation is in `docs/` (start from `docs/README.md`; `docs/CUSTOMIZE.md` covers configuration, `docs/TROUBLESHOOTING.md` common problems). It describes the generic template, so check it against this repo (for example, this site has no `baseurl`).

## Commands

```bash
docker compose up -d                 # local preview at http://localhost:8080
npm ci && npm run lint:prettier      # formatting check, also run in CI
npm run lint:style-contract          # checks the repo stays a thin starter (bin/style_contract.js)
bundle exec al-folio upgrade audit   # v1 config check, also run in CI (upgrade-check.yml)
```

- The pre-commit hook (`.githooks/pre-commit`, enabled with `git config core.hooksPath .githooks`) runs Prettier and the style contract.

- Docker builds into the container (`/tmp/_site`), not into the repo's `_site/`, and restarts Jekyll when `_config.yml` changes.
- Pushing to `main` deploys to GitHub Pages via `.github/workflows/deploy.yml`.
- Workflows run on `ubuntu-latest`: pin Ruby by minor version (`"3.3"`), since newer runner images only ship the latest patch release of each series.
