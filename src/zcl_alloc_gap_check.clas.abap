CLASS zcl_alloc_gap_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_number,
             value TYPE i,
           END OF ty_number.
    TYPES ty_numbers_tt TYPE STANDARD TABLE OF ty_number WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_gap,
             after   TYPE i,
             before  TYPE i,
             missing TYPE i,
           END OF ty_gap.
    TYPES ty_gap_tt TYPE STANDARD TABLE OF ty_gap WITH DEFAULT KEY.

    METHODS find
      IMPORTING
        it_numbers     TYPE ty_numbers_tt
      RETURNING
        VALUE(rt_gaps) TYPE ty_gap_tt.

ENDCLASS.


CLASS zcl_alloc_gap_check IMPLEMENTATION.

  METHOD find.
    DATA lt_sorted TYPE ty_numbers_tt.
    DATA ls_gap    TYPE ty_gap.
    DATA lv_prev   TYPE i.
    DATA lv_first  TYPE abap_bool.

    lt_sorted = it_numbers.
    SORT lt_sorted BY value ASCENDING.

    lv_first = abap_true.
    LOOP AT lt_sorted INTO DATA(ls_number).
      IF lv_first = abap_true.
        lv_prev = ls_number-value.
        lv_first = abap_false.
        CONTINUE.
      ENDIF.

      IF ls_number-value - lv_prev > 1.
        CLEAR ls_gap.
        ls_gap-after = lv_prev.
        ls_gap-before = ls_number-value.
        ls_gap-missing = ls_number-value - lv_prev - 1.
        APPEND ls_gap TO rt_gaps.
      ENDIF.

      lv_prev = ls_number-value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
