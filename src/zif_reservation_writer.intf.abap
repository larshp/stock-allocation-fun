INTERFACE zif_reservation_writer PUBLIC.

  "! <p class="shorttext synchronized">Earmark confirmed stock with a reservation</p>
  "!
  "! Only lines with a confirmed quantity are reserved. If nothing was
  "! confirmed no reservation is created and the returned number stays initial.
  "!
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
  "! @parameter iv_lgort       | <p class="shorttext synchronized">Storage location, plant level if empty</p>
  "! @parameter it_allocation  | <p class="shorttext synchronized">Confirmed quantity per demand line</p>
  "! @parameter rv_reservation | <p class="shorttext synchronized">Number of the reservation created</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Reservation was rejected</p>
  METHODS reserve
    IMPORTING
      iv_matnr              TYPE mard-matnr
      iv_werks              TYPE mard-werks
      it_allocation         TYPE zif_allocation=>ty_allocation_tab
      iv_lgort              TYPE mard-lgort OPTIONAL
    RETURNING
      VALUE(rv_reservation) TYPE rkpf-rsnum
    RAISING
      zcx_allocation.

  "! <p class="shorttext synchronized">Give an earlier reservation back</p>
  "!
  "! What a run does before allocating afresh: the stock an earlier run set
  "! aside goes back into the pool, so the demand that is on the books today
  "! competes for all of it rather than for what is left over. A reservation
  "! that is already gone is not an error -- the stock is free either way.
  "!
  "! @parameter iv_reservation | <p class="shorttext synchronized">Reservation to give back</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Reservation could not be cancelled</p>
  METHODS cancel
    IMPORTING
      iv_reservation TYPE rkpf-rsnum
    RAISING
      zcx_allocation.

ENDINTERFACE.
