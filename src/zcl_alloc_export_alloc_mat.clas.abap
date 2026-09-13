CLASS zcl_alloc_export_alloc_mat DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_mat,
             matnr     TYPE matnr,
             positions TYPE i,
             quantity  TYPE menge_d,
           END OF ty_mat.
    TYPES ty_mat_tt TYPE STANDARD TABLE OF ty_mat WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

    METHODS collect
      IMPORTING
        it_result     TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_mat) TYPE ty_mat_tt.

ENDCLASS.


CLASS zcl_alloc_export_alloc_mat IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD collect.
    DATA ls_mat TYPE ty_mat.

    LOOP AT it_result INTO DATA(ls_result).
      LOOP AT ls_result-allocations INTO DATA(ls_allocation).
        IF ls_allocation-quantity <= 0.
          CONTINUE.
        ENDIF.

        CLEAR ls_mat.
        ls_mat-matnr = ls_allocation-matnr.
        ls_mat-quantity = ls_allocation-quantity.
        APPEND ls_mat TO rt_mat.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    DATA lt_mat           TYPE ty_mat_tt.
    DATA lt_groups        TYPE ty_mat_tt.
    DATA ls_group         TYPE ty_mat.
    DATA lt_fields        TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line          TYPE string.
    DATA lv_group_started TYPE abap_bool.

    lt_mat = collect( it_result ).
    SORT lt_mat BY matnr ASCENDING.

    lv_group_started = abap_false.

    LOOP AT lt_mat INTO DATA(ls_item).
      IF lv_group_started = abap_false OR ls_item-matnr <> ls_group-matnr.
        IF lv_group_started = abap_true.
          APPEND ls_group TO lt_groups.
        ENDIF.
        CLEAR ls_group.
        ls_group-matnr = ls_item-matnr.
        lv_group_started = abap_true.
      ENDIF.

      ls_group-positions = ls_group-positions + 1.
      ls_group-quantity = ls_group-quantity + ls_item-quantity.
    ENDLOOP.

    IF lv_group_started = abap_true.
      APPEND ls_group TO lt_groups.
    ENDIF.

    APPEND 'MATNR' TO lt_fields.
    APPEND 'POSITIONS' TO lt_fields.
    APPEND 'QUANTITY' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT lt_groups INTO ls_group.
      lv_line = mo_csv->build_line( VALUE #(
        ( |{ ls_group-matnr }| )
        ( |{ ls_group-positions }| )
        ( |{ ls_group-quantity }| ) ) ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
