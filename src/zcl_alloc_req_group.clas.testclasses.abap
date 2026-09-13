CLASS ltcl_alloc_req_group DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_req_group.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_matnr      TYPE matnr
        iv_qty        TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_req_group=>ty_item.

    METHODS empty_list     FOR TESTING.
    METHODS single_material FOR TESTING.
    METHODS two_materials  FOR TESTING.
    METHODS sums_quantity  FOR TESTING.
    METHODS sorted_output  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_req_group IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_req_group( ).
  ENDMETHOD.

  METHOD item.
    rs_row-matnr = iv_matnr.
    rs_row-requirement-requested_qty = iv_qty.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_req_group=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->group( lt_items ) ).
  ENDMETHOD.

  METHOD single_material.
    DATA lt_items TYPE zcl_alloc_req_group=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_qty = '10' ) TO lt_items.

    DATA(lt_groups) = mo_cut->group( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_groups ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 1 ]-matnr exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 1 ]-count exp = 1 ).
  ENDMETHOD.

  METHOD two_materials.
    DATA lt_items TYPE zcl_alloc_req_group=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_qty = '10' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-2' iv_qty = '5' ) TO lt_items.

    DATA(lt_groups) = mo_cut->group( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_groups ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 1 ]-count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 2 ]-count exp = 1 ).
  ENDMETHOD.

  METHOD sums_quantity.
    DATA lt_items TYPE zcl_alloc_req_group=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_qty = '10' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-1' iv_qty = '7' ) TO lt_items.

    DATA(lt_groups) = mo_cut->group( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_groups ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 1 ]-count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 1 ]-requested_qty
                                        exp = '17' ).
  ENDMETHOD.

  METHOD sorted_output.
    DATA lt_items TYPE zcl_alloc_req_group=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-B' iv_qty = '10' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-A' iv_qty = '5' ) TO lt_items.

    DATA(lt_groups) = mo_cut->group( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 1 ]-matnr exp = 'MAT-A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 2 ]-matnr exp = 'MAT-B' ).
  ENDMETHOD.

ENDCLASS.
