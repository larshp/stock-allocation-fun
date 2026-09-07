CLASS zcl_alloc_reason_text DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! <p class="shorttext synchronized">Put a reason for falling short into words</p>
    "!
    "! One place for the wording, because both reports show the same column and
    "! two lists that call the same thing by two names are worse than none.
    "!
    "! @parameter iv_reason | <p class="shorttext synchronized">Reason of ZIF_ALLOCATION=&gt;C_REASON</p>
    "! @parameter rv_text   | <p class="shorttext synchronized">Wording, empty for a line that got everything</p>
    CLASS-METHODS text
      IMPORTING
        iv_reason      TYPE zif_allocation=>ty_reason
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_reason_text IMPLEMENTATION.

  METHOD text.

    " a reason nobody here knows is shown as it stands rather than swallowed:
    " a customer with a strategy of its own may answer with a code of its own,
    " and an unfamiliar letter says more than an empty column
    CASE iv_reason.
      WHEN zif_allocation=>c_reason-no_stock.
        rv_text = `not enough stock`.
      WHEN zif_allocation=>c_reason-supply_late.
        rv_text = `stock comes too late`.
      WHEN zif_allocation=>c_reason-customer_cap.
        rv_text = `customer share`.
      WHEN zif_allocation=>c_reason-whole_units.
        rv_text = `whole units only`.
      WHEN zif_allocation=>c_reason-complete_only.
        rv_text = `complete delivery`.
      WHEN zif_allocation=>c_reason-quota.
        rv_text = `customer quota`.
      WHEN zif_allocation=>c_reason-too_little.
        rv_text = `too little to ship`.
      WHEN zif_allocation=>c_reason-ship_together.
        rv_text = `ships with the rest of the order`.
      WHEN space.
        CLEAR rv_text.
      WHEN OTHERS.
        rv_text = |{ iv_reason }|.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
