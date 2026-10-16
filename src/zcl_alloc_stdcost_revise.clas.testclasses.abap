CLASS ltcl_alloc_stdcost_revise DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stdcost_revise.
    DATA mt_cost TYPE zcl_alloc_stdcost_revise=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_cost TYPE i.

    METHODS revises_cost   FOR TESTING.
    METHODS revised_rule   FOR TESTING.
    METHODS counts_revisions FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stdcost_revise IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stdcost_revise( ).

    add( iv_cost = 100 ).
    add( iv_cost = 105 ).
    add( iv_cost = 110 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_cost TO mt_cost.
  ENDMETHOD.

  METHOD revises_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->revise( iv_current = 100 iv_percent = 5 )
      exp = 105 ).
  ENDMETHOD.

  METHOD revised_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_revised( iv_current = 100 iv_new = 105 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_revised( iv_current = 100 iv_new = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_revisions.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->revision_count( mt_cost ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
