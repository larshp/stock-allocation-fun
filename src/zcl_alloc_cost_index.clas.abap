CLASS zcl_alloc_cost_index DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS index
      IMPORTING
        it_values       TYPE ty_values_tt
        iv_base_period  TYPE i
      RETURNING
        VALUE(rt_index) TYPE ty_values_tt.

    METHODS rebase
      IMPORTING
        it_values       TYPE ty_values_tt
        iv_base_value   TYPE i
      RETURNING
        VALUE(rt_index) TYPE ty_values_tt.

    METHODS change_percent
      IMPORTING
        iv_from           TYPE i
        iv_to             TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cost_index IMPLEMENTATION.

  METHOD index.
    DATA lv_count TYPE i.
    DATA lv_base  TYPE i.
    DATA lv_idx   TYPE i.

    " The series is carried onto its base period.
    lv_count = lines( it_values ).
    IF iv_base_period < 1 OR iv_base_period > lv_count.
      RETURN.
    ENDIF.

    READ TABLE it_values INTO lv_base INDEX iv_base_period.
    IF lv_base = 0.
      RETURN.
    ENDIF.

    LOOP AT it_values INTO DATA(lv_value).
      lv_idx = lv_value * 100 DIV lv_base.
      APPEND lv_idx TO rt_index.
    ENDLOOP.
  ENDMETHOD.

  METHOD rebase.
    DATA lv_idx TYPE i.

    " The series is carried onto the given base value.
    IF iv_base_value = 0.
      RETURN.
    ENDIF.

    LOOP AT it_values INTO DATA(lv_value).
      lv_idx = lv_value * 100 DIV iv_base_value.
      APPEND lv_idx TO rt_index.
    ENDLOOP.
  ENDMETHOD.

  METHOD change_percent.
    " The change is the move from one value to the next, in percent.
    IF iv_from = 0.
      RETURN.
    ENDIF.

    rv_percent = ( iv_to - iv_from ) * 100 DIV iv_from.
  ENDMETHOD.

ENDCLASS.
