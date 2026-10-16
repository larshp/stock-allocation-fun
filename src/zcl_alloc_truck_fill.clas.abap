CLASS zcl_alloc_truck_fill DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_load,
             weight TYPE i,
             volume TYPE i,
           END OF ty_load.
    TYPES ty_load_tt TYPE STANDARD TABLE OF ty_load WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             weight     TYPE i,
             volume     TYPE i,
             weight_pct TYPE i,
             volume_pct TYPE i,
             fits       TYPE abap_bool,
             limiting   TYPE string,
           END OF ty_result.

    METHODS check
      IMPORTING
        it_load          TYPE ty_load_tt
        iv_max_weight    TYPE i
        iv_max_volume    TYPE i
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_truck_fill IMPLEMENTATION.

  METHOD check.
    DATA lv_w_pct TYPE i.
    DATA lv_v_pct TYPE i.

    LOOP AT it_load INTO DATA(ls_load).
      rs_result-weight = rs_result-weight + ls_load-weight.
      rs_result-volume = rs_result-volume + ls_load-volume.
    ENDLOOP.

    IF iv_max_weight > 0.
      lv_w_pct = rs_result-weight * 100 DIV iv_max_weight.
    ENDIF.
    IF iv_max_volume > 0.
      lv_v_pct = rs_result-volume * 100 DIV iv_max_volume.
    ENDIF.

    rs_result-weight_pct = lv_w_pct.
    rs_result-volume_pct = lv_v_pct.

    " A truck with no stated limit is not constrained by that dimension.
    rs_result-fits = xsdbool( ( iv_max_weight <= 0 OR rs_result-weight <= iv_max_weight )
                              AND ( iv_max_volume <= 0 OR rs_result-volume <= iv_max_volume ) ).

    IF lv_w_pct > lv_v_pct.
      rs_result-limiting = 'WEIGHT'.
    ELSEIF lv_v_pct > lv_w_pct.
      rs_result-limiting = 'VOLUME'.
    ELSE.
      rs_result-limiting = 'NONE'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
