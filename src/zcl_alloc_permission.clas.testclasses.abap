CLASS ltcl_alloc_permission DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_permission.

    METHODS setup.

    METHODS allows_granted  FOR TESTING.
    METHODS denies_unknown  FOR TESTING.
    METHODS overwrites_cell FOR TESTING.
    METHODS counts_allowed  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_permission IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_permission( ).
  ENDMETHOD.

  METHOD allows_granted.
    DATA lv_allowed TYPE abap_bool.

    mo_cut->set( iv_role = 'ALLOCATOR' iv_actvt = 'READ' iv_allowed = abap_true ).

    lv_allowed = mo_cut->allows( iv_role = 'ALLOCATOR' iv_actvt = 'READ' ).

    cl_abap_unit_assert=>assert_equals( act = lv_allowed exp = abap_true ).
  ENDMETHOD.

  METHOD denies_unknown.
    DATA lv_allowed TYPE abap_bool.

    mo_cut->set( iv_role = 'ALLOCATOR' iv_actvt = 'READ' iv_allowed = abap_true ).

    lv_allowed = mo_cut->allows( iv_role = 'AUDITOR' iv_actvt = 'READ' ).

    cl_abap_unit_assert=>assert_equals( act = lv_allowed exp = abap_false ).
  ENDMETHOD.

  METHOD overwrites_cell.
    DATA lv_allowed TYPE abap_bool.

    mo_cut->set( iv_role = 'ALLOCATOR' iv_actvt = 'WRITE' iv_allowed = abap_true ).
    mo_cut->set( iv_role = 'ALLOCATOR' iv_actvt = 'WRITE' iv_allowed = abap_false ).

    lv_allowed = mo_cut->allows( iv_role = 'ALLOCATOR' iv_actvt = 'WRITE' ).

    cl_abap_unit_assert=>assert_equals( act = lv_allowed exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->allowed_count( ) exp = 0 ).
  ENDMETHOD.

  METHOD counts_allowed.
    mo_cut->set( iv_role = 'ALLOCATOR' iv_actvt = 'READ' iv_allowed = abap_true ).
    mo_cut->set( iv_role = 'ALLOCATOR' iv_actvt = 'WRITE' iv_allowed = abap_false ).
    mo_cut->set( iv_role = 'AUDITOR' iv_actvt = 'READ' iv_allowed = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->allowed_count( ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
