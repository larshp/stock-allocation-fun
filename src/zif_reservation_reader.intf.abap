INTERFACE zif_reservation_reader PUBLIC.

  TYPES ty_reservation_tab TYPE STANDARD TABLE OF resb-rsnum WITH EMPTY KEY.

  "! <p class="shorttext synchronized">Reservations that are still there for a material in a plant</p>
  "!
  "! A reservation counts as live while an item for the material exists and is
  "! not flagged for deletion. Whoever asks whether an earlier allocation still
  "! holds has to ask this question, and has to ask it the same way, so it is
  "! answered in one place only.
  "!
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
  "! @parameter rt_reservation | <p class="shorttext synchronized">Reservation numbers, no duplicates</p>
  METHODS live_reservations
    IMPORTING
      iv_matnr              TYPE mard-matnr
      iv_werks              TYPE mard-werks
    RETURNING
      VALUE(rt_reservation) TYPE ty_reservation_tab.

  "! <p class="shorttext synchronized">Quantity a reservation is still holding</p>
  "!
  "! The items that have not been flagged for deletion, added up. What a run
  "! promised and what its reservation holds should be the same number, and
  "! this is the second half of that comparison.
  "!
  "! @parameter iv_reservation | <p class="shorttext synchronized">Reservation number</p>
  "! @parameter rv_quantity    | <p class="shorttext synchronized">Quantity still held, zero if it is gone</p>
  METHODS held_quantity
    IMPORTING
      iv_reservation     TYPE rkpf-rsnum
    RETURNING
      VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

ENDINTERFACE.
