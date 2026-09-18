CLASS ltcl_alloc_tag_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_tag_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_tag_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_tag_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_tags TYPE zcl_alloc_tag=>ty_tag_tt.

    DATA(lt_lines) = mo_cut->build( lt_tags ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'RUN_ID;TAG' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_tags TYPE zcl_alloc_tag=>ty_tag_tt.
    DATA ls_tag  TYPE zcl_alloc_tag=>ty_tag.

    ls_tag-run_id = 'R1'.
    ls_tag-tag = 'URGENT'.
    APPEND ls_tag TO lt_tags.

    DATA(lt_lines) = mo_cut->build( lt_tags ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'R1;URGENT' ).
  ENDMETHOD.

ENDCLASS.
