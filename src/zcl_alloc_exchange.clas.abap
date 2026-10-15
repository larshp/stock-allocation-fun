CLASS zcl_alloc_exchange DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_pair,
             returned_material    TYPE matnr,
             replacement_material TYPE matnr,
             quantity             TYPE i,
           END OF ty_pair.
    TYPES ty_pair_tt TYPE STANDARD TABLE OF ty_pair WITH DEFAULT KEY.

    METHODS propose
      IMPORTING
        it_returned     TYPE ty_item_tt
        it_replacements TYPE ty_item_tt
      RETURNING
        VALUE(rt_pairs) TYPE ty_pair_tt.

    METHODS paired
      IMPORTING
        it_pairs      TYPE ty_pair_tt
      RETURNING
        VALUE(rv_qty) TYPE i.

    METHODS quantity
      IMPORTING
        it_pairs             TYPE ty_pair_tt
        iv_returned_material TYPE matnr
      RETURNING
        VALUE(rv_qty)        TYPE i.

ENDCLASS.


CLASS zcl_alloc_exchange IMPLEMENTATION.

  METHOD propose.
    DATA ls_pair TYPE ty_pair.

    " A returned item is paired with the first replacement of the same material,
    " and only as far as the smaller of the two quantities allows.
    LOOP AT it_returned INTO DATA(ls_returned).
      IF ls_returned-quantity <= 0.
        CONTINUE.
      ENDIF.

      LOOP AT it_replacements INTO DATA(ls_replacement).
        IF ls_replacement-material <> ls_returned-material
            OR ls_replacement-quantity <= 0.
          CONTINUE.
        ENDIF.

        CLEAR ls_pair.
        ls_pair-returned_material = ls_returned-material.
        ls_pair-replacement_material = ls_replacement-material.

        IF ls_returned-quantity < ls_replacement-quantity.
          ls_pair-quantity = ls_returned-quantity.
        ELSE.
          ls_pair-quantity = ls_replacement-quantity.
        ENDIF.

        APPEND ls_pair TO rt_pairs.
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD paired.
    LOOP AT it_pairs INTO DATA(ls_pair).
      rv_qty = rv_qty + ls_pair-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD quantity.
    LOOP AT it_pairs INTO DATA(ls_pair).
      IF ls_pair-returned_material = iv_returned_material.
        rv_qty = rv_qty + ls_pair-quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
