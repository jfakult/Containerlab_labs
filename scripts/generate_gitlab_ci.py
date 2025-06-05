#!/usr/bin/env python3

import os
from pathlib import Path

LABS_DIR = Path("labs")
CI_FILE = Path(".gitlab-ci.yml")

HEADER = """\
stages:
  - validate

.validate_template: &validate_template
  stage: validate
  image: ghcr.io/srl-labs/clab:latest
  tags:
    - containerlab
  script:
    - ./scripts/validate_lab.sh "$LAB_PATH"

"""

def main():
    jobs = []
    for lab in sorted(LABS_DIR.iterdir()):
        if lab.is_dir() and (lab / "topology.yaml").exists():
            job_name = f"validate_{lab.name}"

            job = f"""{job_name}:
  <<: *validate_template
  variables:
    LAB_PATH: {lab}
  rules:
    - changes:
        - {lab}/**
"""
            jobs.append(job)
        else:
            print("Skipping lab " + str(lab) + " because it doesn't have a topology.yaml file")


    with open(CI_FILE, "w") as f:
        f.write(HEADER + "\n".join(jobs))

    print(f"✅ Generated {CI_FILE} with {len(jobs)} jobs.")

if __name__ == "__main__":
    main()