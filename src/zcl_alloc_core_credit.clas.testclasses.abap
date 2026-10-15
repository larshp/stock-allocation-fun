CLASS ltcl_alloc_core_credit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_core_credit.

    METHODS setup.

    METHODS core
      IMPORTING
        iv_material    TYPE matnr
        iv_returned    TYPE i
        iv_rate        TYPE i
      RETURNING
        VALUE(rs_core) TYPE zcl_alloc_core_credit=>ty_core.

    METHODS multiplies      FOR TESTING.
    METHODS guards_negative FOR TESTING.
    METHODS values_one     FOR TESTING.
    METHODS totals         FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_core_credit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_core_credit( ).
  ENDMETHOD.

  METHOD core.
    rs_core-material = iv_material.
    rs_core-returned = iv_returned.
    rs_core-credit_per_unit = iv_rate.
  ENDMETHOD.

  METHOD multiplies.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->credit( iv_returned = 3 iv_credit_per_unit = 50 )
      exp = 150 ).
  ENDMETHOD.

  METHOD guards_negative.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->credit( iv_returned = -1 iv_credit_per_unit = 50 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->credit( iv_returned = 3 iv_credit_per_unit = -1 )
      exp = 0 ).
  ENDMETHOD.

  METHOD values_one.
    DATA ls_core TYPE zcl_alloc_core_credit=>ty_core.

    ls_core = core( iv_material = 'M1' iv_returned = 4 iv_rate = 25 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->credit_of( ls_core ) exp = 100 ).
  ENDMETHOD.

  METHOD totals.
    DATA lt_cores TYPE zcl_alloc_core_credit=>ty_core_tt.
    DATA ls_core  TYPE zcl_alloc_core_credit=>ty_core.

    ls_core = core( iv_material = 'M1' iv_returned = 4 iv_rate = 25 ).
    APPEND ls_core TO lt_cores.
    ls_core = core( iv_material = 'M2' iv_returned = 1 iv_rate = 100 ).
    APPEND ls_core TO lt_cores.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_cores ) exp = 200 ).
  ENDMETHOD.

ENDCLASS.
