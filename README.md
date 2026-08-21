# stock-allocation-fun

A stock allocation solution written in ABAP: it works out who gets the stock
that is genuinely available, records the decision and reserves it in SAP.

Built to install into an existing SAP system with
[abapGit](https://abapgit.org), and developed against
[abaplint](https://abaplint.org) and the
[abaplint transpiler](https://github.com/abaplint/transpiler) so the ABAP Unit
tests run without a SAP system.

## What it does

`ZSTOCK_ALLOCATION` takes a plant and, optionally, a material or an MRP
controller. For each material waiting for stock it

1. checks the user may allocate in the plant (`AUTHORITY-CHECK` on
   `ZSTOCK_ALL`) and locks the material for the run,
2. works out what there is to give away and from when: the book stock from
   `MARD`, restricted to the storage locations that may be allocated and less
   what is not up for allocation — open reservations, stock on deliveries that
   are waiting for their goods issue, the plant's safety stock and batches that
   will not keep long enough to ship — plus the receipts still to come in on
   open purchasing documents from `EKKO`/`EKPO`/`EKET`, on open production
   orders from `AUFK`/`AFKO`/`AFPO` and, where the plant asks for it, on
   planned orders from `PLAF` and purchase requisitions from `EBAN`, each on
   the day it arrives,
3. reads the open demand — sales orders from `VBAK`/`VBAP` and stock transport
   orders that take stock out of the plant from `EKKO`/`EKPO`/`EKET` — leaving
   out what is rejected, delivery blocked at any of the three levels a block
   can sit on, blocked by the credit check, served from a stock segment of its
   own, or waiting for a material that is flagged for deletion; converts it to base
   units, takes off what has already been delivered or sent and what earlier
   runs already reserved for the same line, and drops anything beyond the
   horizon,
4. walks the supply in the order it becomes available and distributes each day
   of it over the demand that can wait for it, either by delivery priority or
   as a fair share, handing over first whatever somebody has promised a line
   by hand, optionally holding every customer to a share of the pool, to the
   quota it agreed for the period, and to whole order units, and giving an
   item that may only ship complete either all of it or none of it,
5. records the outcome in `ZSTOCK_ALLOC_RES` and commits it,
6. reserves the confirmed quantities through `BAPI_RESERVATION_CREATE1`, links
   the reservation back onto the recorded run and commits that.

Each material is its own unit of work, committed through
`BAPI_TRANSACTION_COMMIT` and waited for, so the next material sees what this
one decided and a job that dies half way leaves whole answers behind.

Every answered line says how much was confirmed, how much is short, the day the
confirmed quantity is there — `now` when it comes off the shelf, otherwise the
day the last of its supply arrives — and, where it fell short, why: not enough
stock, stock that comes too late, the customer's share, its quota, whole
units, or the complete delivery rule.

One material failing does not stop the rest of the run; the report says which
ones failed and why. Twenty in a row does stop it: that is the lock table
full, the user without the authorization or the update task down, and it will
not be different for the twenty-first. The run says where it stopped and how
many materials it did not attempt, in the spool and in the log.

A run that changes something also writes an application log under the object
`ZSTOCK_ALLOC`, so a scheduled job can be read back in `SLG1` long after its
spool is gone: one line per material with the run to look the result up by, a
warning where a line did not get everything, and an error with the reason for
each material that was skipped, headed by the settings the run used and closed
by how the night went as a whole. Create the log object once with `SLG0` — it
is Customizing, not a repository object. Without it the run allocates exactly
as before and keeps no log.

Ticking **Give earlier allocations back first** re-cuts instead of adding: the
run cancels the reservations its earlier runs left on the material, so all the
demand on the books today competes for all the stock rather than for what is
left over. That is what makes an urgent order that arrived this morning able to
take stock from a line that is not due for a month.

A plant that sets a wait in Customizing also moves a line that has been short
in every run for that long one place up the queue, and another place for every
further wait of the same length: without it a stable order starves the same
lines every night.

A plant too big for one nightly job can be split: schedule `ZSTOCK_ALLOCATION`
several times with **Jobs sharing the plant** set to how many there are and
**Package this job covers** set to 1, 2, 3 and so on. Which job takes a
material follows from the material number, so the jobs never collide and
nothing is missed even though each of them reads the plant a moment apart.
`ZSTOCK_ALLOC_JOBS` schedules the whole set in one go rather than leaving
somebody to create them one at a time in SM36, where one job quietly missing
is a part of the plant nobody allocates.

Ticking **Carry on where a run stopped** leaves out every material a run has
already decided about today. A night that died at four in the morning is then
finished by re-scheduling the same job rather than by doing the whole plant
again.

**The selection screen defaults to a test run.** A test run does the whole
calculation and shows the result without recording or reserving anything.

## The other programs

Twenty programs is a lot to meet at once, so they are grouped by who runs
them. Everything reads and changes nothing, except the three at the bottom,
which say so on their selection screens and default to a test run.

### For the planner, in the morning

| Program              | What it answers                                          |
| -------------------- | -------------------------------------------------------- |
| `ZSTOCK_ALLOC_PLTS`  | how every plant you may see stands: materials, short lines, how much is short, the oldest day anything is still waiting for, and whether a run has touched it today |
| `ZSTOCK_ALLOC_SHORT` | what is short across the plant, soonest and biggest first, with the unit, how long it has been short, the reason and the customer on every line, narrowed to one MRP controller or one customer, and orderable by what has waited longest instead of what is wanted soonest: the list to work through |
| `ZSTOCK_ALLOC_DISPLAY` | what the last run decided, per material, with the customer on every line — narrowed to the short lines, one MRP controller or one customer |
| `ZSTOCK_ALLOC_ALT`   | what the plant has said could stand in for each material that came up short, and what those have |
| `ZSTOCK_ALLOC_WHY`   | the working behind one material — what has been promised or agreed for it by hand, every day of supply, every line competing for it, and what the three come to right now; and where nothing is waiting, why not |
| `ZSTOCK_ALLOC_PROJ`  | how a material stands week by week, and the first week it runs out |

### Before promising anything

| Program              | What it answers                                          |
| -------------------- | -------------------------------------------------------- |
| `ZSTOCK_ALLOC_ATP`   | how much can be promised of a quantity, and from when |
| `ZSTOCK_ALLOC_WHAT`  | what one more order would be confirmed, and which lines on the books would pay for it |
| `ZSTOCK_ALLOC_IF`    | what one more delivery would fix: which lines would gain, by how much, and how much of it nobody could take |
| `ZSTOCK_ALLOC_HIST`  | what every run so far decided about one sales order or stock transport order, run by run, and how long it has been going short |
| `ZSTOCK_ALLOC_DIFF`  | what the last run changed about the one before it, and which customers lost stock — or, ticked, what a run now would change |
| `ZSTOCK_ALLOC_TRY`   | what each distribution rule would confirm for one material, side by side |

### For whoever looks after the solution

| Program              | What it answers                                          |
| -------------------- | -------------------------------------------------------- |
| `ZSTOCK_ALLOC_COVER` | which materials with demand the last night did not get to at all, which is what a job that never ran looks like |
| `ZSTOCK_ALLOC_CHECK` | which recorded runs no longer agree with the reservation they claim |
| `ZSTOCK_ALLOC_CFGC`  | what is wrong with the Customizing of one plant or of every plant you may see: periods that run backwards, materials that are gone, classes nobody transported |
| `ZSTOCK_ALLOC_QUOT`  | how each quota of a plant stands: what was agreed, what the last run gave against it, and what is left |
| `ZSTOCK_ALLOC_PROM`  | what has been promised a line by hand, what the last run gave it, until when, and who promised it |

### The four that change something

| Program              | What it does                                             |
| -------------------- | -------------------------------------------------------- |
| `ZSTOCK_ALLOC_JOBS`  | schedules a plant's night as several background jobs at once, one per package |
| `ZSTOCK_ALLOC_ORPH`  | gives back stock still earmarked for demand that has gone from the documents |
| `ZSTOCK_ALLOC_FREE`  | gives a material's earmarked stock back by hand, for when it is wanted for something the run knows nothing about |
| `ZSTOCK_ALLOC_REORG` | removes recorded runs past the retention time that hold nothing back |

### For callers that are not people

`ZIF_ATP_QUERY` is the promise for a program in the same system to call, and
`Z_STOCK_ALLOC_PROMISE` the same answer again for a caller outside ABAP:
remote enabled, with flat fields and a `BAPIRET2` instead of an exception.
`Z_STOCK_ALLOC_PROMISES` answers a whole basket in one call, reading each
plant's settings once instead of once per line. `Z_STOCK_ALLOC_RESULT`
answers the question afterwards — what the last run actually gave an order —
for the same kind of caller, and takes a stock transport order as readily as a
sales one.

`ZSTOCK_ALLOC_SHORT` and `ZSTOCK_ALLOC_COVER` both take an e-mail address.
Scheduled with one, the morning list and the "did the night finish" check
arrive rather than waiting to be run. The coverage check sends only when
something is missing unless the box is unticked: a nightly mail saying
everything is fine is a mail nobody opens, and on the morning it matters it
looks like all the others.

`ZSTOCK_ALLOC_REORG` leaves a run whose reservation is still there alone,
because the demand netting reads it, and a real run writes to the same
application log as an allocation run.

## The night, in order

Nothing here has to be scheduled, and a plant that schedules only the
allocation gets a working allocation. What follows is the order the programs
are meant to be used in when a plant runs unattended, and why:

1. **`ZSTOCK_ALLOC_ORPH`** — give back stock still held for demand that has
   gone from the documents. Before the run rather than after it, so the run
   distributes that stock tonight instead of tomorrow night.
2. **`ZSTOCK_ALLOC_JOBS`** — the allocation itself, as one job per package.
   A plant small enough for one job can schedule `ZSTOCK_ALLOCATION`
   directly; ticking **Give earlier allocations back first** makes it a
   re-cut, which is what a plant wanting all of today's demand to compete for
   all of the stock needs.
3. **`ZSTOCK_ALLOC_COVER`** with an e-mail address — did the night finish. A
   package that never ran leaves no trace anywhere else, and this only writes
   to anybody when something is missing.
4. **`ZSTOCK_ALLOC_SHORT`** with an e-mail address — the morning list, waiting
   in an inbox rather than waiting to be run.
5. **`ZSTOCK_ALLOC_REORG`**, weekly rather than nightly — remove recorded runs
   past the retention time that hold nothing back.

`ZSTOCK_ALLOC_CFGC` belongs in the transport process rather than the nightly
one: run it after importing Customizing, when what it finds can still be
corrected before a night acts on it.

## Customizing

| Table               | What it holds                                             |
| ------------------- | --------------------------------------------------------- |
| `ZSTOCK_ALLOC_CFG`  | the settings of a plant: distribution rule, horizon, storage location, customer cap, whether planned orders and requisitions count as supply, whether confirmations are cut to whole order units, whether customers are held to their quotas, where a stock transport order stands against a customer order, how many days it takes to get goods out of the door and whether those are working days, how long a line may go short before it moves up the queue, which movement type the reservation is made under, whether a promise counts demand nobody has confirmed yet, and how long a recorded run is kept |
| `ZSTOCK_ALLOC_PRI`  | which customers are served before the rest, once per customer, for one plant or for all of them |
| `ZSTOCK_ALLOC_HLD`  | materials the plant has put on hold, with a reason and optionally a day the hold lifts by itself |
| `ZSTOCK_ALLOC_SUB`  | materials that could stand in for another one in a plant, how many of them make one of it, and what a planner should know before offering it |
| `ZSTOCK_ALLOC_FIX`  | quantities somebody has promised a demand line by hand, served before the distribution rules see the stock, with a last day and a note of who promised it |
| `ZSTOCK_ALLOC_QTA`  | how much of a material one customer may take in a period, per plant; a row naming no customer is the rule of the house |
| `ZSTOCK_ALLOC_EXT`  | classes of your own that join the run as a source of supply or of demand, for one plant or for all of them |

All seven Customizing tables are delivery class `C` and log their changes, so
`SCU3` answers "who put that quota in and when". None of them ships with a
maintenance view: generate one per table with the table maintenance generator
in `SE11` and put the views in a transport of their own, which is where a
system's own maintenance dialogues belong.

A class named in `ZSTOCK_ALLOC_EXT` has to implement `ZIF_SUPPLY_READER` or
`ZIF_DEMAND_READER`, be public and be creatable without parameters. It is read
alongside the sources that ship with the solution, and the engine cannot tell
the difference. A class that is missing or is not a reader of the kind it was
configured as fails the material with a message saying so, and in a plant wide
run the rest of the plant carries on.

Both allocation programs read `ZSTOCK_ALLOC_CFG` by default, so a scheduled job
only has to be told the plant; unticking **Settings come from the plant** hands
the screen back to somebody trying something out. A plant with no row gets the
defaults.

## Authorization

Every program here checks `ZSTOCK_ALL` before it reads or writes anything:
activity `02` to allocate, re-cut or give stock back, `03` to look at what a
run decided or work out what one would decide, and the plant in `WERKS`. The
object ships with the repository, so a role needs it before anybody can run a
plant.

Allocating is not maintaining a material master, which is why this does not
use `M_MATE_WRK`. A business that would rather guard it with the standard
object can wire `ZCL_AUTHORITY_PLANT` instead of `ZCL_AUTHORITY_ALLOC`: both
implement `ZIF_ALLOCATION_AUTHORITY` and nothing else has to change.

## Installing into SAP

Pull the repository with abapGit. `.abapgit.xml` sets the starting folder to
`/src/`, so only the custom `Z` objects are installed — the SAP standard stubs
under `/sap-stubs/` exist for linting and testing and must never reach a real
system, where the real `MARD`, `VBAP` and `BAPI_RESERVATION_CREATE1` are already
there.

## Developing

```sh
npm install
npm test
```

| Script              | What it does                                            |
| ------------------- | ------------------------------------------------------- |
| `npm run lint`      | `abaplint` over `src/` and `sap-stubs/`                 |
| `npm run docs`      | checks every report and Customizing table is in this file |
| `npm run transpile` | ABAP -> JavaScript into `output/`                       |
| `npm run unit`      | runs the transpiled ABAP Unit tests                     |
| `npm test`          | all four, in that order                                 |

The same four steps run on every push, see
[.github/workflows/test.yml](.github/workflows/test.yml).

## Where the seams are

Everything a customer is likely to want to change sits behind an interface.
`ZCL_ALLOCATION_SERVICE=>create_default( )` knows the object graph of one run and
`ZCL_ALLOCATION_MASS_RUN=>create_default( )` the graph of a plant wide one;
nothing else has to:

| Interface                  | Swap it to change                                  |
| -------------------------- | -------------------------------------------------- |
| `ZIF_ALLOCATION_STRATEGY`  | who gets the stock when there is not enough        |
| `ZIF_STOCK_DEDUCTION`      | what counts as unavailable, one class per reason   |
| `ZIF_SUPPLY_READER`        | what there is to give away, one class per source   |
| `ZIF_STOCK_READER`         | where the book stock comes from                     |
| `ZIF_DEMAND_READER`        | where demand comes from, and which materials count  |
| `ZIF_UNIT_CONVERTER`       | how quantities reach the base unit of measure      |
| `ZIF_RESERVATION_WRITER`   | how confirmed stock is earmarked                   |
| `ZIF_RESERVATION_READER`   | when an earlier reservation stops counting         |
| `ZIF_ALLOCATION_AUTHORITY` | which authorization object guards a run            |
| `ZIF_ALLOCATION_LOCK`      | how concurrent runs are kept apart                 |
| `ZIF_RUN_ID_SUPPLIER`      | how runs are numbered                              |
| `ZIF_ALLOCATION_STORE`     | where the result is recorded                       |
| `ZIF_ALLOCATION_LOG`       | where a run says what it did                       |
| `ZIF_ATP_QUERY`            | how a promise is worked out for one line           |
| `ZIF_ALLOC_CONFIG`         | where a plant's settings come from                 |
| `ZIF_UNIT_OF_WORK`         | what makes a run durable, and what undoes it       |

## Layout

- `src/` — the solution, all objects prefixed `Z`
- `sap-stubs/` — stubs of the SAP standard objects that open-abap does not ship
- `test/setup.mjs` — wires an in-memory SQLite database into the test run

## Documentation

- [PLAN.md](PLAN.md) — what is being built
- [NOTES.md](NOTES.md) — design decisions and progress, feature by feature
- [ANOMALIES.md](ANOMALIES.md) — toolchain defects found along the way
