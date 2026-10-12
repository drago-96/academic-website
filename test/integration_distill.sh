#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
tmp_override="${tmp_dir}/distill-override.yml"
tmp_site="${tmp_dir}/site"
fixture_dir="$(mktemp -d integration-distill-XXXXXX)"

cleanup() {
  rm -rf "${fixture_dir}"
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

cat >"${fixture_dir}/distill.md" <<'MARKDOWN'
---
layout: distill
title: Distill integration fixture
description: A temporary page for testing the Distill runtime.
date: 2021-01-01
permalink: /test/distill/
giscus_comments: true
mermaid:
  enabled: true
tikzjax: true
---

Distill integration fixture.
MARKDOWN

cat >"${tmp_override}" <<'YAML'
giscus:
  repo: alshedivat/al-folio
  repo_id: R_kgDOExample
  category: Comments
  category_id: DIC_kwDOExample
YAML

bundle exec jekyll build --config "_config.yml,${tmp_override}" -d "${tmp_site}" >/dev/null

distill_page="${tmp_site}/test/distill/index.html"

if [ ! -f "${distill_page}" ]; then
  echo "distill page was not generated at ${distill_page}" >&2
  exit 1
fi

grep -q 'd-front-matter' "${distill_page}"
grep -q '/assets/js/distillpub/template.v2.js' "${distill_page}"
grep -q '/assets/js/distillpub/transforms.v2.js' "${distill_page}"
grep -q '/assets/js/distillpub/overrides.js' "${distill_page}"
grep -q '/assets/al_charts/js/mermaid-setup.js' "${distill_page}"
grep -q 'https://cdn.jsdelivr.net/npm/@planktimerr/tikzjax@1.0.8/dist/fonts.css' "${distill_page}"
grep -q 'https://cdn.jsdelivr.net/npm/@planktimerr/tikzjax@1.0.8/dist/tikzjax.js' "${distill_page}"
grep -q 'id="giscus_thread"' "${distill_page}"
transforms_runtime="${tmp_site}/assets/js/distillpub/transforms.v2.js"
distill_gem_root="$(bundle exec ruby -e 'spec = Gem.loaded_specs["al_folio_distill"]; puts spec.full_gem_path if spec')"
distill_runtime="${distill_gem_root}/assets/js/distillpub/transforms.v2.js"
if [ -f "${distill_runtime}" ]; then
  # Prefer the packaged gem runtime for deterministic parity checks.
  transforms_runtime="${distill_runtime}"
elif [ ! -f "${transforms_runtime}" ]; then
  echo "distill transforms runtime missing at ${transforms_runtime} (and not found in installed al_folio_distill gem)" >&2
  exit 1
fi

expected_transforms_hash="$(ruby -rjson -e 'print JSON.parse(File.read(ARGV[0])).fetch("assets").fetch("transforms.v2.js")' "${distill_gem_root}/assets/js/distillpub/provenance.json")"
actual_transforms_hash="$(ruby -rdigest -e 'print Digest::SHA256.file(ARGV[0]).hexdigest' "${transforms_runtime}")"
if [ "${actual_transforms_hash}" != "${expected_transforms_hash}" ]; then
  echo "unexpected distill transforms runtime hash: ${actual_transforms_hash}" >&2
  exit 1
fi

echo "distill integration checks passed"
