CLASS zcl_alloc_margin_limit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_below
      IMPORTING
        iv_margin_percent TYPE i
        iv_limit          TYPE i
      RETURNING
        VALUE(rv_ok)      TYPE abap_bool.

    METHODS gap
      IMPORTING
        iv_margin_percent TYPE i
        iv_limit          TYPE i
      RETURNING
        VALUE(rv_gap)     TYPE i.

    METHODS clamp
      IMPORTING
        iv_margin_percent TYPE i
        iv_limit          TYPE i
      RETURNING
        VALUE(rv_margin)  TYPE i.

ENDCLASS.


CLASS zcl_alloc_margin_limit IMPLEMENTATION.

  METHOD is_below.
    " The margin is below its limit once it falls short of it.
    rv_ok = xsdbool( iv_margin_percent < iv_limit ).
  ENDMETHOD.

  METHOD gap.
    " The gap is what the margin is short of the limit by.
    IF iv_margin_percent >= iv_limit.
      RETURN.
    ENDIF.

    rv_gap = iv_limit - iv_margin_percent.
  ENDMETHOD.

  METHOD clamp.
    " The margin is held up at the limit whenever it dips below it.
    IF iv_margin_percent < iv_limit.
      rv_margin = iv_limit.
    ELSE.
      rv_margin = iv_margin_percent.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
