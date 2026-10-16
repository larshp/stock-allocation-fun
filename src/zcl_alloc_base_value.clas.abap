CLASS zcl_alloc_base_value DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS value
      IMPORTING
        iv_quantity     TYPE i
        iv_price        TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS total
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_value     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_base_value IMPLEMENTATION.

  METHOD value.
    " A base value is its quantity at its price.
    rv_value = iv_quantity * iv_price.
  ENDMETHOD.

  METHOD total.
    " The total adds up the base values.
    LOOP AT it_values INTO DATA(lv_value).
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_zero.
    " A base value at zero carries no weight.
    rv_ok = xsdbool( iv_value = 0 ).
  ENDMETHOD.

ENDCLASS.
