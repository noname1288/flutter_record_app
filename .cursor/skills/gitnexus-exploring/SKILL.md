---
name: gitnexus-exploring
description: "Use when exploring codebase, understanding architecture, tracing execution flows, or learning how code works. Examples: 'How does X work?', 'What calls this function?', 'Show me the auth flow', 'Explain the project structure'"
---

# Exploring Code with GitNexus

## Workflow

```
1. READ gitnexus://repo/{name}/context           → Codebase overview, check staleness
2. gitnexus_query({query: "<concept>"})          → Find related execution flows
3. gitnexus_context({name: "<symbol>"})           → Deep dive on specific symbol
4. READ gitnexus://repo/{name}/process/{name}     → Trace full execution flow
```

If context reports "Index is stale" → run `npx gitnexus analyze` in terminal first.

## Checklist

```
- [ ] READ gitnexus://repo/{name}/context
- [ ] gitnexus_query for the concept you want to understand
- [ ] Review returned processes (execution flows)
- [ ] gitnexus_context on key symbols for callers/callees
- [ ] READ process resource for full execution traces
- [ ] Read source files for implementation details
```

## Tools

**gitnexus_query** — find execution flows related to a concept:

```
gitnexus_query({query: "payment processing"})
→ Processes: CheckoutFlow, RefundFlow, WebhookHandler
→ Symbols grouped by flow with file locations
```

**gitnexus_context** — 360-degree view of a symbol:

```
gitnexus_context({name: "validateUser"})
→ Incoming calls: loginHandler, apiMiddleware
→ Outgoing calls: checkToken, getUserById
→ Processes: LoginFlow (step 2/5), TokenRefresh (step 1/3)
```

## Example: "How does payment processing work?"

```
1. READ gitnexus://repo/my-app/context       → 918 symbols, 45 processes
2. gitnexus_query({query: "payment processing"})
   → CheckoutFlow: processPayment → validateCard → chargeStripe
   → RefundFlow: initiateRefund → calculateRefund → processRefund
3. gitnexus_context({name: "processPayment"})
   → Incoming: checkoutHandler, webhookHandler
   → Outgoing: validateCard, chargeStripe, saveTransaction
4. Read src/payments/processor.ts for implementation details
```
