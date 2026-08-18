INTERFACE zif_allocation_store PUBLIC.

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

  "! <p class="shorttext synchronized">Read back the outcome of an allocation run</p>
  "!
  "! @parameter iv_run_id     | <p class="shorttext synchronized">Allocation run</p>
  "! @parameter rt_allocation | <p class="shorttext synchronized">Confirmed quantity per demand line</p>
  METHODS read
    IMPORTING
      iv_run_id            TYPE zstock_alloc_res-run_id
    RETURNING
      VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

ENDINTERFACE.
