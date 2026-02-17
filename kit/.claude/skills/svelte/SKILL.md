---
name: svelte
description: >
  Svelte 5 development with runes, snippet blocks, and SvelteKit patterns. Use when writing
  Svelte components, using runes ($state, $props, $derived, $effect), SvelteKit routing,
  form actions, or migrating from Svelte 4. Triggers: Svelte, .svelte files, runes, $state,
  $props, $derived, $effect, SvelteKit, load functions, form actions, snippet blocks.
---

# Svelte 5

Senior Svelte 5 engineer. Runes-first reactivity. See `astro` skill for Svelte islands in Astro projects, `sentry` skill for error tracking in SvelteKit.

## Svelte 5 Runes (Replaces Svelte 4 Reactivity)

| Svelte 4 (Legacy) | Svelte 5 (Current) |
|---|---|
| `export let prop` | `let { prop } = $props()` |
| `$: derived = x + y` | `let derived = $derived(x + y)` |
| `let count = 0` (reactive in component) | `let count = $state(0)` |
| `$: { sideEffect() }` | `$effect(() => { sideEffect() })` |
| `on:click={handler}` | `onclick={handler}` |
| `<slot />` | `{@render children()}` |
| `<slot name="header" />` | `{@render header()}` |

## Key Patterns

```svelte
<script lang="ts">
  // Props with defaults
  let { title, class: className = "" }: { title: string; class?: string } = $props();

  // Reactive state
  let count = $state(0);

  // Derived values
  let doubled = $derived(count * 2);
  let expensive = $derived.by(() => heavyComputation(count));

  // Side effects (runs after DOM update)
  $effect(() => {
    document.title = title;
  });
</script>
```

## Snippet Blocks (Replace Slots)

```svelte
{#snippet row(item)}
  <tr><td>{item.name}</td><td>{item.value}</td></tr>
{/snippet}

<Table data={items} {row} />
```

Components accept snippets as props:

```svelte
<script lang="ts">
  import type { Snippet } from "svelte";
  let { row, children }: { row: Snippet<[Item]>; children: Snippet } = $props();
</script>

{@render children()}
{#each items as item}
  {@render row(item)}
{/each}
```

## SvelteKit Essentials

- **File routing**: `src/routes/blog/[slug]/+page.svelte`
- **Load functions**: `+page.ts` (universal) or `+page.server.ts` (server-only)
- **Form actions**: `+page.server.ts` exports `actions` object, use `enhance` for progressive enhancement
- **Layouts**: `+layout.svelte` wraps child routes

## MUST DO

- Use runes for all reactivity: `$state()`, `$derived()`, `$effect()`, `$props()`
- Use `onclick` (lowercase) for event handlers, not `on:click`
- Use `{@render children()}` instead of `<slot />`
- Type props with destructured `$props()` interface
- Use `$effect` cleanup by returning a function: `$effect(() => { return () => cleanup() })`

## MUST NOT

- Use Svelte 4 `export let` — use `$props()` destructuring
- Use `$:` reactive declarations — use `$derived()` or `$derived.by()`
- Use `on:click` directive syntax — use `onclick` attribute
- Use `<slot>` — use snippet blocks with `{@render}`
- Use `$effect` for derived state — use `$derived()` instead
- Mutate `$state` objects without reassignment for deep reactivity — use `$state.snapshot()` for copies

## References

| Topic | File | Load When |
|-------|------|-----------|
| Coding conventions | [conventions.md](references/conventions.md) | Component patterns, state management, forms, styling, testing |

Docs: <https://svelte.dev/docs>
