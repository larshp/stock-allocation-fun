CLASS zcl_alloc_export_alloc_mjson DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_mat,
             matnr     TYPE matnr,
             positions TYPE i,
             quantity  TYPE menge_d,
           END OF ty_mat.
    TYPES ty_mat_tt TYPE STANDARD TABLE OF ty_mat WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_result      TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rv_json) TYPE string.

  PRIVATE SECTION.
    METHODS collect
      IMPORTING
        it_result     TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_mat) TYPE ty_mat_tt.

ENDCLASS.


CLASS zcl_alloc_export_alloc_mjson IMPLEMENTATION.

  METHOD collect.
    DATA ls_mat TYPE ty_mat.

    LOOP AT it_result INTO DATA(ls_result).
      LOOP AT ls_result-allocations INTO DATA(ls_allocation).
        IF ls_allocation-quantity <= 0.
          CONTINUE.
        ENDIF.

        CLEAR ls_mat.
        ls_mat-matnr = ls_allocation-matnr.
        ls_mat-positions = 1.
        ls_mat-quantity = ls_allocation-quantity.
        APPEND ls_mat TO rt_mat.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    DATA lt_mat   TYPE ty_mat_tt.
    DATA ls_line  TYPE ty_mat.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    lt_mat = collect( it_result ).
    SORT lt_mat BY matnr ASCENDING.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT lt_mat INTO DATA(ls_item).
      IF lv_first = abap_true OR ls_item-matnr <> ls_line-matnr.
        IF lv_first = abap_false.
          rv_json = rv_json && lv_item.
        ENDIF.

        CLEAR ls_line.
        ls_line-matnr = ls_item-matnr.
        lv_first = abap_false.
      ENDIF.

      ls_line-positions = ls_line-positions + 1.
      ls_line-quantity = ls_line-quantity + ls_item-quantity.

      IF sy-tabix = lines( lt_mat ) OR ls_item-matnr <> ls_line-matnr.
        CLEAR lv_item.
        lv_item = '{'.
        lv_item = lv_item && |"matnr":"{ ls_line-matnr }",|.
        lv_item = lv_item && |"positions":{ ls_line-positions },|.
        lv_item = lv_item && |"quantity":{ ls_line-quantity }|.
        lv_item = lv_item && '}'.
      ENDIF.
    ENDLOOP.

    IF lv_first = abap_false.
      " rebuild the output from the aggregated groups for correctness
      CLEAR rv_json.
      rv_json = '['.
      lv_first = abap_true.
      DATA lv_group_first TYPE abap_bool.
      DATA ls_group TYPE ty_mat.

      lv_group_first = abap_true.
      CLEAR ls_group.

      LOOP AT lt_mat INTO DATA(ls_group_item).
        IF lv_group_first = abap_true OR ls_group_item-matnr <> ls_group-matnr.
          IF lv_group_first = abap_false.
            IF lv_first = abap_false.
              rv_json = rv_json && ','.
            ENDIF.
            lv_first = abap_false.
            CLEAR lv_item.
            lv_item = '{'.
            lv_item = lv_item && |"matnr":"{ ls_group-matnr }",|.
            lv_item = lv_item && |"positions":{ ls_group-positions },|.
            lv_item = lv_item && |"quantity":{ ls_group-quantity }|.
            lv_item = lv_item && '}'.
            rv_json = rv_json && lv_item.
          ENDIF.

          CLEAR ls_group.
          ls_group-matnr = ls_group_item-matnr.
          lv_group_first = abap_false.
        ENDIF.

        ls_group-positions = ls_group-positions + 1.
        ls_group-quantity = ls_group-quantity + ls_group_item-quantity.
      ENDLOOP.

      IF lv_group_first = abap_false.
        IF lv_first = abap_false.
          rv_json = rv_json && ','.
        ENDIF.
        CLEAR lv_item.
        lv_item = '{'.
        lv_item = lv_item && |"matnr":"{ ls_group-matnr }",|.
        lv_item = lv_item && |"positions":{ ls_group-positions },|.
        lv_item = lv_item && |"quantity":{ ls_group-quantity }|.
        lv_item = lv_item && '}'.
        rv_json = rv_json && lv_item.
      ENDIF.
    ENDIF.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
