# LSC Groomer — CVE Triage & Ticket Creation Instance

## Focus

This instance gathers CVEs affecting Lightspeed Core components and creates/triages Jira tickets in the LCORE project.

## Status: Skeleton — Workflow TBD

The custom workflow for this instance has not been defined yet. Key open questions:

- How are CVEs discovered? (Dependabot alerts on a dummy repo with requirements.txt, external feed, container scan results?)
- What triggers a grooming cycle? (Scheduled, event-driven, manual?)
- Should it deduplicate against existing LCORE Vulnerability tickets?
- Should it also file tickets in RHOAI Jira? (diagram shows this as optional)
- Should it post to Slack channels? (LCORE channel + RHOAI channel per diagram)

## Architecture (from component diagram)

1. A dummy repository maintains `requirements.txt` files listing all packages used across LSC container images
2. Dependabot runs against this repo and detects CVEs
3. A "File JIRAs script" reads the CVE list and creates LCORE Jira tickets (optionally also RHOAI)
4. Notifications are sent to LCORE and RHOAI Slack channels
5. RHOAI infrastructure handles: package bump → rebuild → refresh package list

## Jira

- Project: **LCORE**
- Board: **LSC Sprint** (scrum, ID 6914)
- Ticket type: `Vulnerability`
