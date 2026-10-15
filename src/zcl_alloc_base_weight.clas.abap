CLASS zcl_alloc_base_weight DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS weight_of
      IMPORTING
        iv_base           TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS total
      IMPORTING
        it_weights      TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_weight    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_base_weight IMPLEMENTATION.

  METHOD weight_of.
    " The weight is one base as a share of the whole.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_base * 100 DIV iv_total.
  ENDMETHOD.

  METHOD total.
    " The weights add up to how the base is spread.
    LOOP AT it_weights INTO DATA(lv_weight).
      rv_total = rv_total + lv_weight.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_zero.
    " A base at zero carries no weight.
    rv_ok = xsdbool( iv_weight = 0 ).
  ENDMETHOD.

ENDCLASS.
