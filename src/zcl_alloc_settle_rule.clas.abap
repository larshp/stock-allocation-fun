CLASS zcl_alloc_settle_rule DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rule_of
      IMPORTING
        iv_percent       TYPE i
      RETURNING
        VALUE(rv_choice) TYPE string.

    METHODS is_full
      IMPORTING
        iv_percent   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        iv_rule          TYPE string
      RETURNING
        VALUE(rv_reason) TYPE string.

ENDCLASS.


CLASS zcl_alloc_settle_rule IMPLEMENTATION.

  METHOD rule_of.
    " The settlement rule reads full, partial or none.
    IF iv_percent >= 100.
      rv_choice = 'FULL'.
    ELSEIF iv_percent <= 0.
      rv_choice = 'NONE'.
    ELSE.
      rv_choice = 'PARTIAL'.
    ENDIF.
  ENDMETHOD.

  METHOD is_full.
    " The rule is full once the whole cost settles.
    rv_ok = xsdbool( iv_percent >= 100 ).
  ENDMETHOD.

  METHOD reason.
    " The reason explains what the settlement rule does.
    CASE iv_rule.
      WHEN 'FULL'.
        rv_reason = 'settles in full'.
      WHEN 'NONE'.
        rv_reason = 'does not settle'.
      WHEN OTHERS.
        rv_reason = 'settles in part'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
