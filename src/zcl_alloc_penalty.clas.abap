CLASS zcl_alloc_penalty DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_deviation,
             deviation_id TYPE string,
             amount       TYPE menge_d,
             weight       TYPE menge_d,
           END OF ty_deviation.
    TYPES ty_deviation_tt TYPE STANDARD TABLE OF ty_deviation WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_penalty,
             total_penalty TYPE menge_d,
             worst_id      TYPE string,
             worst_penalty TYPE menge_d,
             item_count    TYPE i,
           END OF ty_penalty.

    METHODS calculate
      IMPORTING
        it_deviations     TYPE ty_deviation_tt
        iv_cap            TYPE menge_d
      RETURNING
        VALUE(rs_penalty) TYPE ty_penalty.

ENDCLASS.


CLASS zcl_alloc_penalty IMPLEMENTATION.

  METHOD calculate.
    DATA lv_size TYPE menge_d.

    rs_penalty-item_count = lines( it_deviations ).

    LOOP AT it_deviations INTO DATA(ls_deviation).
      lv_size = ls_deviation-amount.
      IF lv_size < 0.
        lv_size = 0 - lv_size.
      ENDIF.

      lv_size = lv_size * ls_deviation-weight.

      IF iv_cap > 0 AND lv_size > iv_cap.
        lv_size = iv_cap.
      ENDIF.

      rs_penalty-total_penalty = rs_penalty-total_penalty + lv_size.

      IF lv_size > rs_penalty-worst_penalty.
        rs_penalty-worst_penalty = lv_size.
        rs_penalty-worst_id = ls_deviation-deviation_id.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
