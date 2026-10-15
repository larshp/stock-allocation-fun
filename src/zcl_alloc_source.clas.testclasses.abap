CLASS ltcl_alloc_source DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_source.
    DATA mt_src TYPE zcl_alloc_source=>ty_source_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_supplier TYPE string
        iv_quota    TYPE i
        iv_fixed    TYPE abap_bool.

    METHODS selects_source FOR TESTING.
    METHODS favours_fixed  FOR TESTING.
    METHODS quota_rule     FOR TESTING.
    METHODS reads_quota    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_source IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_source( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_source TYPE zcl_alloc_source=>ty_source.

    ls_source-supplier = iv_supplier.
    ls_source-quota = iv_quota.
    ls_source-fixed = iv_fixed.
    APPEND ls_source TO mt_src.
  ENDMETHOD.

  METHOD selects_source.
    add( iv_supplier = 'S1' iv_quota = 60 iv_fixed = abap_false ).
    add( iv_supplier = 'S2' iv_quota = 40 iv_fixed = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( mt_src ) exp = 'S1' ).
  ENDMETHOD.

  METHOD favours_fixed.
    add( iv_supplier = 'S1' iv_quota = 60 iv_fixed = abap_false ).
    add( iv_supplier = 'S2' iv_quota = 40 iv_fixed = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( mt_src ) exp = 'S2' ).
  ENDMETHOD.

  METHOD quota_rule.
    add( iv_supplier = 'S1' iv_quota = 60 iv_fixed = abap_false ).
    add( iv_supplier = 'S2' iv_quota = 40 iv_fixed = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_quota( mt_src ) exp = abap_true ).
  ENDMETHOD.

  METHOD reads_quota.
    add( iv_supplier = 'S1' iv_quota = 60 iv_fixed = abap_false ).
    add( iv_supplier = 'S2' iv_quota = 40 iv_fixed = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->quota_of( it_sources = mt_src iv_supplier = 'S2' ) exp = 40 ).
  ENDMETHOD.

ENDCLASS.
