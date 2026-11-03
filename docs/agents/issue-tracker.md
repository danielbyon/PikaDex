# Issue tracker: GitHub

Issues and specs live in GitHub Issues for `danielbyon/PikaDex`. Use the `gh` CLI for issue operations.

## Conventions

- Create an issue with `gh issue create --title "..." --body "..."`. Use a heredoc for a multi-line body.
- Read an issue with `gh issue view <number> --json number,title,body,labels,comments`.
- List issues with `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`, adding `--label` or other filters as needed.
- Create a child issue with `gh issue create --parent <parent> ...`, or link it afterward with `gh issue edit <parent> --add-sub-issue <child>` (GitHub CLI 2.94+). On older versions, use `gh api --method POST repos/<owner>/<repo>/issues/<parent>/sub_issues -F sub_issue_id=<child-db-id>`. If GitHub sub-issues aren't available, put `Part of #<parent>` at the top of the child's body.
- Use GitHub's native issue dependencies to record blockers. Add them with `gh issue create --blocked-by <n>,<n> ...` or `gh issue edit <child> --add-blocked-by <blocker>` (GitHub CLI 2.94+). On older versions, use `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`. The ID must be the blocker's numeric database ID, retrieved with `gh api repos/<owner>/<repo>/issues/<n> --jq .id`; it is not the issue number or `node_id`. If native dependencies aren't available, put `Blocked by: #<n>, #<n>` at the top of the issue body. An issue is unblocked when all its blockers are closed.
- Count open blockers with `gh api repos/<owner>/<repo>/issues/<n> --jq .issue_dependencies_summary.blocked_by`. A result of `0` means the issue can start. `gh issue view <n> --json blockedBy` includes closed blockers, so to count only open ones use `--jq '[.blockedBy.nodes[] | select(.state == "OPEN")] | length'`.
- Comment with `gh issue comment <number> --body "..."`.
- Add or remove labels with `gh issue edit <number> --add-label "..."` or `--remove-label "..."`.
- To close an issue, post an explanation with `gh issue comment <number> --body "..."`, then run `gh issue close <number>`. On an already-closed issue, `gh issue close --comment` drops the comment and still exits successfully.

When run inside this checkout, `gh` infers the repository from its Git remote.

File issues only in `danielbyon/PikaDex`, not in `mattpocock/skills`. Before the first `gh issue create` in a session, verify the target with `gh repo view --json nameWithOwner` to make sure it resolves to this repository.

## Pull requests as a triage surface

**PRs as a request surface: no.** Set this to `yes` only if external pull requests should enter the triage queue.

If enabled, use the corresponding `gh pr` commands:

- Read a PR with `gh pr view <number>`, then read its comments with `gh pr view <number> --comments` and its changes with `gh pr diff <number>`. In a non-interactive terminal, `--comments` prints the comments without the PR body.
- List open external PRs with `gh api --paginate 'repos/{owner}/{repo}/pulls?state=open' --jq '.[] | select(.author_association | IN("OWNER","MEMBER","COLLABORATOR") | not) | {number, title, author: .user.login, author_association, labels: [.labels[].name]}'`.
- Comment, label, or close with `gh pr comment`, `gh pr edit --add-label` / `--remove-label`, and `gh pr close`.

GitHub uses one number space for issues and PRs. To resolve a bare reference such as `#42`, try `gh pr view 42`, then `gh issue view 42` if it isn't a PR.

## Publishing and fetching issues

When a skill says to publish work to the issue tracker, create a GitHub issue. When it asks for a relevant ticket, read it with the command above.

## Wayfinding

`/wayfinder` uses one map issue and child issues as tickets:

- Create the map issue with the `wayfinder:map` label. Its body holds Notes, Decisions-so-far, and Fog.
- Link child tickets as GitHub sub-issues where available. Otherwise, add them to a task list in the map issue and put `Part of #<map>` at the top of each child body. Use `wayfinder:<type>` labels, where the type is `research`, `prototype`, `grilling`, or `task`. Assign a ticket to the driving developer when it is claimed.
- Record blockers using the conventions above.
- To find the next ticket, list the map's open children and skip any with an open blocker or an assignee. Choose the first remaining ticket in map order.
- Claim a ticket with `gh issue edit <n> --add-assignee @me`. This is the first write for that claim.
- Resolve a ticket by commenting with the answer, closing it, then adding a context pointer (gist and link) to the map's Decisions-so-far.
