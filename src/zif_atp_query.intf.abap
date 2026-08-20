INTERFACE zif_atp_query PUBLIC.

  "! What can be promised of one quantity of one material.
  "!
  "! QUANTITY is never more than what was asked for, and COMPLETE says whether
  "! it is all of it. DATE is the day the promised quantity is there in full,
  "! initial when it is on the shelf already -- the same convention the
  "! allocation result uses for AVAIL_DATE.
  TYPES:
    BEGIN OF ty_promise,
      quantity TYPE zif_allocation=>ty_quantity,
      date     TYPE d,
      complete TYPE abap_bool,
    END OF ty_promise.

  "! <p class="shorttext synchronized">What can be promised of a quantity, and from when</p>
  "!
  "! Answers the question a salesperson asks before writing an order down: can
  "! this plant give me this much, and when. It reads the same supply timeline
  "! an allocation run distributes -- stock that is free, less what is already
  "! held back, plus the receipts on their way -- and changes nothing.
  "!
  "! With IV_BY_DATE the answer only counts supply that is there by that day,
  "! which is a promise for a date the customer named. Without it the answer is
  "! the earliest day the whole quantity can be there.
  "!
  "! @parameter iv_matnr       | <p class="shorttext synchronized">Material number</p>
  "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
  "! @parameter iv_quantity    | <p class="shorttext synchronized">Quantity asked for, in the base unit</p>
  "! @parameter iv_by_date     | <p class="shorttext synchronized">Day it is wanted by, any day if empty</p>
  "! @parameter rs_promise     | <p class="shorttext synchronized">What can be promised, and from when</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Not allowed here, or supply unreadable</p>
  METHODS promise
    IMPORTING
      iv_matnr          TYPE mard-matnr
      iv_werks          TYPE mard-werks
      iv_quantity       TYPE zif_allocation=>ty_quantity
      iv_by_date        TYPE d OPTIONAL
    RETURNING
      VALUE(rs_promise) TYPE ty_promise
    RAISING
      zcx_allocation.

ENDINTERFACE.
