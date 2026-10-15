CLASS zcl_alloc_shelf_ratio DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS ratio
      IMPORTING
        iv_total_days     TYPE i
        iv_remaining_days TYPE i
      RETURNING
        VALUE(rv_pct)     TYPE i.

    METHODS is_fresh
      IMPORTING
        iv_total_days     TYPE i
        iv_remaining_days TYPE i
        iv_min_pct        TYPE i
      RETURNING
        VALUE(rv_ok)      TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_shelf_ratio IMPLEMENTATION.

  METHOD ratio.
    IF iv_total_days <= 0 OR iv_remaining_days <= 0.
      RETURN.
    ENDIF.

    " The raw ratio can exceed 100 percent, which is exactly how an inconsistent
    " batch master record (remaining longer than total) becomes visible.
    rv_pct = iv_remaining_days * 100 DIV iv_total_days.
  ENDMETHOD.

  METHOD is_fresh.
    rv_ok = xsdbool( iv_min_pct > 0
                     AND ratio( iv_total_days     = iv_total_days
                                iv_remaining_days = iv_remaining_days ) >= iv_min_pct ).
  ENDMETHOD.

ENDCLASS.
