CLASS ltcl_alloc_diff3 DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_diff3.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_id         TYPE zcl_alloc_diff3=>ty_id
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_diff3=>ty_item.

    METHODS input
      IMPORTING
        it_base       TYPE zcl_alloc_diff3=>ty_item_tt
        it_left       TYPE zcl_alloc_diff3=>ty_item_tt
        it_right      TYPE zcl_alloc_diff3=>ty_item_tt
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_diff3=>ty_input.

    METHODS identical_kept   FOR TESTING.
    METHODS left_only        FOR TESTING.
    METHODS right_only       FOR TESTING.
    METHODS both_same_change FOR TESTING.
    METHODS conflict         FOR TESTING.
    METHODS unions_keys      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_diff3 IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_diff3( ).
  ENDMETHOD.

  METHOD item.
    rs_row-id = iv_id.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD input.
    rs_row-base = it_base.
    rs_row-left = it_left.
    rs_row-right = it_right.
  ENDMETHOD.

  METHOD identical_kept.
    DATA lt_base TYPE zcl_alloc_diff3=>ty_item_tt.

    APPEND item( iv_id = 'R1' iv_quantity = '10' ) TO lt_base.

    DATA(lt_lines) = mo_cut->compare( input( it_base  = lt_base
                                             it_left  = lt_base
                                             it_right = lt_base ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-status exp = 'S' ).
  ENDMETHOD.

  METHOD left_only.
    DATA lt_base TYPE zcl_alloc_diff3=>ty_item_tt.
    DATA lt_left TYPE zcl_alloc_diff3=>ty_item_tt.

    APPEND item( iv_id = 'R1' iv_quantity = '10' ) TO lt_base.
    APPEND item( iv_id = 'R1' iv_quantity = '7' ) TO lt_left.

    DATA(lt_lines) = mo_cut->compare( input( it_base  = lt_base
                                             it_left  = lt_left
                                             it_right = lt_base ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-status exp = 'L' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-left_qty
                                        exp = '7' ).
  ENDMETHOD.

  METHOD right_only.
    DATA lt_base  TYPE zcl_alloc_diff3=>ty_item_tt.
    DATA lt_right TYPE zcl_alloc_diff3=>ty_item_tt.

    APPEND item( iv_id = 'R1' iv_quantity = '10' ) TO lt_base.
    APPEND item( iv_id = 'R1' iv_quantity = '4' ) TO lt_right.

    DATA(lt_lines) = mo_cut->compare( input( it_base  = lt_base
                                             it_left  = lt_base
                                             it_right = lt_right ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-status exp = 'R' ).
  ENDMETHOD.

  METHOD both_same_change.
    DATA lt_base  TYPE zcl_alloc_diff3=>ty_item_tt.
    DATA lt_left  TYPE zcl_alloc_diff3=>ty_item_tt.
    DATA lt_right TYPE zcl_alloc_diff3=>ty_item_tt.

    APPEND item( iv_id = 'R1' iv_quantity = '10' ) TO lt_base.
    APPEND item( iv_id = 'R1' iv_quantity = '6' ) TO lt_left.
    APPEND item( iv_id = 'R1' iv_quantity = '6' ) TO lt_right.

    DATA(lt_lines) = mo_cut->compare( input( it_base  = lt_base
                                             it_left  = lt_left
                                             it_right = lt_right ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-status exp = 'S' ).
  ENDMETHOD.

  METHOD conflict.
    DATA lt_base  TYPE zcl_alloc_diff3=>ty_item_tt.
    DATA lt_left  TYPE zcl_alloc_diff3=>ty_item_tt.
    DATA lt_right TYPE zcl_alloc_diff3=>ty_item_tt.

    APPEND item( iv_id = 'R1' iv_quantity = '10' ) TO lt_base.
    APPEND item( iv_id = 'R1' iv_quantity = '6' ) TO lt_left.
    APPEND item( iv_id = 'R1' iv_quantity = '4' ) TO lt_right.

    DATA(lt_lines) = mo_cut->compare( input( it_base  = lt_base
                                             it_left  = lt_left
                                             it_right = lt_right ) ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-status exp = 'C' ).
  ENDMETHOD.

  METHOD unions_keys.
    DATA lt_left  TYPE zcl_alloc_diff3=>ty_item_tt.
    DATA lt_right TYPE zcl_alloc_diff3=>ty_item_tt.

    APPEND item( iv_id = 'R2' iv_quantity = '5' ) TO lt_left.
    APPEND item( iv_id = 'R1' iv_quantity = '3' ) TO lt_right.

    DATA(lt_lines) = mo_cut->compare( input( it_base  = VALUE #( )
                                             it_left  = lt_left
                                             it_right = lt_right ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-id exp = 'R1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-status exp = 'R' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-status exp = 'L' ).
  ENDMETHOD.

ENDCLASS.
