CLASS ltcl_alloc_recon_resolve DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recon_resolve.
    DATA mt_line TYPE zcl_alloc_recon_resolve=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_key  TYPE string
        iv_diff TYPE i.

    METHODS resolves_diffs FOR TESTING.
    METHODS resolved_rule  FOR TESTING.
    METHODS counts_open    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recon_resolve IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recon_resolve( ).

    add( iv_key = 'K1' iv_diff = 5 ).
    add( iv_key = 'K2' iv_diff = 100 ).
    add( iv_key = 'K3' iv_diff = 0 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_recon_resolve=>ty_line.

    ls_line-key = iv_key.
    ls_line-diff = iv_diff.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD resolves_diffs.
    DATA lt_out TYPE zcl_alloc_recon_resolve=>ty_line_tt.

    lt_out = mo_cut->resolve( it_diffs = mt_line iv_tolerance = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_out ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_out[ 1 ]-diff exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_out[ 2 ]-diff exp = 100 ).
  ENDMETHOD.

  METHOD resolved_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_resolved( iv_diff = 5 iv_tolerance = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_resolved( iv_diff = 100 iv_tolerance = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_open.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->open_count( it_diffs = mt_line iv_tolerance = 10 )
      exp = 1 ).
  ENDMETHOD.

ENDCLASS.
