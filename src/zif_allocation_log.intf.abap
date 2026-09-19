INTERFACE zif_allocation_log PUBLIC.

  "! <p class="shorttext synchronized">Start a log for a plant wide run</p>
  "!
  "! Called once, before the first material. Nothing here raises: a run that
  "! cannot write its diary still has to allocate stock, and a night's
  "! allocations must not be lost because the log was.
  "!
  "! @parameter iv_werks    | <p class="shorttext synchronized">Plant the run covers</p>
  "! @parameter iv_settings | <p class="shorttext synchronized">What the run was told to do, in a line</p>
  METHODS start
    IMPORTING
      iv_werks    TYPE mard-werks
      iv_settings TYPE string OPTIONAL.

  "! <p class="shorttext synchronized">Note that a material was allocated</p>
  "!
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_run_id      | <p class="shorttext synchronized">Run the result was recorded under</p>
  "! @parameter iv_short_lines | <p class="shorttext synchronized">Lines that did not get everything</p>
  METHODS allocated
    IMPORTING
      iv_matnr       TYPE mard-matnr
      iv_run_id      TYPE zstock_alloc_res-run_id
      iv_short_lines TYPE i DEFAULT 0.

  "! <p class="shorttext synchronized">Note that a material could not be allocated</p>
  "!
  "! @parameter iv_matnr  | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_reason | <p class="shorttext synchronized">Why it was left out</p>
  METHODS failed
    IMPORTING
      iv_matnr  TYPE mard-matnr
      iv_reason TYPE string.

  "! <p class="shorttext synchronized">Note that an earlier reservation was given back</p>
  "!
  "! A re-cut takes stock away from lines that had it. That is the most
  "! consequential thing a run does and, until it says so here, the only trace
  "! of it is the reservation no longer being there.
  "!
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material the stock was held for</p>
  "! @parameter iv_reservation | <p class="shorttext synchronized">Reservation that was cancelled</p>
  METHODS released
    IMPORTING
      iv_matnr       TYPE mard-matnr
      iv_reservation TYPE rkpf-rsnum.

  "! <p class="shorttext synchronized">Note that a transfer was proposed</p>
  "!
  "! Since feature 172 the proposing is an unattended job covering the whole
  "! company, and a note it writes changes somebody's morning in a plant the
  "! job was not even called for. That is the kind of job feature 40 gave a
  "! diary to: the spool is gone in a fortnight and `ZSTOCK_ALLOC_TRF` says
  "! who wrote the note but not what the run as a whole did.
  "!
  "! @parameter iv_matnr      | <p class="shorttext synchronized">Material</p>
  "! @parameter iv_from_werks | <p class="shorttext synchronized">Plant being asked for it</p>
  "! @parameter iv_quantity   | <p class="shorttext synchronized">Quantity asked for</p>
  METHODS proposed
    IMPORTING
      iv_matnr      TYPE mard-matnr
      iv_from_werks TYPE mard-werks
      iv_quantity   TYPE zif_allocation=>ty_quantity.

  "! <p class="shorttext synchronized">Note how many stale proposals were closed</p>
  "!
  "! A count rather than one line each: which notes they were is in
  "! `ZSTOCK_ALLOC_TRF` with who closed them and when, and that is the record.
  "! What the diary adds is that a run closed some at all, which is the thing
  "! nobody would otherwise know had happened.
  "!
  "! @parameter iv_closed | <p class="shorttext synchronized">Proposals whose shortage had gone</p>
  METHODS proposals_closed
    IMPORTING
      iv_closed TYPE i.

  "! <p class="shorttext synchronized">Note that a recorded run was removed</p>
  "!
  "! Housekeeping is a job of this solution like the allocation itself, and a
  "! job that deletes something unattended is exactly the kind that has to be
  "! able to say afterwards what it deleted.
  "!
  "! @parameter iv_run_id | <p class="shorttext synchronized">Run that was removed</p>
  METHODS removed
    IMPORTING
      iv_run_id TYPE zstock_alloc_res-run_id.

  "! <p class="shorttext synchronized">Note how the run ended</p>
  "!
  "! The last line, and the one somebody reads first: a night that covered
  "! four hundred materials and left two short is a different night from one
  "! that left two hundred short, and neither is visible from four hundred
  "! lines each saying what happened to one of them.
  "!
  "! @parameter iv_materials | <p class="shorttext synchronized">Materials the run covered</p>
  "! @parameter iv_short     | <p class="shorttext synchronized">Of those, how many did not get everything</p>
  "! @parameter iv_failed    | <p class="shorttext synchronized">Of those, how many could not be allocated</p>
  METHODS finished
    IMPORTING
      iv_materials TYPE i
      iv_short     TYPE i
      iv_failed    TYPE i.

  "! <p class="shorttext synchronized">Make the log durable</p>
  "!
  "! Called once, after the last material. A log that is never saved is gone
  "! when the job ends, which is what a run with nothing to say wants.
  METHODS save.

ENDINTERFACE.
