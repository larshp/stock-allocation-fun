CLASS ltcl_alloc_snap_heavy DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut   TYPE REF TO zcl_alloc_snap_heavy.
    DATA mt_after TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add_after
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS make_before
      IMPORTING
        iv_id           TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty          TYPE menge_d
      RETURNING
        VALUE(rs_entry) TYPE zcl_alloc_snap_heavy=>ty_entry.

    METHODS take_maps_lines   FOR TESTING.
    METHODS take_empty        FOR TESTING.
    METHODS unchanged_line    FOR TESTING.
    METHODS changed_line      FOR TESTING.
    METHODS added_line        FOR TESTING.
    METHODS removed_line      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_snap_heavy IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_snap_heavy( ).
  ENDMETHOD.

  METHOD add_after.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.

    ls_result-requirement_id = iv_id.
    ls_result-allocated_qty = iv_qty.
    APPEND ls_result TO mt_after.
  ENDMETHOD.

  METHOD make_before.
    rs_entry-requirement_id = iv_id.
    rs_entry-allocated_qty = iv_qty.
  ENDMETHOD.

  METHOD take_maps_lines.
    add_after( iv_id = 'R1' iv_qty = 5 ).
    add_after( iv_id = 'R2' iv_qty = 3 ).

    DATA(lt_lines) = mo_cut->take( mt_after ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-requirement_id exp = 'R1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-allocated_qty exp = 3 ).
  ENDMETHOD.

  METHOD take_empty.
    DATA(lt_lines) = mo_cut->take( mt_after ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
  ENDMETHOD.

  METHOD unchanged_line.
    DATA lt_before TYPE zcl_alloc_snap_heavy=>ty_entry_tt.

    APPEND make_before( iv_id = 'R1' iv_qty = 7 ) TO lt_before.

    add_after( iv_id = 'R1' iv_qty = 7 ).

    DATA(lt_lines) = mo_cut->compare( it_before = lt_before
                                      it_after  = mt_after ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-changed exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = 0 ).
  ENDMETHOD.

  METHOD changed_line.
    DATA lt_before TYPE zcl_alloc_snap_heavy=>ty_entry_tt.

    APPEND make_before( iv_id = 'R1' iv_qty = 5 ) TO lt_before.

    add_after( iv_id = 'R1' iv_qty = 8 ).

    DATA(lt_lines) = mo_cut->compare( it_before = lt_before
                                      it_after  = mt_after ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-changed exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-previous_qty exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-current_qty exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = 3 ).
  ENDMETHOD.

  METHOD added_line.
    DATA lt_before TYPE zcl_alloc_snap_heavy=>ty_entry_tt.

    add_after( iv_id = 'R9' iv_qty = 4 ).

    DATA(lt_lines) = mo_cut->compare( it_before = lt_before
                                      it_after  = mt_after ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-changed exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-previous_qty exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = 4 ).
  ENDMETHOD.

  METHOD removed_line.
    DATA lt_before TYPE zcl_alloc_snap_heavy=>ty_entry_tt.

    APPEND make_before( iv_id = 'R5' iv_qty = 6 ) TO lt_before.

    DATA(lt_lines) = mo_cut->compare( it_before = lt_before
                                      it_after  = mt_after ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-changed exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-current_qty exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = -6 ).
  ENDMETHOD.

ENDCLASS.
