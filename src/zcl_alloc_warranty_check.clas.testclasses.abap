CLASS ltcl_alloc_warranty_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_warranty_check.

    METHODS setup.

    METHODS warranty
      IMPORTING
        iv_start           TYPE d
        iv_days            TYPE i
      RETURNING
        VALUE(rs_warranty) TYPE zcl_alloc_warranty_check=>ty_warranty.

    METHODS covers_inclusively FOR TESTING.
    METHODS covers_start_day   FOR TESTING.
    METHODS expired            FOR TESTING.
    METHODS remaining          FOR TESTING.
    METHODS reasons            FOR TESTING.
    METHODS no_warranty        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_warranty_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_warranty_check( ).
  ENDMETHOD.

  METHOD warranty.
    rs_warranty-material = 'M1'.
    rs_warranty-start_day = iv_start.
    rs_warranty-days = iv_days.
  ENDMETHOD.

  METHOD covers_inclusively.
    DATA ls_warranty TYPE zcl_alloc_warranty_check=>ty_warranty.

    ls_warranty = warranty( iv_start = '20260101' iv_days = 365 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( is_warranty  = ls_warranty
                                iv_check_day = '20260601' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( is_warranty  = ls_warranty
                                iv_check_day = '20270101' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD covers_start_day.
    DATA ls_warranty TYPE zcl_alloc_warranty_check=>ty_warranty.

    ls_warranty = warranty( iv_start = '20260101' iv_days = 365 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( is_warranty  = ls_warranty
                                iv_check_day = '20260101' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( is_warranty  = ls_warranty
                                iv_check_day = '20251231' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD expired.
    DATA ls_warranty TYPE zcl_alloc_warranty_check=>ty_warranty.

    ls_warranty = warranty( iv_start = '20260101' iv_days = 365 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( is_warranty  = ls_warranty
                                iv_check_day = '20270102' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD remaining.
    DATA ls_warranty TYPE zcl_alloc_warranty_check=>ty_warranty.

    ls_warranty = warranty( iv_start = '20260101' iv_days = 365 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining_days( is_warranty  = ls_warranty
                                    iv_check_day = '20260201' )
      exp = 334 ).
  ENDMETHOD.

  METHOD reasons.
    DATA ls_warranty TYPE zcl_alloc_warranty_check=>ty_warranty.

    ls_warranty = warranty( iv_start = '20260101' iv_days = 365 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( is_warranty  = ls_warranty
                            iv_check_day = '20260601' )
      exp = 'COVERED' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( is_warranty  = ls_warranty
                            iv_check_day = '20251231' )
      exp = 'NOT_STARTED' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( is_warranty  = ls_warranty
                            iv_check_day = '20270102' )
      exp = 'EXPIRED' ).
  ENDMETHOD.

  METHOD no_warranty.
    DATA ls_warranty TYPE zcl_alloc_warranty_check=>ty_warranty.

    ls_warranty = warranty( iv_start = '20260101' iv_days = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( is_warranty  = ls_warranty
                            iv_check_day = '20260601' )
      exp = 'NO_WARRANTY' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( is_warranty  = ls_warranty
                                iv_check_day = '20260601' )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
