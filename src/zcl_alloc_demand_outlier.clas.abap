CLASS zcl_alloc_demand_outlier DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS filter
      IMPORTING
        it_values        TYPE ty_values_tt
        iv_limit         TYPE i
      RETURNING
        VALUE(rt_values) TYPE ty_values_tt.

    METHODS is_outlier
      IMPORTING
        iv_value     TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS removed_count
      IMPORTING
        it_values       TYPE ty_values_tt
        iv_limit        TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_demand_outlier IMPLEMENTATION.

  METHOD is_outlier.
    " A demand above the limit is treated as an outlier.
    rv_ok = xsdbool( iv_value > iv_limit ).
  ENDMETHOD.

  METHOD filter.
    " The filtered history keeps the demands at or below the limit; other values
    " are dropped.
    LOOP AT it_values INTO DATA(lv_value).
      IF lv_value <= iv_limit.
        APPEND lv_value TO rt_values.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD removed_count.
    LOOP AT it_values INTO DATA(lv_value).
      IF is_outlier( iv_value = lv_value iv_limit = iv_limit ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
