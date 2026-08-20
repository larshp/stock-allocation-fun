INTERFACE zif_allocation_log PUBLIC.

  "! <p class="shorttext synchronized">Start a log for a plant wide run</p>
  "!
  "! Called once, before the first material. Nothing here raises: a run that
  "! cannot write its diary still has to allocate stock, and a night's
  "! allocations must not be lost because the log was.
  "!
  "! @parameter iv_werks | <p class="shorttext synchronized">Plant the run covers</p>
  METHODS start
    IMPORTING
      iv_werks TYPE mard-werks.

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

  "! <p class="shorttext synchronized">Make the log durable</p>
  "!
  "! Called once, after the last material. A log that is never saved is gone
  "! when the job ends, which is what a run with nothing to say wants.
  METHODS save.

ENDINTERFACE.
