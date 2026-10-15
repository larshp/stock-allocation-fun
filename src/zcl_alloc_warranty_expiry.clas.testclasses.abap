CLASS ltcl_alloc_warranty_expiry DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_warranty_expiry.

    METHODS setup.

    METHODS warranty
      IMPORTING
        iv_start           TYPE d
        iv_days            TYPE i
      RETURNING
        VALUE(rs_warranty) TYPE zcl_alloc_warranty_expiry=>ty_warranty.

    METHODS expiry_reads     FOR TESTING.
    METHODS not_expired_yet  FOR TESTING.
    METHODS expired          FOR TESTING.
    METHODS days_remaining   FOR TESTING.
    METHODS bad_warranty     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_warranty_expiry IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_warranty_expiry( ).
  ENDMETHOD.

  METHOD warranty.
    rs_warranty-start_day = iv_start.
    rs_warranty-days = iv_days.
  ENDMETHOD.

  METHOD expiry_reads.
    DATA ls_warranty TYPE zcl_alloc_warranty_expiry=>ty_warranty.

    ls_warranty = warranty( iv_start = '20260101' iv_days = 365 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->expiry_day( ls_warranty )
      exp = '20270101' ).
  ENDMETHOD.

  METHOD not_expired_yet.
    DATA ls_warranty TYPE zcl_alloc_warranty_expiry=>ty_warranty.

    ls_warranty = warranty( iv_start = '20260101' iv_days = 365 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_expired( is_warranty  = ls_warranty
                                 iv_check_day = '20261231' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_expired( is_warranty  = ls_warranty
                                 iv_check_day = '20270101' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD expired.
    DATA ls_warranty TYPE zcl_alloc_warranty_expiry=>ty_warranty.

    ls_warranty = warranty( iv_start = '20260101' iv_days = 365 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_expired( is_warranty  = ls_warranty
                                 iv_check_day = '20270102' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD days_remaining.
    DATA ls_warranty TYPE zcl_alloc_warranty_expiry=>ty_warranty.

    ls_warranty = warranty( iv_start = '20260101' iv_days = 365 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_left( is_warranty  = ls_warranty
                               iv_check_day = '20261231' )
      exp = 1 ).
  ENDMETHOD.

  METHOD bad_warranty.
    DATA ls_warranty TYPE zcl_alloc_warranty_expiry=>ty_warranty.

    ls_warranty = warranty( iv_start = '20260101' iv_days = -1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->expiry_day( ls_warranty )
      exp = '00000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_expired( is_warranty  = ls_warranty
                                 iv_check_day = '20260601' )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
