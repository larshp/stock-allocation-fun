CLASS ltcl_alloc_abc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_matnr      TYPE matnr
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_abc=>ty_item.

    METHODS empty_result       FOR TESTING.
    METHODS single_item_is_a   FOR TESTING.
    METHODS sorted_descending  FOR TESTING.
    METHODS share_and_cum      FOR TESTING.
    METHODS second_item_is_b   FOR TESTING.
    METHODS zero_total_is_a    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_abc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc( ).
  ENDMETHOD.

  METHOD item.
    rs_row-matnr = iv_matnr.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD empty_result.
    DATA lt_items TYPE zcl_alloc_abc=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->classify( lt_items ) ).
  ENDMETHOD.

  METHOD single_item_is_a.
    DATA lt_items TYPE zcl_alloc_abc=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_quantity = '10' ) TO lt_items.

    DATA(lt_lines) = mo_cut->classify( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-class exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-share_pct exp = 100 ).
  ENDMETHOD.

  METHOD sorted_descending.
    DATA lt_items TYPE zcl_alloc_abc=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-A' iv_quantity = '10' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-B' iv_quantity = '90' ) TO lt_items.

    DATA(lt_lines) = mo_cut->classify( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-matnr exp = 'MAT-B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-matnr exp = 'MAT-A' ).
  ENDMETHOD.

  METHOD share_and_cum.
    DATA lt_items TYPE zcl_alloc_abc=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-B' iv_quantity = '90' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-A' iv_quantity = '10' ) TO lt_items.

    DATA(lt_lines) = mo_cut->classify( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-share_pct exp = 90 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-cum_pct exp = 90 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-cum_pct exp = 100 ).
  ENDMETHOD.

  METHOD second_item_is_b.
    DATA lt_items TYPE zcl_alloc_abc=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-B' iv_quantity = '90' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-A' iv_quantity = '10' ) TO lt_items.

    DATA(lt_lines) = mo_cut->classify( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-class exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-class exp = 'B' ).
  ENDMETHOD.

  METHOD zero_total_is_a.
    DATA lt_items TYPE zcl_alloc_abc=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_quantity = '0' ) TO lt_items.

    DATA(lt_lines) = mo_cut->classify( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-share_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-class exp = 'A' ).
  ENDMETHOD.

ENDCLASS.
