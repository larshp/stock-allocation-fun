CLASS zcl_alloc_demand_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             demand_class TYPE string,
             periods      TYPE i,
             non_zero     TYPE i,
             adi_x100     TYPE i,
             cv2_x100     TYPE i,
             mean         TYPE menge_d,
           END OF ty_result.

    METHODS classify
      IMPORTING
        it_series        TYPE ty_series_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    CONSTANTS c_adi_limit TYPE i VALUE 132.
    CONSTANTS c_cv2_limit TYPE i VALUE 4900.

ENDCLASS.


CLASS zcl_alloc_demand_class IMPLEMENTATION.

  METHOD classify.
    DATA lv_sum     TYPE menge_d.
    DATA lv_dev     TYPE menge_d.
    DATA lv_var_sum TYPE menge_d.
    DATA lv_variance TYPE menge_d.
    DATA lv_square  TYPE menge_d.
    DATA lv_adi     TYPE abap_bool.
    DATA lv_vol     TYPE abap_bool.

    rs_result-periods = lines( it_series ).

    IF rs_result-periods = 0.
      rs_result-demand_class = 'unknown'.
      RETURN.
    ENDIF.

    LOOP AT it_series INTO DATA(lv_value).
      IF lv_value > 0.
        rs_result-non_zero = rs_result-non_zero + 1.
        lv_sum = lv_sum + lv_value.
      ENDIF.
    ENDLOOP.

    IF rs_result-non_zero = 0.
      rs_result-demand_class = 'no demand'.
      RETURN.
    ENDIF.

    rs_result-adi_x100 = rs_result-periods * 100 DIV rs_result-non_zero.
    rs_result-mean = lv_sum DIV rs_result-non_zero.

    LOOP AT it_series INTO lv_value.
      IF lv_value <= 0.
        CONTINUE.
      ENDIF.

      lv_dev = lv_value - rs_result-mean.
      lv_var_sum = lv_var_sum + lv_dev * lv_dev.
    ENDLOOP.

    lv_variance = lv_var_sum DIV rs_result-non_zero.
    lv_square = rs_result-mean * rs_result-mean.

    IF lv_square > 0.
      rs_result-cv2_x100 = lv_variance * 10000 DIV lv_square.
    ENDIF.

    IF rs_result-adi_x100 >= c_adi_limit.
      lv_adi = abap_true.
    ENDIF.

    IF rs_result-cv2_x100 >= c_cv2_limit.
      lv_vol = abap_true.
    ENDIF.

    IF lv_adi = abap_false AND lv_vol = abap_false.
      rs_result-demand_class = 'smooth'.
    ELSEIF lv_adi = abap_true AND lv_vol = abap_false.
      rs_result-demand_class = 'intermittent'.
    ELSEIF lv_adi = abap_false AND lv_vol = abap_true.
      rs_result-demand_class = 'erratic'.
    ELSE.
      rs_result-demand_class = 'lumpy'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
