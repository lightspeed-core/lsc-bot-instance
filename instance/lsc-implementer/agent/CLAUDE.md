# LSC Implementer — CVE Remediation Instance

## Focus

This instance picks up Vulnerability tickets from the LCORE Jira board and implements fixes across Lightspeed Core Python repositories.

## Jira

- Project: **LCORE**
- Board: **LSC Sprint** (scrum, ID 6914)
- Ticket type: primarily `Vulnerability`
- Labels on CVE tickets: `Security`, `SecurityTracking`, `CVE-*`, `pscomponent:lightspeed-core/<image>`

### pscomponent → repo mapping

CVE tickets have a `pscomponent:lightspeed-core/<image>` label identifying the affected container image. Map to source repos:

| pscomponent image | Source repo |
|---|---|
| `lightspeed-stack-rhel9` | `lightspeed-core/lightspeed-stack` |
| `rag-tool-cpu-rhel9` | `lightspeed-core/rag-content` |
| `rag-tool-cuda-*-rhel9` | `lightspeed-core/rag-content` |
| `rag-tool-rhel9` | `lightspeed-core/rag-content` |

Other images → check Dockerfiles in the matching repos. When unsure, search across all repos for the vulnerable dependency.

## Tech Stack

All repos are **Python**.

- Package manager: `pip` with `requirements.txt` / `Pipfile` / `pyproject.toml`
- Linting/formatting: check each repo for `ruff`, `black`, `flake8`, `mypy` config
- Testing: `pytest` (check `Makefile` or `tox.ini` for test commands)
- Virtual environments: use `python -m venv .venv` if needed

### CVE fix pattern

1. Identify the vulnerable package and version from the ticket summary (e.g. "Pillow: Native heap out-of-bounds write")
2. Find which `requirements*.txt` / `Pipfile` / `pyproject.toml` pins or constrains that package
3. **Check RHOAI index for a version that fixes the CVE** before bumping (always CPU; also CUDA for rag-content `rag-tool-*` images):
   ```bash
   pip index versions <package> --index-url https://packages.redhat.com/api/pypi/public-rhai/rhoai/3.4/cpu-ubi9/simple/
   pip index versions <package> --index-url https://packages.redhat.com/api/pypi/public-rhai/rhoai/3.4/cuda12.9-ubi9/simple/
   ```
   Identify the minimum fixed version from the CVE description. From the RHOAI index output, pick the **lowest available version ≥ the minimum fixed version** that is present in all applicable indexes. Use that version in step 4.
   - No version ≥ minimum fixed version in any applicable index → `jira_add_comment` with:
        * which index is missing it
        * request to file an AIPCC ticket (project AIPCC, parent AIPCC-17493, title: `Update <package> in RHOAI 3.4 to <version> for <CVE-ID>`)
        * open an MR on https://gitlab.com/redhat/rhel-ai/rhai/pipeline (DCO sign-off via `git commit -s`, ref pipeline!1262)
        * announce in #forum-aipcc tagging @aipcc-support. 
        Then STOP — move ticket back to New/unassigned once index is updated.

**Only if version is present in all applicable indexes:**
4. Bump to the fixed version (mentioned in the CVE description or check PyPI)
5. Run tests to verify nothing breaks
6. Check if other repos in this org are affected by the same CVE (same `pscomponent` prefix)
