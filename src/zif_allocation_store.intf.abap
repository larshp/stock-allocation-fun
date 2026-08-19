INTERFACE zif_allocation_store PUBLIC.

  "! What one recorded run covers. The rows of a run all carry the same
  "! material, plant and reservation, so this is the run seen from outside.
  TYPES:
    BEGIN OF ty_run_head,
      run_id      TYPE zstock_alloc_res-run_id,
      matnr       TYPE zstock_alloc_res-matnr,
      werks       TYPE zstock_alloc_res-werks,
      reservation TYPE zstock_alloc_res-reservation,
    END OF ty_run_head.
  TYPES ty_run_head_tab TYPE STANDARD TABLE OF ty_run_head WITH EMPTY KEY.

  "! <p class="shorttext synchronized">Record the outcome of an allocation run</p>
  "!
  "! Saving the same run twice replaces the earlier result rather than adding
  "! to it, so a run can be repeated without leaving stale lines behind.
  "!
  "! @parameter iv_run_id      | <p class="shorttext synchronized">Allocation run</p>
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
  "! @parameter it_allocation  | <p class="shorttext synchronized">Confirmed quantity per demand line</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Result could not be stored</p>
  METHODS save
    IMPORTING
      iv_run_id     TYPE zstock_alloc_res-run_id
      iv_matnr      TYPE mard-matnr
      iv_werks      TYPE mard-werks
      it_allocation TYPE zif_allocation=>ty_allocation_tab
    RAISING
      zcx_allocation.

  "! <p class="shorttext synchronized">Link a recorded run to the reservation it produced</p>
  "!
  "! Kept apart from SAVE because the reservation only exists after the result
  "! has been written down.
  "!
  "! @parameter iv_run_id      | <p class="shorttext synchronized">Allocation run</p>
  "! @parameter iv_reservation | <p class="shorttext synchronized">Number of the reservation</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Link could not be stored</p>
  METHODS record_reservation
    IMPORTING
      iv_run_id      TYPE zstock_alloc_res-run_id
      iv_reservation TYPE zstock_alloc_res-reservation
    RAISING
      zcx_allocation.

  "! <p class="shorttext synchronized">Read back the outcome of an allocation run</p>
  "!
  "! @parameter iv_run_id     | <p class="shorttext synchronized">Allocation run</p>
  "! @parameter rt_allocation | <p class="shorttext synchronized">Confirmed quantity per demand line</p>
  METHODS read
    IMPORTING
      iv_run_id            TYPE zstock_alloc_res-run_id
    RETURNING
      VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

  "! <p class="shorttext synchronized">Runs of a plant recorded before a point in time</p>
  "!
  "! One entry per run, not per demand line. For housekeeping, which has to
  "! decide per run whether the record is still doing any work.
  "!
  "! @parameter iv_werks      | <p class="shorttext synchronized">Plant</p>
  "! @parameter iv_created_at | <p class="shorttext synchronized">Time stamp everything older than is returned</p>
  "! @parameter rt_run        | <p class="shorttext synchronized">One entry per recorded run</p>
  METHODS runs_recorded_before
    IMPORTING
      iv_werks      TYPE mard-werks
      iv_created_at TYPE zstock_alloc_res-created_at
    RETURNING
      VALUE(rt_run) TYPE ty_run_head_tab.

  "! <p class="shorttext synchronized">Remove a recorded run</p>
  "!
  "! Deleting a run that is not there is an error: the caller asked for
  "! something to be removed and nothing was.
  "!
  "! @parameter iv_run_id      | <p class="shorttext synchronized">Allocation run</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Run could not be deleted</p>
  METHODS delete_run
    IMPORTING
      iv_run_id TYPE zstock_alloc_res-run_id
    RAISING
      zcx_allocation.

ENDINTERFACE.
