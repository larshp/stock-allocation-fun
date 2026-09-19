INTERFACE zif_run_id_supplier PUBLIC.

  "! <p class="shorttext synchronized">Hand out an identifier for one allocation run</p>
  "!
  "! Which id scheme a system uses is a local decision, so it sits behind an
  "! interface rather than inside the service.
  "!
  "! @parameter rv_run_id      | <p class="shorttext synchronized">Allocation run</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">No identifier could be produced</p>
  METHODS next
    RETURNING
      VALUE(rv_run_id) TYPE zstock_alloc_res-run_id
    RAISING
      zcx_allocation.

ENDINTERFACE.
