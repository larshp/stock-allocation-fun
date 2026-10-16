CLASS zcl_alloc_cover_days DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS days
      IMPORTING
        iv_stock        TYPE i
        iv_daily_demand TYPE i
      RETURNING
        VALUE(rv_days)  TYPE i.

    METHODS is_covered
      IMPORTING
        iv_days          TYPE i
        iv_required_days TYPE i
      RETURNING
        VALUE(rv_ok)     TYPE abap_bool.

    METHODS gap_days
      IMPORTING
        iv_days          TYPE i
        iv_required_days TYPE i
      RETURNING
        VALUE(rv_gap)    TYPE i.

ENDCLASS.


CLASS zcl_alloc_cover_days IMPLEMENTATION.

  METHOD days.
    " The cover is the stock spread over the daily demand.
    IF iv_daily_demand <= 0.
      RETURN.
    ENDIF.

    rv_days = iv_stock DIV iv_daily_demand.
  ENDMETHOD.

  METHOD is_covered.
    " The stock covers the requirement while its cover reaches the target.
    rv_ok = xsdbool( iv_days >= iv_required_days ).
  ENDMETHOD.

  METHOD gap_days.
    " The gap is the short cover, never negative.
    IF iv_days >= iv_required_days.
      RETURN.
    ENDIF.

    rv_gap = iv_required_days - iv_days.
  ENDMETHOD.

ENDCLASS.
