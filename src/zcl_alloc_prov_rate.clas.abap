CLASS zcl_alloc_prov_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_provision   TYPE i
        iv_value       TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS provision
      IMPORTING
        iv_value            TYPE i
        iv_rate             TYPE i
      RETURNING
        VALUE(rv_provision) TYPE i.

    METHODS is_high
      IMPORTING
        iv_rate      TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_prov_rate IMPLEMENTATION.

  METHOD rate.
    " The provision rate is the provision related to the stock value.
    IF iv_value <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_provision * 100 DIV iv_value.
  ENDMETHOD.

  METHOD provision.
    " The provision is the stock value at the given rate.
    rv_provision = iv_value * iv_rate DIV 100.
  ENDMETHOD.

  METHOD is_high.
    " A rate above the threshold is a high provision.
    rv_ok = xsdbool( iv_rate > iv_threshold ).
  ENDMETHOD.

ENDCLASS.
