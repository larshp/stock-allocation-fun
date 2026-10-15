CLASS zcl_alloc_shelf_life DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS remaining_days
      IMPORTING
        iv_today       TYPE i
        iv_expiry      TYPE i
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS is_expired
      IMPORTING
        iv_today          TYPE i
        iv_expiry         TYPE i
      RETURNING
        VALUE(rv_expired) TYPE abap_bool.

    METHODS is_usable
      IMPORTING
        iv_today         TYPE i
        iv_expiry        TYPE i
        iv_min_remaining TYPE i
      RETURNING
        VALUE(rv_ok)     TYPE abap_bool.

    METHODS is_expiring
      IMPORTING
        iv_today       TYPE i
        iv_expiry      TYPE i
        iv_warn_days   TYPE i
      RETURNING
        VALUE(rv_soon) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_shelf_life IMPLEMENTATION.

  METHOD remaining_days.
    " Dates arrive as plain day numbers, so no calendar arithmetic is involved.
    IF iv_expiry <= iv_today.
      RETURN.
    ENDIF.

    rv_days = iv_expiry - iv_today.
  ENDMETHOD.

  METHOD is_expired.
    " The expiry day itself is still usable; the batch is expired from the next
    " day onwards.
    rv_expired = xsdbool( iv_today > iv_expiry ).
  ENDMETHOD.

  METHOD is_usable.
    rv_ok = xsdbool( remaining_days( iv_today  = iv_today
                                     iv_expiry = iv_expiry ) >= iv_min_remaining
                     AND iv_min_remaining > 0 ).
  ENDMETHOD.

  METHOD is_expiring.
    rv_soon = xsdbool( is_expired( iv_today  = iv_today
                                   iv_expiry = iv_expiry ) = abap_false
                       AND remaining_days( iv_today  = iv_today
                                           iv_expiry = iv_expiry ) <= iv_warn_days
                       AND iv_warn_days > 0 ).
  ENDMETHOD.

ENDCLASS.
