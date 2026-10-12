#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
tmp_override="${tmp_dir}/comments-test-override.yml"
tmp_site="${tmp_dir}/site"
fixture_dir="$(mktemp -d integration-comments-XXXXXX)"

cleanup() {
  rm -rf "${fixture_dir}"
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

cat >"${fixture_dir}/giscus.md" <<'MARKDOWN'
---
layout: post
title: Giscus integration fixture
permalink: /test/comments/giscus/
giscus_comments: true
---

Giscus integration fixture.
MARKDOWN

cat >"${fixture_dir}/disqus.md" <<'MARKDOWN'
---
layout: post
title: Disqus integration fixture
permalink: /test/comments/disqus/
disqus_comments: true
---

Disqus integration fixture.
MARKDOWN

cat >"${tmp_override}" <<'YAML'
giscus:
  repo: alshedivat/al-folio
  repo_id: R_kgDOExample
  category: Comments
  category_id: DIC_kwDOExample
disqus_shortname: example
YAML

bundle exec jekyll build --config "_config.yml,${tmp_override}" -d "${tmp_site}" >/dev/null

giscus_page="${tmp_site}/test/comments/giscus/index.html"
disqus_page="${tmp_site}/test/comments/disqus/index.html"

grep -q 'https://giscus.app/client.js' "${giscus_page}"
if grep -q 'giscus comments misconfigured' "${giscus_page}"; then
  echo "unexpected giscus misconfiguration warning in ${giscus_page}" >&2
  exit 1
fi

grep -q 'id="disqus_thread"' "${disqus_page}"
grep -q '.disqus.com/embed.js' "${disqus_page}"

echo "comments integration checks passed"
