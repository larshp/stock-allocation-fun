CLASS ltcl_alloc_constraint DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_constraint.
    DATA mt_con TYPE zcl_alloc_constraint=>ty_constraint_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id        TYPE string
        iv_mandatory TYPE abap_bool
        iv_holds     TYPE abap_bool.

    METHODS empty_is_feasible   FOR TESTING.
    METHODS all_satisfied       FOR TESTING.
    METHODS optional_violation  FOR TESTING.
    METHODS mandatory_violation FOR TESTING.
    METHODS counts_values       FOR TESTING.
    METHODS lists_mandatory_ids FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_constraint IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_constraint( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_constraint TYPE zcl_alloc_constraint=>ty_constraint.

    ls_constraint-constraint_id = iv_id.
    ls_constraint-must_hold = iv_mandatory.
    ls_constraint-holds = iv_holds.
    APPEND ls_constraint TO mt_con.
  ENDMETHOD.

  METHOD empty_is_feasible.
    DATA(ls_result) = mo_cut->evaluate( mt_con ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-feasible exp = abap_true ).
  ENDMETHOD.

  METHOD all_satisfied.
    add( iv_id = 'A' iv_mandatory = abap_true iv_holds = abap_true ).
    add( iv_id = 'B' iv_mandatory = abap_false iv_holds = abap_true ).

    DATA(ls_result) = mo_cut->evaluate( mt_con ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-satisfied exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-violated exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-feasible exp = abap_true ).
  ENDMETHOD.

  METHOD optional_violation.
    add( iv_id = 'A' iv_mandatory = abap_false iv_holds = abap_false ).

    DATA(ls_result) = mo_cut->evaluate( mt_con ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-violated exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-mandatory_violated exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-feasible exp = abap_true ).
  ENDMETHOD.

  METHOD mandatory_violation.
    add( iv_id = 'A' iv_mandatory = abap_true iv_holds = abap_true ).
    add( iv_id = 'B' iv_mandatory = abap_true iv_holds = abap_false ).

    DATA(ls_result) = mo_cut->evaluate( mt_con ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-mandatory_violated exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-feasible exp = abap_false ).
  ENDMETHOD.

  METHOD counts_values.
    add( iv_id = 'A' iv_mandatory = abap_true iv_holds = abap_true ).
    add( iv_id = 'B' iv_mandatory = abap_true iv_holds = abap_false ).
    add( iv_id = 'C' iv_mandatory = abap_false iv_holds = abap_false ).

    DATA(ls_result) = mo_cut->evaluate( mt_con ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-satisfied exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-violated exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-mandatory_violated exp = 1 ).
  ENDMETHOD.

  METHOD lists_mandatory_ids.
    add( iv_id = 'A' iv_mandatory = abap_true iv_holds = abap_false ).
    add( iv_id = 'B' iv_mandatory = abap_false iv_holds = abap_false ).
    add( iv_id = 'C' iv_mandatory = abap_true iv_holds = abap_false ).

    DATA(lt_ids) = mo_cut->violated_ids( mt_con ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_ids ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ids[ 1 ] exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_ids[ 2 ] exp = 'C' ).
  ENDMETHOD.

ENDCLASS.
