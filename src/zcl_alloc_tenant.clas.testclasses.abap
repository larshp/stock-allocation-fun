CLASS ltcl_alloc_tenant DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_tenant.

    METHODS setup.

    METHODS defaults_to_default FOR TESTING.
    METHODS keeps_tenant       FOR TESTING.
    METHODS compares_tenant    FOR TESTING.
    METHODS qualifies_key      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_tenant IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_tenant( ).
  ENDMETHOD.

  METHOD defaults_to_default.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get_tenant( ) exp = 'DEFAULT' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_default( ) exp = abap_true ).
  ENDMETHOD.

  METHOD keeps_tenant.
    DATA lo_tenant TYPE REF TO zcl_alloc_tenant.

    lo_tenant = NEW zcl_alloc_tenant( iv_tenant = 'ACME' ).

    cl_abap_unit_assert=>assert_equals( act = lo_tenant->get_tenant( ) exp = 'ACME' ).
    cl_abap_unit_assert=>assert_equals( act = lo_tenant->is_default( ) exp = abap_false ).
  ENDMETHOD.

  METHOD compares_tenant.
    DATA lo_tenant TYPE REF TO zcl_alloc_tenant.

    lo_tenant = NEW zcl_alloc_tenant( iv_tenant = 'ACME' ).

    cl_abap_unit_assert=>assert_equals( act = lo_tenant->belongs_to( 'ACME' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lo_tenant->belongs_to( 'OTHER' ) exp = abap_false ).
  ENDMETHOD.

  METHOD qualifies_key.
    DATA lo_tenant TYPE REF TO zcl_alloc_tenant.

    lo_tenant = NEW zcl_alloc_tenant( iv_tenant = 'ACME' ).

    cl_abap_unit_assert=>assert_equals( act = lo_tenant->qualify( 'R1' ) exp = 'ACME::R1' ).
  ENDMETHOD.

ENDCLASS.
