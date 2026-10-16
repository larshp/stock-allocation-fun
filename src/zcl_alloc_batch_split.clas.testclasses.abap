CLASS ltcl_alloc_batch_split DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_batch_split.

    METHODS setup.

    METHODS add
      IMPORTING
        it_items        TYPE zcl_alloc_batch_split=>ty_item_tt
        iv_matnr        TYPE matnr
        iv_quantity     TYPE menge_d
      RETURNING
        VALUE(rt_items) TYPE zcl_alloc_batch_split=>ty_item_tt.

    METHODS input
      IMPORTING
        it_items      TYPE zcl_alloc_batch_split=>ty_item_tt
        iv_max        TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_batch_split=>ty_input.

    METHODS empty_items   FOR TESTING.
    METHODS fits_one_batch FOR TESTING.
    METHODS splits_when_full FOR TESTING.
    METHODS oversized_own_batch FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_batch_split IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_batch_split( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_batch_split=>ty_item.

    rt_items = it_items.
    ls_item-matnr = iv_matnr.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO rt_items.
  ENDMETHOD.

  METHOD input.
    rs_row-items = it_items.
    rs_row-max_batch = iv_max.
  ENDMETHOD.

  METHOD empty_items.
    DATA lt_items TYPE zcl_alloc_batch_split=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->split( input( it_items = lt_items iv_max = '10' ) ) ).
  ENDMETHOD.

  METHOD fits_one_batch.
    DATA lt_items TYPE zcl_alloc_batch_split=>ty_item_tt.

    lt_items = add( it_items = lt_items iv_matnr = 'MAT-1' iv_quantity = '4' ).
    lt_items = add( it_items = lt_items iv_matnr = 'MAT-2' iv_quantity = '5' ).

    DATA(lt_lines) = mo_cut->split( input( it_items = lt_items
                                           iv_max   = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-batch exp = 1 ).
  ENDMETHOD.

  METHOD splits_when_full.
    DATA lt_items TYPE zcl_alloc_batch_split=>ty_item_tt.

    lt_items = add( it_items = lt_items iv_matnr = 'MAT-1' iv_quantity = '8' ).
    lt_items = add( it_items = lt_items iv_matnr = 'MAT-2' iv_quantity = '5' ).

    DATA(lt_lines) = mo_cut->split( input( it_items = lt_items
                                           iv_max   = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-batch exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-batch exp = 2 ).
  ENDMETHOD.

  METHOD oversized_own_batch.
    DATA lt_items TYPE zcl_alloc_batch_split=>ty_item_tt.

    lt_items = add( it_items = lt_items iv_matnr = 'MAT-1' iv_quantity = '25' ).
    lt_items = add( it_items = lt_items iv_matnr = 'MAT-2' iv_quantity = '1' ).

    DATA(lt_lines) = mo_cut->split( input( it_items = lt_items
                                           iv_max   = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-batch exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-batch exp = 2 ).
  ENDMETHOD.

ENDCLASS.
