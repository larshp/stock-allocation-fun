CLASS zcl_alloc_seq_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             is_ordered  TYPE abap_bool,
             has_dupes   TYPE abap_bool,
             gap_count   TYPE i,
             first_value TYPE i,
             last_value  TYPE i,
           END OF ty_result.

    METHODS check
      IMPORTING
        it_numbers       TYPE zcl_alloc_gap_check=>ty_numbers_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_seq_check IMPLEMENTATION.

  METHOD check.
    DATA lt_sorted TYPE zcl_alloc_gap_check=>ty_numbers_tt.
    DATA lv_prev   TYPE i.
    DATA lv_first  TYPE abap_bool.

    rs_result-is_ordered = abap_true.
    rs_result-has_dupes = abap_false.
    rs_result-gap_count = 0.

    IF lines( it_numbers ) = 0.
      RETURN.
    ENDIF.

    lv_first = abap_true.
    LOOP AT it_numbers INTO DATA(ls_number).
      IF lv_first = abap_true.
        rs_result-first_value = ls_number-value.
        lv_prev = ls_number-value.
        lv_first = abap_false.
      ELSE.
        IF ls_number-value <= lv_prev.
          rs_result-is_ordered = abap_false.
        ENDIF.
        lv_prev = ls_number-value.
      ENDIF.

      rs_result-last_value = ls_number-value.
    ENDLOOP.

    lt_sorted = it_numbers.
    SORT lt_sorted BY value ASCENDING.

    lv_first = abap_true.
    LOOP AT lt_sorted INTO DATA(ls_sorted).
      IF lv_first = abap_true.
        lv_prev = ls_sorted-value.
        lv_first = abap_false.
        CONTINUE.
      ENDIF.

      IF ls_sorted-value = lv_prev.
        rs_result-has_dupes = abap_true.
      ENDIF.

      IF ls_sorted-value - lv_prev > 1.
        rs_result-gap_count = rs_result-gap_count + 1.
      ENDIF.

      lv_prev = ls_sorted-value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
