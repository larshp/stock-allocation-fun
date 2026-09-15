CLASS zcl_alloc_sequence DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_mode TYPE c LENGTH 1.

    TYPES: BEGIN OF ty_row,
             lgort    TYPE lgort_d,
             charg    TYPE c LENGTH 10,
             gr_date  TYPE d,
             quantity TYPE menge_d,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    METHODS order
      IMPORTING
        it_rows        TYPE ty_row_tt
        iv_mode        TYPE ty_mode DEFAULT 'F'
      RETURNING
        VALUE(rt_rows) TYPE ty_row_tt.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             lgort    TYPE lgort_d,
             charg    TYPE c LENGTH 10,
             gr_date  TYPE d,
             quantity TYPE menge_d,
             sort_key TYPE d,
           END OF ty_work.
    TYPES ty_work_tt TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.

ENDCLASS.


CLASS zcl_alloc_sequence IMPLEMENTATION.

  METHOD order.
    DATA lt_work    TYPE ty_work_tt.
    DATA ls_work    TYPE ty_work.
    DATA lv_unknown TYPE d.

    IF iv_mode = 'L'.
      " latest goods receipt first, unknown dates last
      lv_unknown = '00000000'.
    ELSE.
      " earliest goods receipt first, unknown dates last
      lv_unknown = '99991231'.
    ENDIF.

    LOOP AT it_rows INTO DATA(ls_row).
      CLEAR ls_work.
      ls_work-lgort = ls_row-lgort.
      ls_work-charg = ls_row-charg.
      ls_work-gr_date = ls_row-gr_date.
      ls_work-quantity = ls_row-quantity.

      IF ls_row-gr_date IS INITIAL.
        ls_work-sort_key = lv_unknown.
      ELSE.
        ls_work-sort_key = ls_row-gr_date.
      ENDIF.

      APPEND ls_work TO lt_work.
    ENDLOOP.

    IF iv_mode = 'L'.
      SORT lt_work BY sort_key DESCENDING
                      lgort ASCENDING
                      charg ASCENDING.
    ELSE.
      SORT lt_work BY sort_key ASCENDING
                      lgort ASCENDING
                      charg ASCENDING.
    ENDIF.

    LOOP AT lt_work INTO DATA(ls_sorted).
      APPEND VALUE #( lgort    = ls_sorted-lgort
                      charg    = ls_sorted-charg
                      gr_date  = ls_sorted-gr_date
                      quantity = ls_sorted-quantity ) TO rt_rows.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
