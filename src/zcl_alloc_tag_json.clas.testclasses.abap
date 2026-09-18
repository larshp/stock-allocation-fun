CLASS ltcl_alloc_tag_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_tag_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_tag_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_tag_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_tags TYPE zcl_alloc_tag=>ty_tag_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_tags )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_tags TYPE zcl_alloc_tag=>ty_tag_tt.
    DATA ls_tag  TYPE zcl_alloc_tag=>ty_tag.

    ls_tag-run_id = 'R1'.
    ls_tag-tag = 'URGENT'.
    APPEND ls_tag TO lt_tags.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_tags )
      exp = '[{"run_id":"R1","tag":"URGENT"}]' ).
  ENDMETHOD.

ENDCLASS.
