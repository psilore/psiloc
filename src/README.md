# Setup Client Development

This directory contains the Go source code for the `setup-client` application, which replaces the legacy bash setup menu with a robust, zero-dependency Go CLI tool.

## Local Development

To build and test the application locally, run the following commands from the repository root:

```bash
# Change to the src directory
cd src

# Build the executable (places it in the root directory)
go build -o ../setup-client main.go

# Run the executable
cd ..
./setup-client
```

## CI/CD and GitHub Flow

This project uses standard [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow) combined with automated Actions for CI/CD.

### 1. Branching & Pull Requests
When making changes:
1. Create a new branch off of `main` (e.g., `feature/new-installer`).
2. Make your code changes in the `src/` directory.
3. Use **Semantic Commit Messages** (e.g., `feat: add docker installer`, `fix: correct typo in bash invocation`). This is critical for the automated release process. See [docs/CONTRIBUTING.md](../docs/CONTRIBUTING.md) for full details on **Conventional Commits**.
4. Open a Pull Request (PR) against the `main` branch.

### 2. Automated Security Scan & Dev Deployment (`ci-cd.yml`)
When a PR is merged into `main` (or code is pushed directly), the **CI/CD Security and Deploy** workflow is automatically triggered:
- **Security**: The code is scanned using `gosec` to identify any Go-specific vulnerabilities.
- **Build**: The `setup-client` is compiled.
- **Dev Deploy**: The compiled binary is uploaded as a GitHub Actions Artifact (`setup-client-dev-binary`). You can download this artifact directly from the Actions run summary page to verify the dev build.

### 3. Creating a Release (`release-please.yml`)
Releases are managed via **Release Please**, which accumulates your merged features and bug fixes into a centralized **Release PR**.

To cut a new release:
1. As you merge feature branches (following Conventional Commits) into `main`, the `release-please` bot will automatically create or update a single Release PR (e.g., `chore(main): release 1.1.0`).
2. This PR acts as a staging area, showing exactly what is going into the next release, complete with a generated `CHANGELOG.md`.
3. When the team is ready to publish the release, simply **merge the Release PR**.
4. The bot will detect the merge, create the Git tag, and publish the official GitHub Release automatically.
