<!--
##############################################################################
# Helper Tasks Directory Documentation
#
# Copyright 2026 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: October 4, 2026
##############################################################################
-->

# Helper Tasks Directory

This directory contains **internal helper tasks** that are called by
strategy tasks in the parent `tasks/network/configureNetworkStrategies/`
directory. These tasks should
**NOT be called directly** from playbooks or roles.

## Usage Guidelines

### DO:

- ✅ Call helpers via `include_tasks` from strategy tasks in the parent directory
- ✅ Use helpers to run several dependent steps per loop item

### DO NOT:

- ❌ Call helpers directly from playbooks or roles
- ❌ Reference helpers from outside `tasks/network/configureNetworkStrategies/`

## Current Helpers

| Helper | Purpose | Called By |
|--------|---------|-----------|
| `addNetworkManagerAddresses.yaml` | Adds addresses to one interface's NetworkManager profile (creates `lo-aliases` for `lo` if needed) | `networkManager.yaml` |
