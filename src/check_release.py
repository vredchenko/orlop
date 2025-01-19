import requests
import sys
import os
import re

def get_latest_stable_release(repo_owner: str, repo_name: str, github_token: str = None) -> str:
    """
    Fetch the latest stable release version from a GitHub repository.

    Args:
        repo_owner: Owner of the repository
        repo_name: Name of the repository
        github_token: Optional GitHub token for authenticated requests

    Returns:
        str: Latest stable release version
    """
    headers = {}
    if github_token:
        headers['Authorization'] = f'token {github_token}'

    url = f'https://api.github.com/repos/{repo_owner}/{repo_name}/releases'

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()

        releases = response.json()

        # Filter out pre-releases and draft releases
        stable_releases = [
            release for release in releases
            if not release['prerelease'] and not release['draft']
        ]

        if not stable_releases:
            raise ValueError("No stable releases found")

        # Get the latest release
        latest_release = stable_releases[0]
        version = latest_release['tag_name']

        # Remove 'v' prefix if present
        version = re.sub(r'^v', '', version)
        return version

    except requests.exceptions.RequestException as e:
        raise Exception(f"Failed to fetch releases: {str(e)}")

if __name__ == "__main__":
    # Can be used from command line
    if len(sys.argv) < 3:
        print("Usage: script.py <repo_owner> <repo_name>")
        sys.exit(1)

    repo_owner = sys.argv[1]
    repo_name = sys.argv[2]
    github_token = os.environ.get('GITHUB_TOKEN')

    try:
        version = get_latest_stable_release(repo_owner, repo_name, github_token)
        print(version)
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)