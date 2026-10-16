CLASS zcl_alloc_supplier_compare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_supplier,
             name  TYPE string,
             score TYPE i,
           END OF ty_supplier.
    TYPES ty_supplier_tt TYPE STANDARD TABLE OF ty_supplier WITH DEFAULT KEY.

    METHODS best
      IMPORTING
        it_suppliers   TYPE ty_supplier_tt
      RETURNING
        VALUE(rv_name) TYPE string.

    METHODS score_of
      IMPORTING
        it_suppliers    TYPE ty_supplier_tt
        iv_name         TYPE string
      RETURNING
        VALUE(rv_score) TYPE i.

    METHODS count
      IMPORTING
        it_suppliers    TYPE ty_supplier_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_supplier_compare IMPLEMENTATION.

  METHOD best.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.

    " The best supplier is the one with the highest score; the first wins ties.
    LOOP AT it_suppliers INTO DATA(ls_supplier).
      IF lv_found = abap_false OR ls_supplier-score > lv_best.
        lv_found = abap_true.
        lv_best = ls_supplier-score.
        rv_name = ls_supplier-name.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD score_of.
    " The score of a named supplier is zero when it is not in the list.
    LOOP AT it_suppliers INTO DATA(ls_supplier).
      IF ls_supplier-name = iv_name.
        rv_score = ls_supplier-score.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( it_suppliers ).
  ENDMETHOD.

ENDCLASS.
