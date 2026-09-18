CLASS ltcl_alloc_restore DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut      TYPE REF TO zcl_alloc_restore.
    DATA mt_target   TYPE zcl_alloc_snap_heavy=>ty_entry_tt.
    DATA mt_current  TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add_target
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS add_current
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS identical_plan   FOR TESTING.
    METHODS update_needed    FOR TESTING.
    METHODS create_needed    FOR TESTING.
    METHODS delete_needed    FOR TESTING.
    METHODS mix_of_actions   FOR TESTING.
    METHODS empty_both       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_restore IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_restore( ).
  ENDMETHOD.

  METHOD add_target.
    DATA ls_entry TYPE zcl_alloc_snap_heavy=>ty_entry.

    ls_entry-requirement_id = iv_id.
    ls_entry-allocated_qty = iv_qty.
    APPEND ls_entry TO mt_target.
  ENDMETHOD.

  METHOD add_current.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.

    ls_result-requirement_id = iv_id.
    ls_result-allocated_qty = iv_qty.
    APPEND ls_result TO mt_current.
  ENDMETHOD.

  METHOD identical_plan.
    add_target( iv_id = 'R1' iv_qty = 5 ).
    add_current( iv_id = 'R1' iv_qty = 5 ).

    DATA(lt_actions) = mo_cut->plan( it_target  = mt_target
                                     it_current = mt_current ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_actions ) exp = 0 ).
  ENDMETHOD.

  METHOD update_needed.
    add_target( iv_id = 'R1' iv_qty = 5 ).
    add_current( iv_id = 'R1' iv_qty = 8 ).

    DATA(lt_actions) = mo_cut->plan( it_target  = mt_target
                                     it_current = mt_current ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_actions ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_actions[ 1 ]-action exp = 'update' ).
    cl_abap_unit_assert=>assert_equals( act = lt_actions[ 1 ]-target_qty exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_actions[ 1 ]-current_qty exp = 8 ).
  ENDMETHOD.

  METHOD create_needed.
    add_target( iv_id = 'R3' iv_qty = 2 ).

    DATA(lt_actions) = mo_cut->plan( it_target  = mt_target
                                     it_current = mt_current ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_actions ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_actions[ 1 ]-action exp = 'create' ).
    cl_abap_unit_assert=>assert_equals( act = lt_actions[ 1 ]-current_qty exp = 0 ).
  ENDMETHOD.

  METHOD delete_needed.
    add_current( iv_id = 'R4' iv_qty = 9 ).

    DATA(lt_actions) = mo_cut->plan( it_target  = mt_target
                                     it_current = mt_current ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_actions ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_actions[ 1 ]-action exp = 'delete' ).
    cl_abap_unit_assert=>assert_equals( act = lt_actions[ 1 ]-current_qty exp = 9 ).
  ENDMETHOD.

  METHOD mix_of_actions.
    add_target( iv_id = 'R1' iv_qty = 5 ).
    add_target( iv_id = 'R2' iv_qty = 1 ).
    add_current( iv_id = 'R1' iv_qty = 5 ).
    add_current( iv_id = 'R2' iv_qty = 4 ).
    add_current( iv_id = 'R7' iv_qty = 3 ).

    DATA(lt_actions) = mo_cut->plan( it_target  = mt_target
                                     it_current = mt_current ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_actions ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_actions[ 1 ]-action exp = 'update' ).
    cl_abap_unit_assert=>assert_equals( act = lt_actions[ 2 ]-action exp = 'delete' ).
  ENDMETHOD.

  METHOD empty_both.
    DATA(lt_actions) = mo_cut->plan( it_target  = mt_target
                                     it_current = mt_current ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_actions ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
