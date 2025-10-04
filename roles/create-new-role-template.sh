#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# create-ansible-role.sh
# Create a minimal Ansible role skeleton.
#
# Features:
# - Creates the role in the CURRENT directory (.) (no "roles/" subfolder)
# - Directories: tasks, handlers, defaults, files, templates
# - Optional: Molecule default scenario (--molecule)
# - Idempotent: existing files are not overwritten (unless --force is used)
# - NO Git init, NO LICENSE file, NO {tests, module_utils, meta,
#   lookup_plugins, library, docs, vars}
# - IMPORTANT: Role names containing a dot (e.g. "my.test") will NOT be split
#   into subfolders, the target folder will be "./my.test"
# - tasks/main.yml and defaults/main.yml will be EMPTY
# - .gitkeep files will be created in files/ and templates/
# =============================================================================

VERSION="2.4.0"

# Defaults
ROLE_NAME=""
BASE_DIR="."                # always current directory as default
DESCRIPTION="Ansible role created via script."
WITH_MOLECULE=false
FORCE=false
COLLECTION_NAMESPACE=""
COLLECTION_NAME=""

usage() {
  cat <<EOF
Usage:
  $(basename "$0") -n ROLENAME [options]

Required:
  -n, --name NAME            Role name (e.g. my.test or nginx)

Options:
  -p, --path PATH            Target base path (default: .)
  -d, --description TEXT     Description
      --collection NAMESPACE.COLLECTION
                             (e.g. myco.base). Creates the role under:
                             collections/ansible_collections/NAMESPACE/COLLECTION/roles/NAME
      --molecule             Add Molecule default scenario
      --force                Overwrite existing files
  -v, --version              Show version
  -h, --help                 Show help

Examples:
  $(basename "$0") -n nginx
  $(basename "$0") -n my.test --molecule -d "Install Nginx"
  $(basename "$0") -n bind --collection myco.base -p .
EOF
}

die() { echo "Error: $*" >&2; exit 1; }

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--name) ROLE_NAME="${2:-}"; shift 2 ;;
      -p|--path) BASE_DIR="${2:-}"; shift 2 ;;
      -d|--description) DESCRIPTION="${2:-}"; shift 2 ;;
      --collection)
        IFS='.' read -r COLLECTION_NAMESPACE COLLECTION_NAME <<< "${2:-}"
        [[ -n "$COLLECTION_NAMESPACE" && -n "$COLLECTION_NAME" ]] || die "--collection requires NAMESPACE.COLLECTION"
        shift 2 ;;
      --molecule) WITH_MOLECULE=true; shift ;;
      --force) FORCE=true; shift ;;
      -v|--version) echo "$(basename "$0") v$VERSION"; exit 0 ;;
      -h|--help) usage; exit 0 ;;
      *) die "Unknown option: $1 (use --help)";;
    esac
  done

  [[ -n "$ROLE_NAME" ]] || die "Role name is required (option -n)."
}

mkd() { mkdir -p "$1"; }

write_file() {
  local path="$1"
  local content="${2-}"
  if [[ -e "$path" && $FORCE == false ]]; then
    echo "⚠️  already exists, skipping: $path"
    return 0
  fi
  printf "%s" "$content" > "$path"
  echo "✅ created: $path"
}

create_role() {
  parse_args "$@"

  # Determine role path (Collection vs. classic). DO NOT split on dots!
  local role_dir
  if [[ -n "$COLLECTION_NAMESPACE" && -n "$COLLECTION_NAME" ]]; then
    local base="collections/ansible_collections/${COLLECTION_NAMESPACE}/${COLLECTION_NAME}/roles"
    [[ -n "$BASE_DIR" && "$BASE_DIR" != "." ]] && base="${BASE_DIR%/}/$base"
    role_dir="${base}/${ROLE_NAME}"
  else
    role_dir="${BASE_DIR%/}/${ROLE_NAME}"
  fi

  echo "📁 Target directory: $role_dir"
  mkd "$role_dir"

  # Minimal directories
  for d in tasks handlers defaults files templates; do
    mkd "$role_dir/$d"
  done

  # .gitkeep for files and templates
  write_file "$role_dir/files/.gitkeep" ""
  write_file "$role_dir/templates/.gitkeep" ""

  # README
  write_file "$role_dir/README.md" "# Role: ${ROLE_NAME}

${DESCRIPTION}

## Requirements
- Tested on Debian/Ubuntu (adjust as needed)

## Role Variables
See \`defaults/main.yml\`.

## Dependencies
- none

## Example Playbook
\`\`\`yaml
- hosts: all
  roles:
    - role: ${ROLE_NAME}
\`\`\`
"

  # tasks/main.yml (empty)
  write_file "$role_dir/tasks/main.yml" ""

  # handlers/main.yml
  write_file "$role_dir/handlers/main.yml" "---
# handlers/main.yml
# Handlers for service restarts, etc.

# - name: restart myservice
#   ansible.builtin.service:
#     name: myservice
#     state: restarted
"

  # defaults/main.yml (empty)
  write_file "$role_dir/defaults/main.yml" ""

  # Molecule (optional)
  if $WITH_MOLECULE; then
    mkd "$role_dir/molecule/default"
    write_file "$role_dir/molecule/default/molecule.yml" "---
dependency:
  name: galaxy
driver:
  name: docker
lint: |
  ansible-lint .
platforms:
  - name: instance
    image: docker.io/geerlingguy/docker-debian12-ansible:latest
    privileged: true
    command: /lib/systemd/systemd
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
provisioner:
  name: ansible
  playbooks:
    converge: converge.yml
verifier:
  name: ansible
"
    write_file "$role_dir/molecule/default/converge.yml" "---
- name: Converge
  hosts: all
  roles:
    - role: ${ROLE_NAME}
"
    write_file "$role_dir/molecule/default/verify.yml" "---
- name: Verify
  hosts: all
  tasks:
    - name: Example assertion
      ansible.builtin.assert:
        that:
          - true
"
  fi

  echo "🎉 Done! Role created at: $role_dir"
}

create_role "$@"
