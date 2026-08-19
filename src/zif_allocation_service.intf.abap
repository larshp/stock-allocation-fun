INTERFACE zif_allocation_service PUBLIC.

  "! What one allocation run produced: the id it was recorded under, the
  "! reservation that earmarked the stock, and who got what.
  TYPES:
    BEGIN OF ty_run,
      run_id      TYPE zstock_alloc_res-run_id,
      reservation TYPE zstock_alloc_res-reservation,
      allocation  TYPE zif_allocation=>ty_allocation_tab,
    END OF ty_run.

  "! <p class="shorttext synchronized">Allocate the stock of a material, record it and earmark it</p>
  "!
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
  "! @parameter rs_run         | <p class="shorttext synchronized">Run id, reservation and confirmed quantities</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Run could not be recorded or reserved</p>
  METHODS run
    IMPORTING
      iv_matnr      TYPE mard-matnr
      iv_werks      TYPE mard-werks
    RETURNING
      VALUE(rs_run) TYPE ty_run
    RAISING
      zcx_allocation.

  "! <p class="shorttext synchronized">Work the allocation out without acting on it</p>
  "!
  "! Same calculation as RUN, but nothing is recorded and no stock is
  "! reserved, so RUN_ID and RESERVATION come back initial. The material is not
  "! locked either: a simulation that blocks the real run would be worse than a
  "! simulation that reads slightly stale numbers.
  "!
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
  "! @parameter rs_run         | <p class="shorttext synchronized">What the run would have confirmed</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Allocation could not be worked out</p>
  METHODS simulate
    IMPORTING
      iv_matnr      TYPE mard-matnr
      iv_werks      TYPE mard-werks
    RETURNING
      VALUE(rs_run) TYPE ty_run
    RAISING
      zcx_allocation.

ENDINTERFACE.
