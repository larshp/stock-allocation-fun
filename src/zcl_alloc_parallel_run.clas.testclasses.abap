CLASS ltcl_alloc_parallel_run DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_parallel_run.
    DATA mt_old TYPE zcl_stock_allocator=>ty_result_tt.
    DATA mt_new TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add_old
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS add_new
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS identical_match     FOR TESTING.
    METHODS within_tolerance    FOR TESTING.
    METHODS outside_tolerance   FOR TESTING.
    METHODS new_only_is_mismatch FOR TESTING.
    METHODS old_only_is_mismatch FOR TESTING.
    METHODS counts_mismatches   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_parallel_run IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_parallel_run( ).
  ENDMETHOD.

  METHOD add_old.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.

    ls_result-requirement_id = iv_id.
    ls_result-allocated_qty = iv_qty.
    APPEND ls_result TO mt_old.
  ENDMETHOD.

  METHOD add_new.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.

    ls_result-requirement_id = iv_id.
    ls_result-allocated_qty = iv_qty.
    APPEND ls_result TO mt_new.
  ENDMETHOD.

  METHOD identical_match.
    add_old( iv_id = 'R1' iv_qty = 10 ).
    add_new( iv_id = 'R1' iv_qty = 10 ).

    DATA(lt_lines) = mo_cut->compare( it_old       = mt_old
                                      it_new       = mt_new
                                      iv_tolerance = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-within_tol exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mismatch_count( lt_lines ) exp = 0 ).
  ENDMETHOD.

  METHOD within_tolerance.
    add_old( iv_id = 'R1' iv_qty = 10 ).
    add_new( iv_id = 'R1' iv_qty = 12 ).

    DATA(lt_lines) = mo_cut->compare( it_old       = mt_old
                                      it_new       = mt_new
                                      iv_tolerance = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-within_tol exp = abap_true ).
  ENDMETHOD.

  METHOD outside_tolerance.
    add_old( iv_id = 'R1' iv_qty = 10 ).
    add_new( iv_id = 'R1' iv_qty = 5 ).

    DATA(lt_lines) = mo_cut->compare( it_old       = mt_old
                                      it_new       = mt_new
                                      iv_tolerance = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = -5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-within_tol exp = abap_false ).
  ENDMETHOD.

  METHOD new_only_is_mismatch.
    add_new( iv_id = 'R9' iv_qty = 4 ).

    DATA(lt_lines) = mo_cut->compare( it_old       = mt_old
                                      it_new       = mt_new
                                      iv_tolerance = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-old_qty exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-within_tol exp = abap_false ).
  ENDMETHOD.

  METHOD old_only_is_mismatch.
    add_old( iv_id = 'R5' iv_qty = 6 ).

    DATA(lt_lines) = mo_cut->compare( it_old       = mt_old
                                      it_new       = mt_new
                                      iv_tolerance = 6 ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-new_qty exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-delta_qty exp = -6 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-within_tol exp = abap_true ).
  ENDMETHOD.

  METHOD counts_mismatches.
    add_old( iv_id = 'R1' iv_qty = 10 ).
    add_old( iv_id = 'R2' iv_qty = 4 ).
    add_new( iv_id = 'R1' iv_qty = 10 ).
    add_new( iv_id = 'R2' iv_qty = 9 ).

    DATA(lt_lines) = mo_cut->compare( it_old       = mt_old
                                      it_new       = mt_new
                                      iv_tolerance = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mismatch_count( lt_lines ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
