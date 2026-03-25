from pathlib import Path


EXECUTION_PROFILE = "{{ cookiecutter.execution_profile }}"


def remove_if_present(relative_path: str) -> None:
    path = Path(relative_path)
    if path.exists():
        path.unlink()


if EXECUTION_PROFILE == "hosted":
    for relative_path in (
        ".github/comparevi/docker-lane-policy.json",
        ".github/comparevi/Emit-DockerProfileReceipt.ps1",
        ".github/workflows/docker-profile.yml",
        "docs/DOCKER_PROFILE.md",
    ):
        remove_if_present(relative_path)
