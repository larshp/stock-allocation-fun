CLASS zcl_alloc_demand_variability DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS variance
      IMPORTING
        it_values          TYPE ty_values_tt
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS std_dev
      IMPORTING
        it_values         TYPE ty_values_tt
      RETURNING
        VALUE(rv_std_dev) TYPE i.

    METHODS is_stable
      IMPORTING
        iv_std_dev   TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

  PRIVATE SECTION.
    METHODS square_root
      IMPORTING
        iv_value       TYPE i
      RETURNING
        VALUE(rv_root) TYPE i.

ENDCLASS.


CLASS zcl_alloc_demand_variability IMPLEMENTATION.

  METHOD square_root.
    DATA lv_limit TYPE i.

    lv_limit = iv_value.
    IF lv_limit < 0.
      lv_limit = 0.
    ENDIF.

    WHILE ( rv_root + 1 ) * ( rv_root + 1 ) <= lv_limit.
      rv_root = rv_root + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD variance.
    DATA lv_sum     TYPE i.
    DATA lv_count   TYPE i.
    DATA lv_mean    TYPE i.
    DATA lv_squares TYPE i.

    LOOP AT it_values INTO DATA(lv_value).
      lv_sum = lv_sum + lv_value.
      lv_count = lv_count + 1.
    ENDLOOP.

    IF lv_count <= 0.
      RETURN.
    ENDIF.

    lv_mean = lv_sum DIV lv_count.

    " The variance averages the squared distance from the mean.
    LOOP AT it_values INTO lv_value.
      DATA(lv_diff) = lv_value - lv_mean.
      lv_squares = lv_squares + lv_diff * lv_diff.
    ENDLOOP.

    rv_variance = lv_squares DIV lv_count.
  ENDMETHOD.

  METHOD std_dev.
    DATA lv_variance TYPE i.

    lv_variance = variance( it_values ).
    rv_std_dev = square_root( lv_variance ).
  ENDMETHOD.

  METHOD is_stable.
    " The demand is stable while its spread stays within the threshold.
    rv_ok = xsdbool( iv_std_dev <= iv_threshold ).
  ENDMETHOD.

ENDCLASS.
