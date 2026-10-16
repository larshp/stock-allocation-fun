CLASS zcl_alloc_monte_carlo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             mean    TYPE i,
             spread  TYPE i,
             samples TYPE i,
             seed    TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             values  TYPE ty_values_tt,
             minimum TYPE i,
             maximum TYPE i,
             average TYPE i,
           END OF ty_result.

    METHODS simulate
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_monte_carlo IMPLEMENTATION.

  METHOD simulate.
    DATA lo_random TYPE REF TO zcl_alloc_random.
    DATA lv_count  TYPE i.
    DATA lv_spread TYPE i.
    DATA lv_neg    TYPE i.
    DATA lv_delta  TYPE i.
    DATA lv_draw   TYPE i.
    DATA lv_sum    TYPE i.
    DATA lv_first  TYPE i.

    lv_count = is_input-samples.
    IF lv_count <= 0.
      RETURN.
    ENDIF.

    lv_spread = is_input-spread.
    IF lv_spread < 0.
      lv_spread = 0 - lv_spread.
    ENDIF.
    lv_neg = 0 - lv_spread.

    lo_random = NEW zcl_alloc_random( iv_seed = is_input-seed ).

    DO lv_count TIMES.
      lv_delta = lo_random->between( iv_from = lv_neg
                                     iv_to   = lv_spread ).
      lv_draw = is_input-mean + lv_delta.

      IF lv_draw < 0.
        lv_draw = 0.
      ENDIF.

      APPEND lv_draw TO rs_result-values.
      lv_sum = lv_sum + lv_draw.
    ENDDO.

    rs_result-average = lv_sum DIV lv_count.

    READ TABLE rs_result-values INTO lv_first INDEX 1.
    rs_result-minimum = lv_first.
    rs_result-maximum = lv_first.

    LOOP AT rs_result-values INTO lv_draw.
      IF lv_draw < rs_result-minimum.
        rs_result-minimum = lv_draw.
      ENDIF.
      IF lv_draw > rs_result-maximum.
        rs_result-maximum = lv_draw.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
