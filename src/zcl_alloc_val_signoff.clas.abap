CLASS zcl_alloc_val_signoff DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_signed
      IMPORTING
        iv_signed_by TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS status
      IMPORTING
        iv_line_count    TYPE i
        iv_is_signed     TYPE abap_bool
      RETURNING
        VALUE(rv_status) TYPE string.

    METHODS require
      IMPORTING
        iv_status        TYPE string
      RETURNING
        VALUE(rv_action) TYPE string.

ENDCLASS.


CLASS zcl_alloc_val_signoff IMPLEMENTATION.

  METHOD is_signed.
    " A valuation is signed once a name is on it.
    rv_ok = xsdbool( iv_signed_by IS NOT INITIAL ).
  ENDMETHOD.

  METHOD status.
    " The status runs from empty through draft to signed.
    IF iv_line_count <= 0.
      rv_status = 'EMPTY'.
    ELSEIF iv_is_signed = abap_true.
      rv_status = 'SIGNED'.
    ELSE.
      rv_status = 'DRAFT'.
    ENDIF.
  ENDMETHOD.

  METHOD require.
    " Each status asks for the next step in the sign-off.
    CASE iv_status.
      WHEN 'EMPTY'.
        rv_action = 'nothing to sign'.
      WHEN 'DRAFT'.
        rv_action = 'awaiting sign-off'.
      WHEN OTHERS.
        rv_action = 'complete'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
