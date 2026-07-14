# Icon update automation

Spec and plan for keeping `lucide_icons` in lockstep with upstream `lucide-static` with zero manual steps.

## Goal

When a new `lucide-static` release ships, the package should regenerate its icon set, bump its version, update the changelog, tag the release, and (optionally) publish — without a human running commands, and without a human merge unless a guardrail trips.

## What each release actually changes

Measured on the `1.17.0 → 1.24.0` bump:

- **Codepoints are stable.** Existing icons keep their `IconData(0x…)` value; new icons get appended codepoints. Verified: 0 of 1,958 shared icons shifted.
  This is why the changelog logic below (naive `+`/`-` line extraction) is correct — only genuinely new/removed icon lines appear in the diff.
- **New icons only** in this bump: 33 added, 0 removed (1,958 → 1,991).
- **Inline SVG previews always churn.** Each icon's dartdoc embeds a base64 SVG whose comment carries the version string (`<!-- @license lucide-static vX.Y.Z -->`), so every icon's data URI changes on every bump (~4k lines). This is inherent to `--inline-svg` and is not data loss.
- **The upstream CSS format can change shape** (1.17→1.24 rewrote it, hence the large one-off `assets/lucide.css` diff). Future bumps are usually small.

## Current pipeline

| Component                            | Trigger                                         | Status                                                  |
| ------------------------------------ | ----------------------------------------------- | ------------------------------------------------------- |
| `.github/dependabot.yml`             | daily                                           | Detects new `lucide-static`, opens a notification PR    |
| `.github/workflows/update-icons.yml` | `workflow_dispatch`                             | Regenerates, bumps version, updates changelog, opens PR |
| `tool/update_icons.sh`               | called by the workflow and `merry update-icons` | Single source of the regeneration steps                 |
| `.github/workflows/tag-release.yml`  | push to `main` touching `pubspec.yaml`          | Creates `vX.Y.Z` tag                                    |

The pipeline is ~90% there. Two gaps block "fully automated".

## Gaps

1. **Regeneration is manual.** `update-icons.yml` is `workflow_dispatch` only, so a human must click "Run workflow" after seeing the Dependabot PR.
2. **`README.md` version pin drifts.** The install snippet pins a `ref: vX.Y.Z` git tag; neither `update-icons.yml` nor `update_icons.sh` touches it, so every automated PR would ship a stale README. Sync it in the same step that bumps `pubspec.yaml`.
3. **The generator output was not formatted.** `tool/update_icons.sh` ran the generator but not `dart format`; the raw output is single-line and violates `analysis_options.yaml` `page_width: 80`.
   Left unformatted, the committed-vs- committed diff is all-lines-changed, which _also_ breaks the changelog's `+`/`-` extraction (it would list every icon as added).
   **Fixed** — step 4 (`dart format lib/lucide_icons_lite.dart`) added to `update_icons.sh`, so both `merry` and CI now produce identical, formatted output.

## Proposed design (full automation)

Close gap 1 by giving `update-icons.yml` its own schedule; the workflow already self-checks `npm view lucide-static version` against `pubspec.yaml`, so a daily run is idempotent and no-ops when already current.

```yaml
on:
  workflow_dispatch:
  schedule:
    - cron: "0 6 * * *" # daily 06:00 UTC; adjust to taste
```

This alone makes the pipeline hands-off up to the PR.
Dependabot then becomes redundant as a _trigger_ but is still useful as a human-visible changelog of upstream releases — keep it or drop it; the schedule does not depend on it.

### Optional: auto-merge with guardrails

To remove the final human merge, add gates and let the bot merge only when they all pass.
Recommended gates, cheapest first:

1. `flutter analyze` — already in the workflow.
2. `flutter test` — **add it.** Today the workflow does not run tests.
3. A **removal guard**: fail (and require human review) if any icon constant disappeared.
   Removals are the only genuinely breaking change for downstream users; additions never are.

Sketch of the removal guard (runs against the regenerated file before commit):

```bash
removed="$(git diff -- lib/lucide_icons_lite.dart \
  | grep -E '^-[[:space:]]+static const IconData' \
  | sed -E 's/.*IconData[[:space:]]+([A-Za-z0-9]+).*/\1/' | sort -u)"
if [ -n "$removed" ]; then
  echo "::warning::Icons removed upstream — needs human review:"; echo "$removed"
  echo "auto_merge=false" >> "$GITHUB_OUTPUT"
else
  echo "auto_merge=true" >> "$GITHUB_OUTPUT"
fi
```

Then enable auto-merge on the created PR only when `auto_merge == true` (`peter-evans/create-pull-request` + `peter-evans/enable-pull-request-automerge`, or `gh pr merge --auto --squash`). Branch protection with the two checks required keeps the merge honest.

`tag-release.yml` already tags on merge, so tagging stays automatic.

### Optional: shrink the review diff

The embedded `v1.24.0` license comment in every inline SVG churns ~4k base64 lines per bump, which makes the human-review step (the recommended "Now" phase) effectively unreadable and quietly pushes toward auto-merge sooner.
Stripping the `<!-- @license … -->` comment from the SVG in `tool/generate_fonts.dart` would collapse the diff to just the genuinely new icons.
Optional; don't build unless the noisy PRs become a problem.

### Optional: publish to pub.dev

If the package is meant to be published, add a release job that runs `dart pub publish --force` gated on the new tag, using pub.dev's GitHub Actions OIDC automated publishing (no long-lived token).
Keep this **separate** from the regeneration workflow so a publish failure never blocks icon updates.

## Recommendation

- **Now (low risk, high value):** add the `schedule` trigger. Ship it; the PR is still human-merged, so there is a review gate and near-zero downside.
- **Next (if the PRs prove boring):** add `flutter test` + the removal guard, then turn on auto-merge for addition-only bumps. Removals still stop for a human.
- **Only if publishing:** add the OIDC publish job last.

Do not build a bespoke version-diffing service, a scheduled Dart script, or a custom bot — the existing workflow + one cron line + standard marketplace actions cover every requirement.

## Implementation checklist

1. Add `schedule:` cron to `update-icons.yml` → verify a manual `workflow_dispatch` still opens a correct PR.
2. Sync the `README.md` `ref: vX.Y.Z` pin in the version-bump step (`sed` on the snippet), so automated PRs don't drift.
3. Add `flutter test` step after `flutter analyze`.
4. Add the removal-guard step; wire its output to a conditional auto-merge step.
   The guard also fails safe if upstream ever breaks codepoint stability: a shift surfaces existing names on `-` lines, which blocks auto-merge for human review.
5. Configure branch protection: require `analyze` + `test` on `chore/lucide-static-*`.
6. (If publishing) add an OIDC `dart pub publish` job triggered by the new tag.

## Open decisions

- Cron frequency (daily vs weekly) — upstream ships often; daily keeps drift small.
- Auto-merge yes/no, and whether removals should hard-fail or just skip auto-merge.
- Keep Dependabot as a redundant notifier, or drop it once the schedule lands.
- Is pub.dev publishing in scope at all? (Package currently consumed as a git dep.)
