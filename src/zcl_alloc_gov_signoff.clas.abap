CLASS zcl_alloc_gov_signoff DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_signed
      IMPORTING
        iv_signed    TYPE i
        iv_required  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS status
      IMPORTING
        iv_signed        TYPE i
        iv_required      TYPE i
      RETURNING
        VALUE(rv_status) TYPE string.

    METHODS require
      IMPORTING
        iv_signed      TYPE i
        iv_required    TYPE i
      RETURNING
        VALUE(rv_more) TYPE i.

ENDCLASS.


CLASS zcl_alloc_gov_signoff IMPLEMENTATION.

  METHOD is_signed.
    " The sign-off is complete once enough signatures are in.
    rv_ok = xsdbool( iv_signed >= iv_required ).
  ENDMETHOD.

  METHOD status.
    " The sign-off reads complete, partial or open.
    IF iv_signed >= iv_required.
      rv_status = 'COMPLETE'.
    ELSEIF iv_signed > 0.
      rv_status = 'PARTIAL'.
    ELSE.
      rv_status = 'OPEN'.
    ENDIF.
  ENDMETHOD.

  METHOD require.
    " How many more signatures the sign-off still needs.
    IF iv_signed >= iv_required.
      RETURN.
    ENDIF.

    rv_more = iv_required - iv_signed.
  ENDMETHOD.

ENDCLASS.
