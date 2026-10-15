CLASS zcl_alloc_recall_scope DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_stock,
             batch    TYPE string,
             material TYPE matnr,
           END OF ty_stock.
    TYPES ty_stock_tt TYPE STANDARD TABLE OF ty_stock WITH DEFAULT KEY.

    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS batches
      IMPORTING
        it_stock        TYPE ty_stock_tt
        iv_batch        TYPE string
      RETURNING
        VALUE(rt_batch) TYPE ty_text_tt.

    METHODS materials
      IMPORTING
        it_stock           TYPE ty_stock_tt
        iv_batch           TYPE string
      RETURNING
        VALUE(rt_material) TYPE ty_text_tt.

ENDCLASS.


CLASS zcl_alloc_recall_scope IMPLEMENTATION.

  METHOD materials.
    DATA lo_seen TYPE REF TO zcl_alloc_key_map.
    DATA lv_mat  TYPE string.

    " The material of the recalled batch defines the scope. Every batch of that
    " material is affected, and the map keeps the distinct list at one lookup per
    " stock row.
    lo_seen = NEW zcl_alloc_key_map( ).

    LOOP AT it_stock INTO DATA(ls_stock).
      IF ls_stock-batch <> iv_batch.
        CONTINUE.
      ENDIF.

      lv_mat = ls_stock-material.

      IF lo_seen->has( iv_key = lv_mat ) = abap_true.
        CONTINUE.
      ENDIF.

      lo_seen->put( iv_key   = lv_mat
                    iv_value = 1 ).
      APPEND ls_stock-material TO rt_material.
    ENDLOOP.
  ENDMETHOD.

  METHOD batches.
    DATA lt_materials TYPE ty_text_tt.
    DATA lo_mats      TYPE REF TO zcl_alloc_key_map.
    DATA lo_seen      TYPE REF TO zcl_alloc_key_map.
    DATA lv_mat       TYPE string.

    lt_materials = materials( it_stock = it_stock iv_batch = iv_batch ).

    lo_mats = NEW zcl_alloc_key_map( ).
    LOOP AT lt_materials INTO DATA(lv_material).
      lo_mats->put( iv_key   = lv_material
                    iv_value = 1 ).
    ENDLOOP.

    lo_seen = NEW zcl_alloc_key_map( ).

    LOOP AT it_stock INTO DATA(ls_stock).
      lv_mat = ls_stock-material.

      IF lo_mats->has( iv_key = lv_mat ) = abap_false.
        CONTINUE.
      ENDIF.
      IF lo_seen->has( iv_key = ls_stock-batch ) = abap_true.
        CONTINUE.
      ENDIF.

      lo_seen->put( iv_key   = ls_stock-batch
                    iv_value = 1 ).
      APPEND ls_stock-batch TO rt_batch.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
