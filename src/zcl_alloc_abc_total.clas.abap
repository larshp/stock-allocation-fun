CLASS zcl_alloc_abc_total DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS total
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS average
      IMPORTING
        it_values         TYPE ty_values_tt
      RETURNING
        VALUE(rv_average) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_total     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_abc_total IMPLEMENTATION.

  METHOD total.
    " The total adds the cost of every activity.
    LOOP AT it_values INTO DATA(lv_value).
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD average.
    DATA lv_total TYPE i.
    DATA lv_count TYPE i.

    " The average spreads the total cost over the activities.
    LOOP AT it_values INTO DATA(lv_value).
      lv_total = lv_total + lv_value.
      lv_count = lv_count + 1.
    ENDLOOP.

    IF lv_count = 0.
      RETURN.
    ENDIF.

    rv_average = lv_total DIV lv_count.
  ENDMETHOD.

  METHOD is_zero.
    " A total at zero carries no activity cost.
    rv_ok = xsdbool( iv_total = 0 ).
  ENDMETHOD.

ENDCLASS.
