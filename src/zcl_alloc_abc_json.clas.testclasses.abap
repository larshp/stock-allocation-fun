CLASS ltcl_alloc_abc_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_abc_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_classes TYPE zcl_alloc_abc=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_classes )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_classes TYPE zcl_alloc_abc=>ty_line_tt.
    DATA ls_class   TYPE zcl_alloc_abc=>ty_line.

    ls_class-matnr = 'MAT-1'.
    ls_class-quantity = '80'.
    ls_class-share_pct = 80.
    ls_class-cum_pct = 80.
    ls_class-class = 'A'.
    APPEND ls_class TO lt_classes.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_classes )
      exp = '[{"matnr":"MAT-1","quantity":80.000,"share_pct":80,' &&
            '"cum_pct":80,"class":"A"}]' ).
  ENDMETHOD.

ENDCLASS.
