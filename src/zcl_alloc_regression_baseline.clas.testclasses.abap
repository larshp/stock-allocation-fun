CLASS ltcl_alloc_regression_baseline DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_regression_baseline.
    DATA mt_res TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add_line
      IMPORTING
        iv_id    TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_alloc TYPE menge_d.

    METHODS capture_of_result FOR TESTING.
    METHODS identical_is_unchanged FOR TESTING.
    METHODS changed_quantity FOR TESTING.
    METHODS added_line     FOR TESTING.
    METHODS removed_line   FOR TESTING.
    METHODS empty_baseline FOR TESTING.
    METHODS empty_run      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_regression_baseline IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_regression_baseline( ).
  ENDMETHOD.

  METHOD add_line.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    ls_line-requirement_id = iv_id.
    ls_line-allocated_qty = iv_alloc.
    APPEND ls_line TO mt_res.
  ENDMETHOD.

  METHOD capture_of_result.
    add_line( iv_id = 'R1' iv_alloc = 10 ).
    add_line( iv_id = 'R2' iv_alloc = 4 ).

    DATA(lt_signature) = mo_cut->capture( mt_res ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_signature ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_signature[ 1 ]-requirement_id exp = 'R1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_signature[ 2 ]-allocated_qty exp = 4 ).
  ENDMETHOD.

  METHOD identical_is_unchanged.
    DATA(lt_before) = VALUE zcl_alloc_regression_baseline=>ty_entry_tt(
      ( requirement_id = 'R1' allocated_qty = 10 ) ).

    DATA(lt_after) = VALUE zcl_alloc_regression_baseline=>ty_entry_tt(
      ( requirement_id = 'R1' allocated_qty = 10 ) ).

    DATA(lt_deltas) = mo_cut->compare( it_before = lt_before
                                       it_after  = lt_after ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_deltas ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_unchanged( lt_deltas ) exp = abap_true ).
  ENDMETHOD.

  METHOD changed_quantity.
    DATA(lt_before) = VALUE zcl_alloc_regression_baseline=>ty_entry_tt(
      ( requirement_id = 'R1' allocated_qty = 10 ) ).

    DATA(lt_after) = VALUE zcl_alloc_regression_baseline=>ty_entry_tt(
      ( requirement_id = 'R1' allocated_qty = 7 ) ).

    DATA(lt_deltas) = mo_cut->compare( it_before = lt_before
                                       it_after  = lt_after ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_deltas ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_deltas[ 1 ]-kind exp = 'changed' ).
    cl_abap_unit_assert=>assert_equals( act = lt_deltas[ 1 ]-before_qty exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_deltas[ 1 ]-after_qty exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_unchanged( lt_deltas ) exp = abap_false ).
  ENDMETHOD.

  METHOD added_line.
    DATA(lt_before) = VALUE zcl_alloc_regression_baseline=>ty_entry_tt(
      ( requirement_id = 'R1' allocated_qty = 10 ) ).

    DATA(lt_after) = VALUE zcl_alloc_regression_baseline=>ty_entry_tt(
      ( requirement_id = 'R1' allocated_qty = 10 )
      ( requirement_id = 'R2' allocated_qty = 5 ) ).

    DATA(lt_deltas) = mo_cut->compare( it_before = lt_before
                                       it_after  = lt_after ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_deltas ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_deltas[ 1 ]-kind exp = 'added' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_deltas[ 1 ]-requirement_id exp = 'R2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_deltas[ 1 ]-after_qty exp = 5 ).
  ENDMETHOD.

  METHOD removed_line.
    DATA(lt_before) = VALUE zcl_alloc_regression_baseline=>ty_entry_tt(
      ( requirement_id = 'R1' allocated_qty = 10 )
      ( requirement_id = 'R2' allocated_qty = 4 ) ).

    DATA(lt_after) = VALUE zcl_alloc_regression_baseline=>ty_entry_tt(
      ( requirement_id = 'R1' allocated_qty = 10 ) ).

    DATA(lt_deltas) = mo_cut->compare( it_before = lt_before
                                       it_after  = lt_after ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_deltas ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_deltas[ 1 ]-kind exp = 'removed' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_deltas[ 1 ]-before_qty exp = 4 ).
  ENDMETHOD.

  METHOD empty_baseline.
    DATA lt_empty TYPE zcl_alloc_regression_baseline=>ty_entry_tt.
    DATA(lt_after) = VALUE zcl_alloc_regression_baseline=>ty_entry_tt(
      ( requirement_id = 'R1' allocated_qty = 10 ) ).

    DATA(lt_deltas) = mo_cut->compare( it_before = lt_empty
                                       it_after  = lt_after ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_deltas ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_deltas[ 1 ]-kind exp = 'added' ).
  ENDMETHOD.

  METHOD empty_run.
    DATA lt_empty TYPE zcl_alloc_regression_baseline=>ty_entry_tt.
    DATA(lt_before) = VALUE zcl_alloc_regression_baseline=>ty_entry_tt(
      ( requirement_id = 'R1' allocated_qty = 10 ) ).

    DATA(lt_deltas) = mo_cut->compare( it_before = lt_before
                                       it_after  = lt_empty ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_deltas ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_deltas[ 1 ]-kind exp = 'removed' ).
  ENDMETHOD.

ENDCLASS.
