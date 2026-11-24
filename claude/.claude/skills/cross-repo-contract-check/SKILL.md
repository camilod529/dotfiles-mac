---
name: cross-repo-contract-check
description: Check that a change to a payload one repo produces (request body, saved document, event, config) matches what the other repos that consume it actually accept and execute. Use before finishing a change to code that builds a cross-service payload, or when something saves fine but fails or misbehaves later in another service.
---

# Cross-repo contract check

When one repo produces a payload that other repos store, validate or execute, the producer is often the de facto contract: the consumer may store it without real validation or load it with validation off, so a wrong payload saves fine and only fails (or silently misbehaves) downstream. This skill cross-checks a producer-side change against the consumers' source.

It is **read-only** for every repo except the one being changed: report mismatches, don't edit the consumer repos unless the user explicitly asks for that change.

## 0. Locate the repos

Ask the user (or read the workspace's local notes) for the sibling repos and their roles: producer, gateway/API, storage/validation models, executor/worker. Always read the consumers' **source**, never vendored or installed copies (`node_modules`, `.venv/site-packages`, build output): those lag behind.

## 1. Scope the change

From the diff (`git diff` against the merge base, or the files the user names), list every change that affects the payload's shape:

- payload builders and serializers
- request/response types and enums
- constants that are serialized (the value sent, not the UI label)
- API routes and the client calls that hit them

If nothing payload-affecting changed, say so and stop.

## 2. Check each change against its counterpart

For each change, find where the consumer reads it and confirm what must hold:

| Producer change | Check in | What must hold |
| --- | --- | --- |
| New or renamed field | Consumer models/schemas **and** any persistence layer that whitelists fields | The field exists in every layer, or it is silently dropped on save. |
| Enum or discriminator value | Consumer enum + the code that branches on it | The value is in the enum and every branch handles it. |
| Value format (dates, booleans, numbers, ids) | Consumer validators/converters | The value converts cleanly (e.g. ISO dates, real booleans vs. `"true"`). |
| Optional vs. required keys | Consumer model defaults and validation rules | Required keys are always sent; omitted keys have a default. |
| Pointers/references between items | The consumer code that follows them | Names and id formats match what the consumer resolves. |
| New or changed endpoint | Gateway config → route definition → handler → request model | Path, method and body match the handler's request model. |

Open the actual code for every row that applies, and quote the line that confirms or contradicts the producer.

## 3. Report

Output a short table: change · counterpart `file:line` · ✅ matches / ❌ mismatch / ⚠️ unverifiable. For each ❌, state the concrete failure (e.g. "field dropped on save", "executor raises on invalid boolean"), and whether the fix belongs in the producer or needs a consumer change. A consumer change goes back to the user to raise with that team; don't edit that repo. Say when only an end-to-end run (an API collection, a staging execution) can confirm a row.
