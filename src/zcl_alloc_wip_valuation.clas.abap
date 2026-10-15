CLASS zcl_alloc_wip_valuation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS valued_at
      IMPORTING
        iv_full_value   TYPE i
        iv_percent      TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS completion
      IMPORTING
        iv_done           TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_partial
      IMPORTING
        iv_percent   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_wip_valuation IMPLEMENTATION.

  METHOD valued_at.
    " The work in progress is valued at its degree of completion.
    rv_value = iv_full_value * iv_percent DIV 100.
  ENDMETHOD.

  METHOD completion.
    " The completion is the work done as a share of the whole.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_done * 100 DIV iv_total.
  ENDMETHOD.

  METHOD is_partial.
    " Work in progress is partial once it has started but not finished.
    IF iv_percent > 0 AND iv_percent < 100.
      rv_ok = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
