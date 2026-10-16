CLASS ltcl_alloc_batching DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_batching.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_matnr      TYPE matnr
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_batching=>ty_item.

    METHODS empty_list     FOR TESTING.
    METHODS single_batch   FOR TESTING.
    METHODS consecutive    FOR TESTING.
    METHODS returns_after  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_batching IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_batching( ).
  ENDMETHOD.

  METHOD item.
    rs_row-matnr = iv_matnr.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_batching=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->build( lt_items ) ).
  ENDMETHOD.

  METHOD single_batch.
    DATA lt_items TYPE zcl_alloc_batching=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_quantity = '3' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-1' iv_quantity = '4' ) TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-quantity exp = '7' ).
  ENDMETHOD.

  METHOD consecutive.
    DATA lt_items TYPE zcl_alloc_batching=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_quantity = '3' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-2' iv_quantity = '4' ) TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-matnr exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-matnr exp = 'MAT-2' ).
  ENDMETHOD.

  METHOD returns_after.
    DATA lt_items TYPE zcl_alloc_batching=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_quantity = '3' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-2' iv_quantity = '4' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-1' iv_quantity = '5' ) TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]-batch exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]-quantity exp = '5' ).
  ENDMETHOD.

ENDCLASS.
