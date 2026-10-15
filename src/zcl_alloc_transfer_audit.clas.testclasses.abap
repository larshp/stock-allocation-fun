CLASS ltcl_alloc_transfer_audit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_transfer_audit.
    DATA mt_line TYPE zcl_alloc_transfer_audit=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material       TYPE matnr
        iv_transfer_price TYPE i
        iv_market_price   TYPE i.

    METHODS audits_lines    FOR TESTING.
    METHODS counts_violations FOR TESTING.
    METHODS picks_worst     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_transfer_audit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_transfer_audit( ).

    add( iv_material = 'M1' iv_transfer_price = 1040 iv_market_price = 1000 ).
    add( iv_material = 'M2' iv_transfer_price = 1100 iv_market_price = 1000 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_transfer_audit=>ty_line.

    ls_line-material = iv_material.
    ls_line-transfer_price = iv_transfer_price.
    ls_line-market_price = iv_market_price.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD audits_lines.
    DATA lt_violations TYPE zcl_alloc_transfer_audit=>ty_violation_tt.

    lt_violations = mo_cut->audit( it_lines             = mt_line
                                   iv_tolerance_percent = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_violations ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_violations[ 1 ]-material exp = 'M2' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_violations[ 1 ]-gap exp = 100 ).
  ENDMETHOD.

  METHOD counts_violations.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->violation_count( it_lines             = mt_line
                                     iv_tolerance_percent = 5 )
      exp = 1 ).
  ENDMETHOD.

  METHOD picks_worst.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst( mt_line ) exp = 100 ).
  ENDMETHOD.

ENDCLASS.
