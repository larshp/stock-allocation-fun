CLASS ltcl_alloc_policy_diff DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_policy_diff.

    METHODS setup.

    METHODS input
      IMPORTING
        is_old        TYPE zcl_stock_allocator=>ty_policy
        is_new        TYPE zcl_stock_allocator=>ty_policy
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_policy_diff=>ty_input.

    METHODS identical_empty FOR TESTING.
    METHODS flag_changed    FOR TESTING.
    METHODS scalar_changed  FOR TESTING.
    METHODS table_changed   FOR TESTING.
    METHODS several_changes FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_policy_diff IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_policy_diff( ).
  ENDMETHOD.

  METHOD input.
    rs_row-old_policy = is_old.
    rs_row-new_policy = is_new.
  ENDMETHOD.

  METHOD identical_empty.
    DATA ls_old TYPE zcl_stock_allocator=>ty_policy.
    DATA ls_new TYPE zcl_stock_allocator=>ty_policy.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->compare( input( is_old = ls_old is_new = ls_new ) ) ).
  ENDMETHOD.

  METHOD flag_changed.
    DATA ls_old TYPE zcl_stock_allocator=>ty_policy.
    DATA ls_new TYPE zcl_stock_allocator=>ty_policy.

    ls_new-use_fefo = abap_true.

    DATA(lt_lines) = mo_cut->compare( input( is_old = ls_old
                                             is_new = ls_new ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-field_name
                                        exp = 'USE_FEFO' ).
  ENDMETHOD.

  METHOD scalar_changed.
    DATA ls_old TYPE zcl_stock_allocator=>ty_policy.
    DATA ls_new TYPE zcl_stock_allocator=>ty_policy.

    ls_old-max_picks = 1.
    ls_new-max_picks = 3.

    DATA(lt_lines) = mo_cut->compare( input( is_old = ls_old
                                             is_new = ls_new ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-old_value
                                        exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-new_value
                                        exp = '3' ).
  ENDMETHOD.

  METHOD table_changed.
    DATA ls_old TYPE zcl_stock_allocator=>ty_policy.
    DATA ls_new TYPE zcl_stock_allocator=>ty_policy.

    APPEND '0001' TO ls_new-allowed_lgorts.

    DATA(lt_lines) = mo_cut->compare( input( is_old = ls_old
                                             is_new = ls_new ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-field_name
                                        exp = 'ALLOWED_COUNT' ).
  ENDMETHOD.

  METHOD several_changes.
    DATA ls_old TYPE zcl_stock_allocator=>ty_policy.
    DATA ls_new TYPE zcl_stock_allocator=>ty_policy.

    ls_new-use_fefo = abap_true.
    ls_new-under_tolerance = 5.

    DATA(lt_lines) = mo_cut->compare( input( is_old = ls_old
                                             is_new = ls_new ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
