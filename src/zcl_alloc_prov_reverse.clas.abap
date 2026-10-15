CLASS zcl_alloc_prov_reverse DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS reverse
      IMPORTING
        iv_provision        TYPE i
        iv_reversal_percent TYPE i
      RETURNING
        VALUE(rv_amount)    TYPE i.

    METHODS amount
      IMPORTING
        iv_provision     TYPE i
        iv_reversed      TYPE i
      RETURNING
        VALUE(rv_amount) TYPE i.

    METHODS is_full
      IMPORTING
        iv_reversed  TYPE i
        iv_provision TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_prov_reverse IMPLEMENTATION.

  METHOD reverse.
    " A reversal takes back a share of the provision.
    rv_amount = iv_provision * iv_reversal_percent DIV 100.
  ENDMETHOD.

  METHOD amount.
    " What is left is the provision less what was reversed.
    IF iv_reversed >= iv_provision.
      RETURN.
    ENDIF.

    rv_amount = iv_provision - iv_reversed.
  ENDMETHOD.

  METHOD is_full.
    " The reversal is full once it matches the whole provision.
    rv_ok = xsdbool( iv_reversed >= iv_provision ).
  ENDMETHOD.

ENDCLASS.
