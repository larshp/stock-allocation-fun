CLASS ltcl_alloc_absorb_prorate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_absorb_prorate.
    DATA mt_line TYPE zcl_alloc_absorb_prorate=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name TYPE string
        iv_base TYPE i.

    METHODS prorates_amount FOR TESTING.
    METHODS computes_share FOR TESTING.
    METHODS sums_total     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_absorb_prorate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_absorb_prorate( ).

    add( iv_name = 'A' iv_base = 100 ).
    add( iv_name = 'B' iv_base = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_absorb_prorate=>ty_line.

    ls_line-name = iv_name.
    ls_line-base = iv_base.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD prorates_amount.
    DATA lt_share TYPE zcl_alloc_absorb_prorate=>ty_share_tt.

    lt_share = mo_cut->prorate( it_lines = mt_line iv_amount = 400 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_share ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_share[ 1 ]-amount exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_share[ 2 ]-amount exp = 300 ).
  ENDMETHOD.

  METHOD computes_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share( iv_base = 100 iv_total_base = 400 iv_amount = 400 )
      exp = 100 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 400 ).
  ENDMETHOD.

ENDCLASS.
