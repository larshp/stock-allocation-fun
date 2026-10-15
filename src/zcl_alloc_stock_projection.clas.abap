CLASS zcl_alloc_stock_projection DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS project
      IMPORTING
        it_demands      TYPE ty_values_tt
        iv_start_stock  TYPE i
      RETURNING
        VALUE(rt_stock) TYPE ty_values_tt.

    METHODS first_zero
      IMPORTING
        it_demands      TYPE ty_values_tt
        iv_start_stock  TYPE i
      RETURNING
        VALUE(rv_index) TYPE i.

    METHODS runs_out
      IMPORTING
        it_demands     TYPE ty_values_tt
        iv_start_stock TYPE i
      RETURNING
        VALUE(rv_ok)   TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_stock_projection IMPLEMENTATION.

  METHOD project.
    DATA lv_stock TYPE i.
    DATA lv_index TYPE i.

    lv_stock = iv_start_stock.

    " Every period reduces the running stock by its demand.
    LOOP AT it_demands INTO DATA(lv_demand).
      lv_index = lv_index + 1.
      lv_stock = lv_stock - lv_demand.
      APPEND lv_stock TO rt_stock.
    ENDLOOP.
  ENDMETHOD.

  METHOD first_zero.
    DATA lv_stock TYPE i.
    DATA lv_index TYPE i.

    lv_stock = iv_start_stock.

    " The first period whose projected stock reaches zero marks the run-out.
    LOOP AT it_demands INTO DATA(lv_demand).
      lv_index = lv_index + 1.
      lv_stock = lv_stock - lv_demand.

      IF lv_stock <= 0.
        rv_index = lv_index.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD runs_out.
    rv_ok = xsdbool( first_zero( it_demands     = it_demands
                                 iv_start_stock = iv_start_stock ) > 0 ).
  ENDMETHOD.

ENDCLASS.
