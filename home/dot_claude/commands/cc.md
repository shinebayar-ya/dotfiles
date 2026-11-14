---
description: Help card for cc-* commands (iplan, oq, impl, wiki, sniff, what, todo, kit). Prints the table, nothing else.
allowed-tools:
---

Print this table as-is. No tools, no extra text.

| Command | Folder | Хэзээ хэрэглэх | Жишээ |
|---|---|---|---|
| `/iplan` | `cc-plans` | Код бичихээс өмнө төлөвлөгөө | `/iplan whitelist bulk insert --review` |
| `/oq` | — | `/iplan`-ы Open questions-г санал болгож хамт хаах | `/oq` |
| `/impl` | — | `/iplan`-аар гарсан plan-г шууд хэрэгжүүлэх | `/impl cc-plans/contract/20261012-3-termination.md` |
| `/wiki` | `cc-docs` | Удаан хүчинтэй лавлах: design, cron, deploy, status code | `/wiki autopay cron` |
| `/sniff` | `cc-reports` | Шалгаж олсон зүйл: review, audit, debug | `/sniff MR !967 settlement` |
| `/what` | `cc-notes` | "Энэ юу вэ" тайлбар (Mongolian) | `/what idempotency key` |
| `/todo` | `cc-tasks` | Хийх зүйлийн checklist | `/todo autopay rollout` |
| `/kit` | `cc-data` | Sample data, payload, one-off `.sql` | `/kit whitelist insert sql` |

Сонгох дүрэм:
- Өөрчлөгдөж, шинэчлэгдэх зүйл → `/wiki`. Нэг удаагийн дүгнэлт → `/sniff`.
- Код бичихийн өмнө → `/iplan`, дараа нь `/oq`. Хэрэгжүүлэх → `/impl <plan.md>`. Дараа нь үлдсэн ажил → `/todo`.
- Өгөгдөл, query → `/kit`. Түүнийг тайлбарласан бичиг → `/wiki`.

Бүгд `cc-<type>/<topic>/YYYYMMDD-N-slug.<ext>` руу бичнэ.
Дүрэм: `~/.claude/CLAUDE.md` → "Claude-generated files (cc-*)"
