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
   `M_MATE_WRK`) and locks the material for the run,
2. works out what there is to give away and from when: the book stock from
   `MARD`, restricted to the storage locations that may be allocated and less
   what is not up for allocation — open reservations, stock on deliveries that
   are waiting for their goods issue, and the plant's safety stock — plus the
   receipts still to come in on open purchasing documents from
   `EKKO`/`EKPO`/`EKET`, on open production orders from `AUFK`/`AFKO`/`AFPO`
   and, where the plant asks for it, on planned orders from `PLAF`, each on
   the day it arrives,
3. reads the open demand — sales orders from `VBAK`/`VBAP` and stock transport
   orders that take stock out of the plant from `EKKO`/`EKPO`/`EKET` — converts
   it to base units, takes off what has already been delivered or sent and what
   earlier runs already reserved for the same line, and drops anything beyond
   the horizon,
4. walks the supply in the order it becomes available and distributes each day
   of it over the demand that can wait for it, either by delivery priority or
   as a fair share, optionally holding every customer to a share of the pool
   and confirming whole order units only, and giving an item that may only ship
   complete either all of it or none of it,
5. records the outcome in `ZSTOCK_ALLOC_RES` and commits it,
6. reserves the confirmed quantities through `BAPI_RESERVATION_CREATE1`, links
   the reservation back onto the recorded run and commits that.

Each material is its own unit of work, committed through
`BAPI_TRANSACTION_COMMIT` and waited for, so the next material sees what this
one decided and a job that dies half way leaves whole answers behind.

Every answered line says how much was confirmed, how much is short, and the day
the confirmed quantity is there — `now` when it comes off the shelf, otherwise
the day the last of its supply arrives.

One material failing does not stop the rest of the run; the report says which
ones failed and why.

A run that changes something also writes an application log under the object
`ZSTOCK_ALLOC`, so a scheduled job can be read back in `SLG1` long after its
spool is gone: one line per material with the run to look the result up by, a
warning where a line did not get everything, and an error with the reason for
each material that was skipped. Create the log object once with `SLG0` — it
is Customizing, not a repository object. Without it the run allocates exactly
as before and keeps no log.

**The selection screen defaults to a test run.** A test run does the whole
calculation and shows the result without recording or reserving anything.

`ZSTOCK_ALLOC_DISPLAY` shows what the last run decided for a plant, per
material, and can be narrowed to the lines that did not get everything. It reads
the recorded result and changes nothing.

`ZSTOCK_ALLOC_ATP` answers the question a salesperson asks before writing an
order down: how much of a material this plant can promise, and from when. It
reads the same supply timeline a run distributes and changes nothing;
`ZIF_ATP_QUERY` is the same answer for a program to call.

`ZSTOCK_ALLOC_CFG` holds the settings of a plant — distribution rule, horizon,
storage location, customer cap, whether planned orders count as supply, whether
confirmations are cut to whole order units, and how long a recorded run is
kept. Both programs read it by default, so a scheduled job only has to be told
the plant; unticking **Settings come from the plant** hands the screen back to
somebody trying something out. A plant with no row gets the defaults.

`ZSTOCK_ALLOC_REORG` keeps `ZSTOCK_ALLOC_RES` from growing forever. It removes
recorded runs that are past the retention time **and** are no longer holding
anything back — a run whose reservation was rejected, deleted or is otherwise
gone. A run whose reservation is still there stays, because the demand netting
reads it. It defaults to a test run too.

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
| `npm run transpile` | ABAP -> JavaScript into `output/`                       |
| `npm run unit`      | runs the transpiled ABAP Unit tests                     |
| `npm test`          | all three, in that order                                |

The same three steps run on every push, see
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
