CLASS ltcl_alloc_reconcile DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut    TYPE REF TO zcl_alloc_reconcile.
    DATA mt_left   TYPE zcl_alloc_reconcile=>ty_item_tt.
    DATA mt_right  TYPE zcl_alloc_reconcile=>ty_item_tt.

    METHODS setup.

    METHODS add_left
      IMPORTING
        iv_key TYPE string
        iv_qty TYPE menge_d.

    METHODS add_right
      IMPORTING
        iv_key TYPE string
        iv_qty TYPE menge_d.

    METHODS matched_lines   FOR TESTING.
    METHODS differing_line  FOR TESTING.
    METHODS missing_line    FOR TESTING.
    METHODS extra_line      FOR TESTING.
    METHODS balanced_flag   FOR TESTING.
    METHODS empty_both      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_reconcile IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_reconcile( ).
  ENDMETHOD.

  METHOD add_left.
    DATA ls_item TYPE zcl_alloc_reconcile=>ty_item.

    ls_item-item_key = iv_key.
    ls_item-quantity = iv_qty.
    APPEND ls_item TO mt_left.
  ENDMETHOD.

  METHOD add_right.
    DATA ls_item TYPE zcl_alloc_reconcile=>ty_item.

    ls_item-item_key = iv_key.
    ls_item-quantity = iv_qty.
    APPEND ls_item TO mt_right.
  ENDMETHOD.

  METHOD matched_lines.
    add_left( iv_key = 'A' iv_qty = 10 ).
    add_right( iv_key = 'A' iv_qty = 10 ).

    DATA(lt_lines) = mo_cut->compare( it_left  = mt_left
                                      it_right = mt_right ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-status exp = 'matched' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = 0 ).
  ENDMETHOD.

  METHOD differing_line.
    add_left( iv_key = 'A' iv_qty = 10 ).
    add_right( iv_key = 'A' iv_qty = 7 ).

    DATA(lt_lines) = mo_cut->compare( it_left  = mt_left
                                      it_right = mt_right ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-status exp = 'differs' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = 3 ).
  ENDMETHOD.

  METHOD missing_line.
    add_left( iv_key = 'A' iv_qty = 10 ).

    DATA(lt_lines) = mo_cut->compare( it_left  = mt_left
                                      it_right = mt_right ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-status exp = 'missing' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-right_qty exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = 10 ).
  ENDMETHOD.

  METHOD extra_line.
    add_right( iv_key = 'Z' iv_qty = 4 ).

    DATA(lt_lines) = mo_cut->compare( it_left  = mt_left
                                      it_right = mt_right ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-status exp = 'extra' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-left_qty exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = -4 ).
  ENDMETHOD.

  METHOD balanced_flag.
    add_left( iv_key = 'A' iv_qty = 1 ).
    add_right( iv_key = 'A' iv_qty = 1 ).

    DATA(lt_lines) = mo_cut->compare( it_left  = mt_left
                                      it_right = mt_right ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_balanced( lt_lines ) exp = abap_true ).

    add_right( iv_key = 'B' iv_qty = 2 ).

    DATA(lt_second) = mo_cut->compare( it_left  = mt_left
                                       it_right = mt_right ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_balanced( lt_second ) exp = abap_false ).
  ENDMETHOD.

  METHOD empty_both.
    DATA(lt_lines) = mo_cut->compare( it_left  = mt_left
                                      it_right = mt_right ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_balanced( lt_lines ) exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
