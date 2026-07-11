# Examples

The `examples/` directory contains preview, demo, and non-production workloads.

They are **not** automatically deployed by the main ApplicationSets (`apps`, `core`, `operators`).

## Purpose

- Safe place to experiment with new apps or configurations
- Reference implementations (e.g. game servers, whoami, Tailscale examples)
- PR preview environments (via the `apps-preview` ApplicationSet when using the `preview` label)

## Structure

- `examples/apps/` — application examples (e.g. game servers, whoami, Netdata)
- `examples/core/` — core component examples (e.g. Tailscale)

Many examples include `secret-generator.yaml` + `*.enc.yaml` to demonstrate the SOPS + KSOPS pattern.
