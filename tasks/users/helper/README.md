<!--
##############################################################################
# Helper Tasks Directory Documentation
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.1
# Date: February 28, 2026
##############################################################################
-->

# Helper Tasks Directory

This directory contains **internal helper tasks** that are called
by public tasks in the parent `tasks/users/` directory. These tasks
should **NOT be called directly** from playbooks or roles.

## Purpose

Helper tasks provide reusable sub-functionality for public tasks,
keeping the main task files clean and focused. They handle specific
operations within a larger workflow.

## Usage Guidelines

### DO

- Call helpers via `include_tasks` from public tasks in parent
  directory
- Use helpers to break complex tasks into manageable pieces
- Use descriptive names that explain the helper's function

### DO NOT

- Call helpers directly from playbooks or roles
- Reference helpers from outside the `tasks/users/` directory
- Use helpers as standalone tasks

## Naming Convention

- **No special prefix needed** (directory name indicates internal
  use)
- Use descriptive camelCase names: `createSingleUser.yaml`, etc.
- Follow same documentation standards as public tasks

## Current Helpers

| Helper                  | Purpose                                              | Called By                       |
|-------------------------|------------------------------------------------------|---------------------------------|
| `loadUserData.yaml`     | Loads one user's vault data and accumulates into map | `postCreate-pb.yaml` (Play 1)   |

## Adding New Helpers

1. Create task file in this directory
2. Follow standard task documentation format
3. Mark as "Internal helper" in USAGE section
4. Update this README with new helper details
5. Reference from parent public task only
