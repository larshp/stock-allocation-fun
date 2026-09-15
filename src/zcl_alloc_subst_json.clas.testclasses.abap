CLASS ltcl_alloc_subst_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_subst_json.

    METHODS setup.

    METHODS empty_result FOR TESTING.
    METHODS one_hop      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_subst_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_subst_json( ).
  ENDMETHOD.

  METHOD empty_result.
    DATA ls_result TYPE zcl_alloc_subst_chain=>ty_result.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_result )
      exp = '{"path":[],"final_matnr":"","steps":0}' ).
  ENDMETHOD.

  METHOD one_hop.
    DATA ls_result TYPE zcl_alloc_subst_chain=>ty_result.

    APPEND 'MAT-A' TO ls_result-path.
    APPEND 'MAT-B' TO ls_result-path.
    ls_result-final_matnr = 'MAT-B'.
    ls_result-steps = 1.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( ls_result )
      exp = '{"path":["MAT-A","MAT-B"],"final_matnr":"MAT-B","steps":1}' ).
  ENDMETHOD.

ENDCLASS.
