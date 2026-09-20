INTERFACE zif_work_calendar PUBLIC.

  "! <p class="shorttext synchronized">The day that is so many days before another</p>
  "!
  "! What "three days before the customer wants it" means is a decision about
  "! the plant, not a subtraction: a plant that does not pick on a Sunday has
  "! to start on the Wednesday for a Monday delivery, and one that runs seven
  "! days a week starts on the Friday. Both are behind this.
  "!
  "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
  "! @parameter iv_date        | <p class="shorttext synchronized">Day to count back from</p>
  "! @parameter iv_days        | <p class="shorttext synchronized">Days to count back</p>
  "! @parameter rv_date        | <p class="shorttext synchronized">The day arrived at</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">The calendar could not answer</p>
  METHODS days_before
    IMPORTING
      iv_werks       TYPE mard-werks
      iv_date        TYPE d
      iv_days        TYPE i
    RETURNING
      VALUE(rv_date) TYPE d
    RAISING
      zcx_allocation.

ENDINTERFACE.
