CLASS ltcl_alloc_interco_elim DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_interco_elim.
    DATA mt_line TYPE zcl_alloc_interco_elim=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material        TYPE matnr
        iv_margin          TYPE i
        iv_sold_externally TYPE abap_bool.

    METHODS eliminates_margin FOR TESTING.
    METHODS keeps_residual    FOR TESTING.
    METHODS cleared_rule      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_interco_elim IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_interco_elim( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_interco_elim=>ty_line.

    ls_line-material = iv_material.
    ls_line-margin = iv_margin.
    ls_line-sold_externally = iv_sold_externally.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD eliminates_margin.
    add( iv_material = 'M1' iv_margin = 100 iv_sold_externally = abap_false ).
    add( iv_material = 'M2' iv_margin = 50 iv_sold_externally = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->eliminate( mt_line ) exp = 100 ).
  ENDMETHOD.

  METHOD keeps_residual.
    add( iv_material = 'M1' iv_margin = 100 iv_sold_externally = abap_false ).
    add( iv_material = 'M2' iv_margin = 50 iv_sold_externally = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->residual( mt_line ) exp = 50 ).
  ENDMETHOD.

  METHOD cleared_rule.
    add( iv_material = 'M1' iv_margin = 50 iv_sold_externally = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_cleared( mt_line ) exp = abap_true ).

    add( iv_material = 'M2' iv_margin = 100 iv_sold_externally = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_cleared( mt_line ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
