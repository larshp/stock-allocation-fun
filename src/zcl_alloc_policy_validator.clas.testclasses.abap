CLASS ltcl_alloc_policy_validator DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_policy_validator.

    METHODS setup.

    METHODS default_policy   FOR TESTING.
    METHODS tolerance_range  FOR TESTING.
    METHODS negative_picks   FOR TESTING.
    METHODS negative_safety  FOR TESTING.
    METHODS negative_days    FOR TESTING.
    METHODS missing_reference FOR TESTING.
    METHODS both_lists       FOR TESTING.
    METHODS reference_present FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_policy_validator IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_policy_validator( ).
  ENDMETHOD.

  METHOD default_policy.
    DATA ls_policy TYPE zcl_stock_allocator=>ty_policy.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->validate( ls_policy ) ).
  ENDMETHOD.

  METHOD tolerance_range.
    DATA ls_policy TYPE zcl_stock_allocator=>ty_policy.

    ls_policy-under_tolerance = 150.

    DATA(lt_issues) = mo_cut->validate( ls_policy ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-field_name
                                        exp = 'UNDER_TOLERANCE' ).
  ENDMETHOD.

  METHOD negative_picks.
    DATA ls_policy TYPE zcl_stock_allocator=>ty_policy.

    ls_policy-max_picks = -1.

    DATA(lt_issues) = mo_cut->validate( ls_policy ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-field_name
                                        exp = 'MAX_PICKS' ).
  ENDMETHOD.

  METHOD negative_safety.
    DATA ls_policy TYPE zcl_stock_allocator=>ty_policy.

    ls_policy-safety_stock = '-5'.

    DATA(lt_issues) = mo_cut->validate( ls_policy ).

    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-field_name
                                        exp = 'SAFETY_STOCK' ).
  ENDMETHOD.

  METHOD negative_days.
    DATA ls_policy TYPE zcl_stock_allocator=>ty_policy.

    ls_policy-min_remaining_days = -2.

    DATA(lt_issues) = mo_cut->validate( ls_policy ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-field_name
                                        exp = 'MIN_REMAINING_DAYS' ).
  ENDMETHOD.

  METHOD missing_reference.
    DATA ls_policy TYPE zcl_stock_allocator=>ty_policy.

    ls_policy-min_remaining_days = 10.

    DATA(lt_issues) = mo_cut->validate( ls_policy ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-field_name
                                        exp = 'REFERENCE_DATE' ).
  ENDMETHOD.

  METHOD both_lists.
    DATA ls_policy TYPE zcl_stock_allocator=>ty_policy.

    APPEND '0001' TO ls_policy-allowed_lgorts.
    APPEND '0002' TO ls_policy-excluded_lgorts.

    DATA(lt_issues) = mo_cut->validate( ls_policy ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-field_name
                                        exp = 'LGORTS' ).
  ENDMETHOD.

  METHOD reference_present.
    DATA ls_policy TYPE zcl_stock_allocator=>ty_policy.

    ls_policy-min_remaining_days = 10.
    ls_policy-reference_date = '20260912'.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->validate( ls_policy ) ).
  ENDMETHOD.

ENDCLASS.
