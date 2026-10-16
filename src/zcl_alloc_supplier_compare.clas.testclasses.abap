CLASS ltcl_alloc_supplier_compare DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_supplier_compare.
    DATA mt_sup TYPE zcl_alloc_supplier_compare=>ty_supplier_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name  TYPE string
        iv_score TYPE i.

    METHODS finds_best    FOR TESTING.
    METHODS scores_named  FOR TESTING.
    METHODS counts        FOR TESTING.
    METHODS empty_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_supplier_compare IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_supplier_compare( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_supplier TYPE zcl_alloc_supplier_compare=>ty_supplier.

    ls_supplier-name = iv_name.
    ls_supplier-score = iv_score.
    APPEND ls_supplier TO mt_sup.
  ENDMETHOD.

  METHOD finds_best.
    add( iv_name = 'S1' iv_score = 80 ).
    add( iv_name = 'S2' iv_score = 95 ).
    add( iv_name = 'S3' iv_score = 90 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best( mt_sup ) exp = 'S2' ).
  ENDMETHOD.

  METHOD scores_named.
    add( iv_name = 'S1' iv_score = 80 ).
    add( iv_name = 'S3' iv_score = 90 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score_of( it_suppliers = mt_sup iv_name = 'S3' ) exp = 90 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score_of( it_suppliers = mt_sup iv_name = 'X9' ) exp = 0 ).
  ENDMETHOD.

  METHOD counts.
    add( iv_name = 'S1' iv_score = 80 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_sup ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best( mt_sup ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
