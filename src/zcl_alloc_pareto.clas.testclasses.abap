CLASS ltcl_alloc_pareto DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pareto.
    DATA mt_itm TYPE zcl_alloc_pareto=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id  TYPE string
        iv_qty TYPE menge_d.

    METHODS empty_items      FOR TESTING.
    METHODS sorts_descending FOR TESTING.
    METHODS shares_are_percent FOR TESTING.
    METHODS cumulative_runs  FOR TESTING.
    METHODS flags_vital      FOR TESTING.
    METHODS zero_total       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pareto IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pareto( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_pareto=>ty_item.

    ls_item-item_id = iv_id.
    ls_item-quantity = iv_qty.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD empty_items.
    DATA(lt_rows) = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->vital_count( lt_rows ) exp = 0 ).
  ENDMETHOD.

  METHOD sorts_descending.
    add( iv_id = 'SMALL' iv_qty = 10 ).
    add( iv_id = 'BIG' iv_qty = 60 ).
    add( iv_id = 'MID' iv_qty = 30 ).

    DATA(lt_rows) = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-item_id exp = 'BIG' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-item_id exp = 'MID' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 3 ]-item_id exp = 'SMALL' ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-rank exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 3 ]-rank exp = 3 ).
  ENDMETHOD.

  METHOD shares_are_percent.
    add( iv_id = 'BIG' iv_qty = 60 ).
    add( iv_id = 'MID' iv_qty = 30 ).
    add( iv_id = 'SMALL' iv_qty = 10 ).

    DATA(lt_rows) = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-share_x100 exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 3 ]-share_x100 exp = 10 ).
  ENDMETHOD.

  METHOD cumulative_runs.
    add( iv_id = 'BIG' iv_qty = 60 ).
    add( iv_id = 'MID' iv_qty = 30 ).
    add( iv_id = 'SMALL' iv_qty = 10 ).

    DATA(lt_rows) = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-cumul_x100 exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-cumul_x100 exp = 90 ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 3 ]-cumul_x100 exp = 100 ).
  ENDMETHOD.

  METHOD flags_vital.
    add( iv_id = 'BIG' iv_qty = 60 ).
    add( iv_id = 'MID' iv_qty = 30 ).
    add( iv_id = 'SMALL' iv_qty = 10 ).

    DATA(lt_rows) = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 1 ]-in_vital exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 2 ]-in_vital exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_rows[ 3 ]-in_vital exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->vital_count( lt_rows ) exp = 2 ).
  ENDMETHOD.

  METHOD zero_total.
    add( iv_id = 'NONE' iv_qty = 0 ).

    DATA(lt_rows) = mo_cut->build( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_rows ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
