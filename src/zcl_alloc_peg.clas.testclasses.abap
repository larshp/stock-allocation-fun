CLASS ltcl_alloc_peg DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_peg.
    DATA mt_req TYPE zcl_alloc_peg=>ty_req_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material    TYPE matnr
        iv_requirement TYPE i
        iv_supply      TYPE i.

    METHODS pegs_quantity FOR TESTING.
    METHODS pegged_rule   FOR TESTING.
    METHODS counts_pegged FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_peg IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_peg( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_req TYPE zcl_alloc_peg=>ty_req.

    ls_req-material = iv_material.
    ls_req-requirement = iv_requirement.
    ls_req-supply = iv_supply.
    APPEND ls_req TO mt_req.
  ENDMETHOD.

  METHOD pegs_quantity.
    DATA ls_req TYPE zcl_alloc_peg=>ty_req.

    ls_req-requirement = 100.
    ls_req-supply = 100.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->peg( ls_req ) exp = 100 ).

    ls_req-supply = 40.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->peg( ls_req ) exp = 40 ).
  ENDMETHOD.

  METHOD pegged_rule.
    DATA ls_req TYPE zcl_alloc_peg=>ty_req.

    ls_req-requirement = 100.
    ls_req-supply = 100.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_pegged( ls_req ) exp = abap_true ).

    ls_req-supply = 40.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_pegged( ls_req ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_pegged.
    add( iv_material = 'M1' iv_requirement = 100 iv_supply = 100 ).
    add( iv_material = 'M2' iv_requirement = 100 iv_supply = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->peg_count( mt_req ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
